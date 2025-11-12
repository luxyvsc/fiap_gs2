import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart';
import '../models/review_models.dart';
import '../services/content_review_service.dart';
import '../widgets/review_issue_card.dart';
import '../widgets/review_summary_card.dart';

enum ContentInputType { text, html, markdown, file }

final reviewServiceProvider = Provider<ContentReviewService>((ref) {
  return ContentReviewService();
});

class ContentReviewScreen extends ConsumerStatefulWidget {
  const ContentReviewScreen({super.key});

  @override
  ConsumerState<ContentReviewScreen> createState() =>
      _ContentReviewScreenState();
}

class _ContentReviewScreenState extends ConsumerState<ContentReviewScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController(
    text: 'http://localhost:8000',
  );

  ReviewType _selectedReviewType = ReviewType.fullReview;
  ContentInputType _selectedInputType = ContentInputType.text;
  ReviewResult? _reviewResult;
  bool _isReviewing = false;
  String? _errorMessage;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    // Set sample content for demonstration
    _titleController.text = 'Introduction to Python Programming';
    _contentController.text = '''
I recieve many questions about Python 2.7 programming. Research shows that 
utilize Python is the most popular language from 2010. According to statistics, 
jQuery is still widely used for web development.

The code was written by developers and was tested thoroughly. We must facilitate 
the implementation of this methodology to achieve better results. This is a 
extremely long sentence that goes on and on and contains way too many words 
for easy comprehension and should really be broken up into multiple smaller 
sentences for better readability.
''';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _performReview() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both title and content';
      });
      return;
    }

    setState(() {
      _isReviewing = true;
      _errorMessage = null;
      _reviewResult = null;
    });

    try {
      final service = ContentReviewService(baseUrl: _apiUrlController.text);
      final result = await service.reviewContent(
        title: _titleController.text,
        text: _contentController.text,
        reviewType: _selectedReviewType,
      );

      setState(() {
        _reviewResult = result;
        _isReviewing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isReviewing = false;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'html', 'md', 'htm', 'markdown'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final content = String.fromCharCodes(file.bytes!);
          setState(() {
            _contentController.text = content;
            _selectedFileName = file.name;

            // Auto-detect content type based on file extension
            if (file.extension == 'html' || file.extension == 'htm') {
              _selectedInputType = ContentInputType.html;
            } else if (file.extension == 'md' || file.extension == 'markdown') {
              _selectedInputType = ContentInputType.markdown;
            } else {
              _selectedInputType = ContentInputType.text;
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading file: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Reviewer Agent'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // Left panel - Input
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Content to Review',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // API URL
                    TextField(
                      controller: _apiUrlController,
                      decoration: const InputDecoration(
                        labelText: 'API Base URL',
                        hintText: 'http://localhost:8000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input type selector
                    DropdownButtonFormField<ContentInputType>(
                      initialValue: _selectedInputType,
                      decoration: const InputDecoration(
                        labelText: 'Content Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.text_format),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ContentInputType.text,
                          child: Text('Plain Text'),
                        ),
                        DropdownMenuItem(
                          value: ContentInputType.html,
                          child: Text('HTML'),
                        ),
                        DropdownMenuItem(
                          value: ContentInputType.markdown,
                          child: Text('Markdown'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedInputType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // File picker button
                    OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.file_upload),
                      label: Text(
                        _selectedFileName ??
                            'Load from File (.txt, .html, .md)',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content preview/editor
                    if (_selectedInputType == ContentInputType.html) ...[
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(8),
                          child: Html(
                            data: _contentController.text.isEmpty
                                ? '<p>HTML preview will appear here...</p>'
                                : _contentController.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'HTML Source:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                    ] else if (_selectedInputType ==
                        ContentInputType.markdown) ...[
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Markdown(
                          data: _contentController.text.isEmpty
                              ? 'Markdown preview will appear here...'
                              : _contentController.text,
                          shrinkWrap: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Markdown Source:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Content
                    TextField(
                      controller: _contentController,
                      maxLines:
                          _selectedInputType == ContentInputType.text ? 15 : 10,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                        helperText: _selectedInputType == ContentInputType.text
                            ? 'Enter plain text content'
                            : _selectedInputType == ContentInputType.html
                                ? 'Enter HTML code'
                                : 'Enter Markdown text',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Review type selector
                    DropdownButtonFormField<ReviewType>(
                      initialValue: _selectedReviewType,
                      decoration: const InputDecoration(
                        labelText: 'Review Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ReviewType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_formatReviewType(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedReviewType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Review button
                    ElevatedButton.icon(
                      onPressed: _isReviewing ? null : _performReview,
                      icon: _isReviewing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.rate_review),
                      label: Text(
                        _isReviewing ? 'Reviewing...' : 'Review Content',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SelectableText(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Right panel - Results
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: _reviewResult == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assessment,
                            size: 100,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Review results will appear here',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReviewSummaryCard(result: _reviewResult!),
                          const SizedBox(height: 16),
                          Text(
                            'Issues Found (${_reviewResult!.issues.length})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          if (_reviewResult!.issues.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'No issues found! Content looks great!',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._reviewResult!.issues.map(
                              (issue) => ReviewIssueCard(issue: issue),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatReviewType(ReviewType type) {
    switch (type) {
      case ReviewType.fullReview:
        return 'Full Review';
      case ReviewType.errorDetection:
        return 'Error Detection';
      case ReviewType.comprehension:
        return 'Comprehension';
      case ReviewType.sourceVerification:
        return 'Source Verification';
      case ReviewType.contentUpdate:
        return 'Content Update';
    }
  }
}
