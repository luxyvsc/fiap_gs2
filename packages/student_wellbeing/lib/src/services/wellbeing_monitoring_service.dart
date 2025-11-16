import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/alert_cluster.dart';
import '../models/wellbeing_checkin.dart';
import '../models/wellbeing_score.dart';

/// Service for monitoring student wellbeing with LGPD/GDPR compliance.
///
/// This service provides:
/// - Consent-based data collection
/// - Local encrypted storage
/// - Data anonymization
/// - Early warning detection
/// - Privacy-focused data management
///
/// **IMPORTANT**: This implementation uses flutter_secure_storage as a
/// placeholder for secure storage. For production, integrate with
/// certified secure storage solutions and proper key management.
///
/// ## Production TODOs for Security:
/// 
/// 1. **Strong Encryption**: Replace flutter_secure_storage with hardware-backed
///    secure storage (HSM integration, Keystore/Keychain with attestation).
///    
/// 2. **Backend Integration**: Implement real backend API with:
///    - TLS 1.3+ for transport security
///    - Certificate pinning to prevent MITM attacks
///    - OAuth 2.0 or JWT-based authentication
///    - Server-side data validation and sanitization
///    
/// 3. **Key Management**: Implement proper cryptographic key management:
///    - Key rotation policies
///    - Secure key derivation (PBKDF2, Argon2)
///    - Hardware-backed key storage
///    - Separate encryption keys for different data types
///    
/// 4. **Advanced Anonymization**: Implement differential privacy techniques
///    to further protect individual data in aggregate reports.
///    
/// 5. **Audit Logging**: Implement comprehensive audit trails for all
///    data access and modifications (LGPD/GDPR requirement).
///    
/// 6. **Data Residency**: Ensure data storage complies with jurisdictional
///    requirements (Brazil for LGPD, EU for GDPR).
///
/// 7. **Penetration Testing**: Conduct regular security audits and penetration
///    testing before production deployment.
class WellbeingMonitoringService {
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  final Uuid _uuid;

  // Stream controllers for reactive state management
  final _checkinsController =
      StreamController<List<WellbeingCheckin>>.broadcast();
  final _scoresController = StreamController<WellbeingScore>.broadcast();
  final _alertsController = StreamController<List<AlertCluster>>.broadcast();

  // In-memory cache
  List<WellbeingCheckin> _checkins = [];
  List<AlertCluster> _alerts = [];

  // Configuration
  int _retentionDays;
  final int alertWindowDays;
  final double stressThreshold;
  final double scoreThreshold;
  final double alertDropPercentThreshold;
  final int consecutiveLowMoodThreshold;
  final int movingAverageWindowSize;
  
  /// Get current retention period in days
  int get retentionDays => _retentionDays;

  /// Creates a new wellbeing monitoring service.
  ///
  /// [retentionDays]: How long to keep data locally (default: 30 days).
  /// [alertWindowDays]: Time window for alert detection (default: 7 days).
  /// [stressThreshold]: Stress level that triggers alerts (default: 4.0).
  /// [scoreThreshold]: Wellbeing score below which alerts trigger (default: 40.0).
  /// [alertDropPercentThreshold]: Percentage drop that triggers alert (default: 20.0).
  /// [consecutiveLowMoodThreshold]: Number of consecutive low moods to trigger alert (default: 3).
  /// [movingAverageWindowSize]: Window size for moving average calculation (default: 7).
  WellbeingMonitoringService({
    FlutterSecureStorage? secureStorage,
    Logger? logger,
    Uuid? uuid,
    int retentionDays = 30,
    this.alertWindowDays = 7,
    this.stressThreshold = 4.0,
    this.scoreThreshold = 40.0,
    this.alertDropPercentThreshold = 20.0,
    this.consecutiveLowMoodThreshold = 3,
    this.movingAverageWindowSize = 7,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _logger = logger ?? Logger(),
        _uuid = uuid ?? const Uuid(),
        _retentionDays = retentionDays;

  /// Stream of all check-ins (updates when new check-ins are added).
  Stream<List<WellbeingCheckin>> get checkinsStream =>
      _checkinsController.stream;

  /// Stream of wellbeing scores (updates when scores are recalculated).
  Stream<WellbeingScore> get scoresStream => _scoresController.stream;

  /// Stream of alerts (updates when new alerts are detected).
  Stream<List<AlertCluster>> get alertsStream => _alertsController.stream;

  /// Initializes the service and loads stored data.
  Future<void> initialize() async {
    _logger.i('Initializing WellbeingMonitoringService');
    await _loadCheckinsFromStorage();
    await _loadAlertsFromStorage();
    await _cleanupOldData();
    _logger.i(
      'Loaded ${_checkins.length} check-ins and ${_alerts.length} alerts',
    );
  }

  /// Records a new wellbeing check-in.
  ///
  /// [studentId]: Optional student identifier (only stored locally with consent).
  /// [moodLevel]: Mood rating from 1-5.
  /// [stressLevel]: Stress rating from 1-5.
  /// [notes]: Optional notes from the student.
  /// [consentToShare]: Whether student consents to share anonymized data.
  ///
  /// Returns the created check-in.
  Future<WellbeingCheckin> recordCheckin({
    String? studentId,
    required int moodLevel,
    required int stressLevel,
    String? notes,
    required bool consentToShare,
  }) async {
    _logger.d(
      'Recording check-in: mood=$moodLevel, stress=$stressLevel, '
      'consent=$consentToShare',
    );

    final checkin = WellbeingCheckin(
      id: _uuid.v4(),
      studentId: consentToShare ? studentId : null,
      timestamp: DateTime.now(),
      moodLevel: moodLevel,
      stressLevel: stressLevel,
      notes: notes,
      consentToShare: consentToShare,
    );

    _checkins.add(checkin);
    await _saveCheckinsToStorage();
    _checkinsController.add(List.unmodifiable(_checkins));

    // Automatically purge old data
    await purgeOldData();

    // Recalculate scores and check for alerts
    await _updateScoresAndAlerts();

    _logger.i('Check-in recorded successfully: ${checkin.id}');
    return checkin;
  }

  /// Gets all check-ins for a specific student.
  ///
  /// Only returns check-ins if the student has consented to storage.
  List<WellbeingCheckin> getCheckinsForStudent(String studentId) {
    return _checkins
        .where((c) => c.studentId == studentId && c.consentToShare)
        .toList();
  }

  /// Calculates the current wellbeing score for a student.
  ///
  /// Uses check-ins from the last [alertWindowDays] days.
  Future<WellbeingScore> calculateScoreForStudent(String studentId) async {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(days: alertWindowDays));

    final recentCheckins = _checkins
        .where(
          (c) =>
              c.studentId == studentId &&
              c.timestamp.isAfter(windowStart) &&
              c.consentToShare,
        )
        .toList();

    final score = WellbeingScore.calculate(
      id: _uuid.v4(),
      checkins: recentCheckins,
      periodStart: windowStart,
      periodEnd: now,
    );

    _scoresController.add(score);
    return score;
  }

  /// Anonymizes check-ins for secure transmission.
  ///
  /// Removes all personal identifiers while preserving aggregate data.
  /// Only processes check-ins where the student has consented to share.
  List<WellbeingCheckin> anonymizeCheckinsForTransmission() {
    return _checkins
        .where((c) => c.consentToShare && !c.isAnonymized)
        .map((c) => c.anonymize(anonymousId: _uuid.v4()))
        .toList();
  }

  /// Deletes all data for a specific student (GDPR right to deletion).
  ///
  /// Removes all check-ins and related data from local storage.
  Future<void> deleteStudentData(String studentId) async {
    _logger.w('Deleting all data for student: $studentId');

    final initialCount = _checkins.length;
    _checkins.removeWhere((c) => c.studentId == studentId);
    final deletedCount = initialCount - _checkins.length;

    await _saveCheckinsToStorage();
    _checkinsController.add(List.unmodifiable(_checkins));

    _logger.i('Deleted $deletedCount check-ins for student $studentId');
  }

  /// Deletes all local data (complete reset).
  Future<void> deleteAllData() async {
    _logger.w('Deleting all local data');

    _checkins.clear();
    _alerts.clear();

    await _secureStorage.delete(key: _checkinsStorageKey);
    await _secureStorage.delete(key: _alertsStorageKey);

    _checkinsController.add(List.unmodifiable(_checkins));
    _alertsController.add(List.unmodifiable(_alerts));

    _logger.i('All data deleted successfully');
  }

  /// Gets the current list of active alerts.
  List<AlertCluster> getActiveAlerts() {
    return List.unmodifiable(_alerts);
  }

  /// Sets a new retention period and triggers cleanup of old data.
  ///
  /// [days]: Number of days to retain data.
  /// 
  /// This will immediately purge any data older than the new retention period.
  Future<void> setRetention(int days) async {
    _logger.i('Updating retention period from $_retentionDays to $days days');
    _retentionDays = days;
    await purgeOldData();
  }

  /// Manually triggers purging of data older than the retention period.
  ///
  /// This is called automatically after `recordCheckin` and `setRetention`,
  /// but can be called manually if needed.
  ///
  /// Returns the number of items removed.
  Future<int> purgeOldData() async {
    final cutoffDate = DateTime.now().subtract(Duration(days: _retentionDays));
    final initialCount = _checkins.length;

    _checkins.removeWhere((c) => c.timestamp.isBefore(cutoffDate));
    final removedCount = initialCount - _checkins.length;

    if (removedCount > 0) {
      await _saveCheckinsToStorage();
      _checkinsController.add(List.unmodifiable(_checkins));
      _logger.i('Purged $removedCount old check-ins (older than $cutoffDate)');
    }

    return removedCount;
  }

  /// Anonymizes check-ins and aggregates them for secure batch transmission.
  ///
  /// This method:
  /// - Groups check-ins by day
  /// - Removes all personal identifiers
  /// - Assigns rotating UUIDs (sendId)
  /// - Truncates timestamps to day-level
  /// - Calculates aggregate statistics
  ///
  /// Only processes check-ins where the user has consented to share.
  ///
  /// Returns a list of anonymized check-ins with sample size metadata.
  /// 
  /// TODO: Production: Implement server-side aggregation for additional privacy.
  List<Map<String, dynamic>> anonymizeBatchForSend() {
    final consentedCheckins =
        _checkins.where((c) => c.consentToShare && !c.isAnonymized).toList();

    if (consentedCheckins.isEmpty) {
      _logger.i('No check-ins available for anonymization');
      return [];
    }

    // Group check-ins by day for aggregation
    final Map<String, List<WellbeingCheckin>> checkinsByDay = {};
    for (final checkin in consentedCheckins) {
      final dayKey = DateTime(
        checkin.timestamp.year,
        checkin.timestamp.month,
        checkin.timestamp.day,
      ).toIso8601String();

      checkinsByDay.putIfAbsent(dayKey, () => []).add(checkin);
    }

    // Create anonymized batches
    final batches = <Map<String, dynamic>>[];
    for (final entry in checkinsByDay.entries) {
      final dayCheckins = entry.value;
      final avgMood = dayCheckins.map((c) => c.moodLevel).reduce((a, b) => a + b) /
          dayCheckins.length;
      final avgStress =
          dayCheckins.map((c) => c.stressLevel).reduce((a, b) => a + b) /
              dayCheckins.length;

      batches.add({
        'send_id': _uuid.v4(), // Rotating UUID for this transmission
        'date': entry.key, // Truncated to day-level
        'sample_size': dayCheckins.length,
        'avg_mood': avgMood,
        'avg_stress': avgStress,
        'is_anonymized': true,
        // Note: No student IDs, no exact timestamps, no personal notes
      });
    }

    _logger.i(
      'Anonymized ${consentedCheckins.length} check-ins into ${batches.length} daily batches',
    );

    return batches;
  }

  /// Computes a moving average of wellbeing scores.
  ///
  /// [windowSize]: Number of recent check-ins to include in the average.
  ///               If null, uses the configured `movingAverageWindowSize`.
  ///
  /// Returns a WellbeingScore with the moving average calculation,
  /// or null if insufficient data.
  ///
  /// This provides a smoothed trend analysis that's less sensitive to
  /// single data points.
  WellbeingScore? computeMovingAverage({int? windowSize}) {
    final size = windowSize ?? movingAverageWindowSize;

    if (_checkins.length < 2) {
      _logger.d('Insufficient check-ins for moving average (need at least 2)');
      return null;
    }

    // Sort check-ins by timestamp (most recent first)
    final sortedCheckins = List<WellbeingCheckin>.from(_checkins)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Take the most recent N check-ins
    final recentCheckins = sortedCheckins.take(size).toList();

    if (recentCheckins.isEmpty) {
      return null;
    }

    // Calculate weighted moving average (more recent = higher weight)
    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (int i = 0; i < recentCheckins.length; i++) {
      final weight = (recentCheckins.length - i).toDouble();
      weightedSum += recentCheckins[i].calculateScore() * weight;
      totalWeight += weight;
    }

    final averageScore = totalWeight > 0 ? weightedSum / totalWeight : 0.0;

    // Calculate trend comparing first half vs second half
    double trend = 0.0;
    if (recentCheckins.length >= 2) {
      final midpoint = recentCheckins.length ~/ 2;
      final olderHalf = recentCheckins.sublist(0, midpoint);
      final newerHalf = recentCheckins.sublist(midpoint);

      final olderAvg = olderHalf.isEmpty
          ? 0.0
          : olderHalf.map((c) => c.calculateScore()).reduce((a, b) => a + b) /
              olderHalf.length;
      final newerAvg = newerHalf.isEmpty
          ? 0.0
          : newerHalf.map((c) => c.calculateScore()).reduce((a, b) => a + b) /
              newerHalf.length;

      trend = newerAvg - olderAvg;
    }

    final now = DateTime.now();
    return WellbeingScore(
      id: _uuid.v4(),
      averageScore: averageScore,
      trend: trend,
      periodStart: recentCheckins.last.timestamp,
      periodEnd: recentCheckins.first.timestamp,
      sampleSize: recentCheckins.length,
      checkins: recentCheckins,
    );
  }

  /// Disposes the service and closes streams.
  void dispose() {
    _checkinsController.close();
    _scoresController.close();
    _alertsController.close();
  }

  // Private methods

  static const String _checkinsStorageKey = 'wellbeing_checkins';
  static const String _alertsStorageKey = 'wellbeing_alerts';

  Future<void> _loadCheckinsFromStorage() async {
    try {
      final data = await _secureStorage.read(key: _checkinsStorageKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
        _checkins = jsonList
            .map(
              (json) =>
                  WellbeingCheckin.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (e) {
      _logger.e('Error loading check-ins from storage: $e');
      _checkins = [];
    }
  }

  Future<void> _saveCheckinsToStorage() async {
    try {
      final jsonList = _checkins.map((c) => c.toJson()).toList();
      final data = jsonEncode(jsonList);
      await _secureStorage.write(key: _checkinsStorageKey, value: data);
    } catch (e) {
      _logger.e('Error saving check-ins to storage: $e');
    }
  }

  Future<void> _loadAlertsFromStorage() async {
    try {
      final data = await _secureStorage.read(key: _alertsStorageKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
        _alerts = jsonList
            .map((json) => AlertCluster.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _logger.e('Error loading alerts from storage: $e');
      _alerts = [];
    }
  }

  Future<void> _saveAlertsToStorage() async {
    try {
      final jsonList = _alerts.map((a) => a.toJson()).toList();
      final data = jsonEncode(jsonList);
      await _secureStorage.write(key: _alertsStorageKey, value: data);
    } catch (e) {
      _logger.e('Error saving alerts to storage: $e');
    }
  }

  /// Removes data older than the retention period.
  Future<void> _cleanupOldData() async {
    final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
    final initialCount = _checkins.length;

    _checkins.removeWhere((c) => c.timestamp.isBefore(cutoffDate));

    if (initialCount != _checkins.length) {
      await _saveCheckinsToStorage();
      _logger.i(
        'Cleaned up ${initialCount - _checkins.length} old check-ins',
      );
    }
  }

  /// Updates scores and detects alerts based on recent check-ins.
  ///
  /// Enhanced alert detection includes:
  /// - Sudden drops in wellbeing scores
  /// - Consecutive low mood patterns
  /// - Consecutive high stress patterns
  /// - Moving average trend analysis
  Future<void> _updateScoresAndAlerts() async {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(days: alertWindowDays));

    // Get recent check-ins
    final recentCheckins =
        _checkins.where((c) => c.timestamp.isAfter(windowStart)).toList();

    if (recentCheckins.length < 2) {
      // Not enough data for meaningful analysis
      return;
    }

    // Sort by timestamp
    recentCheckins.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Create anonymous cluster metadata
    final clusterName = 'Cluster-Anonymous';
    final clusterSize = recentCheckins.length;

    // Calculate current aggregate statistics
    final avgStress = recentCheckins
            .map((c) => c.stressLevel.toDouble())
            .reduce((a, b) => a + b) /
        recentCheckins.length;

    final avgMood = recentCheckins
            .map((c) => c.moodLevel.toDouble())
            .reduce((a, b) => a + b) /
        recentCheckins.length;

    final score = WellbeingScore.calculate(
      id: _uuid.v4(),
      checkins: recentCheckins,
      periodStart: windowStart,
      periodEnd: now,
    );

    // Emit score update
    _scoresController.add(score);

    // ALERT DETECTION #1: Sudden drop detection
    // Compare current score with moving average of previous periods
    final movingAvg = computeMovingAverage();
    if (movingAvg != null && score.averageScore < movingAvg.averageScore) {
      final dropPercent =
          ((movingAvg.averageScore - score.averageScore) / movingAvg.averageScore) *
              100;

      if (dropPercent >= alertDropPercentThreshold) {
        _createAlert(
          clusterName: clusterName,
          alertType: AlertType.decliningTrend,
          severity: dropPercent > 30 ? AlertSeverity.high : AlertSeverity.medium,
          description:
              'Sudden drop in wellbeing detected: ${dropPercent.toStringAsFixed(1)}% decline',
          clusterSize: clusterSize,
          percentageChange: -dropPercent,
          metadata: {
            'days_window': alertWindowDays,
            'affected_sample_size': clusterSize,
            'previous_avg': movingAvg.averageScore,
            'current_avg': score.averageScore,
          },
        );
      }
    }

    // ALERT DETECTION #2: Consecutive low mood pattern
    if (recentCheckins.length >= consecutiveLowMoodThreshold) {
      final lastN = recentCheckins
          .skip(recentCheckins.length - consecutiveLowMoodThreshold)
          .toList();
      final allLowMood = lastN.every((c) => c.moodLevel <= 2);

      if (allLowMood) {
        _createAlert(
          clusterName: clusterName,
          alertType: AlertType.lowMood,
          severity: AlertSeverity.high,
          description:
              'Consecutive low mood pattern detected ($consecutiveLowMoodThreshold checks)',
          clusterSize: clusterSize,
          percentageChange: score.trend,
          metadata: {
            'days_window': alertWindowDays,
            'affected_sample_size': clusterSize,
            'consecutive_count': consecutiveLowMoodThreshold,
          },
        );
      }
    }

    // ALERT DETECTION #3: Consecutive high stress pattern
    if (recentCheckins.length >= consecutiveLowMoodThreshold) {
      final lastN = recentCheckins
          .skip(recentCheckins.length - consecutiveLowMoodThreshold)
          .toList();
      final allHighStress = lastN.every((c) => c.stressLevel >= 4);

      if (allHighStress) {
        _createAlert(
          clusterName: clusterName,
          alertType: AlertType.stressIncrease,
          severity: AlertSeverity.high,
          description:
              'Sustained high stress detected ($consecutiveLowMoodThreshold checks)',
          clusterSize: clusterSize,
          percentageChange: score.trend,
          metadata: {
            'days_window': alertWindowDays,
            'affected_sample_size': clusterSize,
            'consecutive_count': consecutiveLowMoodThreshold,
            'avg_stress': avgStress,
          },
        );
      }
    }

    // ALERT DETECTION #4: General concerning patterns (from original implementation)
    if (score.isConcerning() || avgStress >= stressThreshold) {
      _createAlert(
        clusterName: clusterName,
        alertType: avgStress >= stressThreshold
            ? AlertType.stressIncrease
            : AlertType.lowMood,
        severity: score.averageScore < 30 || avgStress > 4.5
            ? AlertSeverity.high
            : AlertSeverity.medium,
        description: avgStress >= stressThreshold
            ? 'Elevated stress levels detected in cluster'
            : 'Low wellbeing scores detected in cluster',
        clusterSize: clusterSize,
        percentageChange: score.trend,
        metadata: {
          'days_window': alertWindowDays,
          'affected_sample_size': clusterSize,
          'avg_mood': avgMood,
          'avg_stress': avgStress,
        },
      );
    }
  }

  /// Helper method to create and store an alert if not duplicate.
  Future<void> _createAlert({
    required String clusterName,
    required AlertType alertType,
    required AlertSeverity severity,
    required String description,
    required int clusterSize,
    double? percentageChange,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();

    // Check for duplicates (same type in last 24 hours)
    final isDuplicate = _alerts.any(
      (a) =>
          a.clusterName == clusterName &&
          a.alertType == alertType &&
          now.difference(a.timestamp).inHours < 24,
    );

    if (isDuplicate) {
      return; // Don't create duplicate alert
    }

    final alert = AlertCluster(
      id: _uuid.v4(),
      clusterName: clusterName,
      alertType: alertType,
      severity: severity,
      description: description,
      timestamp: now,
      clusterSize: clusterSize,
      percentageChange: percentageChange,
      recommendations: _getRecommendations(alertType, severity),
    );

    _alerts.add(alert);
    await _saveAlertsToStorage();
    _alertsController.add(List.unmodifiable(_alerts));
    _logger.w('New alert generated: ${alert.description}');
  }

  /// Gets contextual recommendations based on alert type and severity.
  List<String> _getRecommendations(AlertType type, AlertSeverity severity) {
    final baseRecommendations = [
      'Consider outreach to support student wellbeing',
      'Review recent workload and deadlines',
      'Offer mental health resources and counseling',
      'Monitor situation closely',
    ];

    switch (type) {
      case AlertType.stressIncrease:
        return [
          'Review upcoming deadlines and assessments',
          'Consider stress management workshops',
          'Provide time management resources',
          ...baseRecommendations,
        ];
      case AlertType.lowMood:
        return [
          'Ensure access to counseling services',
          'Check in with students individually',
          'Promote peer support programs',
          ...baseRecommendations,
        ];
      case AlertType.decliningTrend:
        return [
          'Investigate recent changes in environment or workload',
          'Early intervention is key',
          'Connect with academic advisors',
          ...baseRecommendations,
        ];
      case AlertType.generalConcern:
        return baseRecommendations;
    }
  }
}
