import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:content_review_example/services/content_review_service.dart';
import 'package:content_review_example/models/review_models.dart';

void main() {
  late ContentReviewService service;
  late Dio dio;

  setUp(() {
    // Create a Dio instance with a custom adapter for testing
    dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8000',
      validateStatus: (status) => status! < 500,
    ));
    service = ContentReviewService(
      baseUrl: 'http://localhost:8000',
      dio: dio,
    );
  });

  group('ContentReviewService API Tests', () {
    test('reviewContent sends correct request format', () async {
      // This test requires the API to be running
      // Skip if API is not available
      try {
        final result = await service.reviewContent(
          title: 'Test Content',
          text: 'I recieve emails regularly.',
          reviewType: ReviewType.fullReview,
        );

        expect(result, isA<ReviewResult>());
        expect(result.status, 'completed');
        expect(result.issues, isNotEmpty);
      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.connectionError) {
          // Skip test if API is not running
          printOnFailure('API not available, skipping test');
        } else {
          rethrow;
        }
      }
    });

    test('reviewErrors sends correct request', () async {
      try {
        final result = await service.reviewErrors(
          title: 'Test',
          text: 'I recieve emails.',
        );

        expect(result, isA<ReviewResult>());
        expect(result.reviewType, ReviewType.errorDetection);
      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.connectionError) {
          printOnFailure('API not available, skipping test');
        } else {
          rethrow;
        }
      }
    });

    test('reviewComprehension sends correct request', () async {
      try {
        final result = await service.reviewComprehension(
          title: 'Test',
          text: 'We must utilize this methodology.',
        );

        expect(result, isA<ReviewResult>());
        expect(result.reviewType, ReviewType.comprehension);
      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.connectionError) {
          printOnFailure('API not available, skipping test');
        } else {
          rethrow;
        }
      }
    });

    test('reviewSources sends correct request', () async {
      try {
        final result = await service.reviewSources(
          title: 'Test',
          text: 'Research shows that statistics indicate results.',
        );

        expect(result, isA<ReviewResult>());
        expect(result.reviewType, ReviewType.sourceVerification);
      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.connectionError) {
          printOnFailure('API not available, skipping test');
        } else {
          rethrow;
        }
      }
    });

    test('reviewUpdates sends correct request', () async {
      try {
        final result = await service.reviewUpdates(
          title: 'Test',
          text: 'Use Python 2.7 for this project.',
        );

        expect(result, isA<ReviewResult>());
        expect(result.reviewType, ReviewType.contentUpdate);
      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.connectionError) {
          printOnFailure('API not available, skipping test');
        } else {
          rethrow;
        }
      }
    });

    test('getAgents returns agent information', () async {
      try {
        final agents = await service.getAgents();

        expect(agents, isNotEmpty);
        expect(agents.first.name, isNotEmpty);
        expect(agents.first.description, isNotEmpty);
      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.connectionError) {
          printOnFailure('API not available, skipping test');
        } else {
          rethrow;
        }
      }
    });
  });

  group('Request Format Tests', () {
    test('_toSnakeCase converts correctly', () {
      // Test the conversion logic
      final testCases = {
        'fullReview': 'full_review',
        'errorDetection': 'error_detection',
        'comprehension': 'comprehension',
        'sourceVerification': 'source_verification',
        'contentUpdate': 'content_update',
      };

      testCases.forEach((input, expected) {
        final result = _toSnakeCase(input);
        expect(result, expected, reason: 'Failed for input: $input');
      });
    });
  });
}

// Helper function to test snake case conversion
String _toSnakeCase(String str) {
  final result = str.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (match) => '_${match.group(0)!.toLowerCase()}',
  );
  // Remove leading underscore only if string starts with it
  return result.startsWith('_') ? result.substring(1) : result;
}
