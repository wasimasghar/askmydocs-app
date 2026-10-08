import 'dart:math';

import '../models/chat_message_model.dart';
import '../models/source_model.dart';
import 'chat_repository.dart';
import 'repository_exception.dart';

/// Fake [ChatRepository] for UI development.
///
/// Replies after 1–2 seconds with canned answers picked by keyword.
/// Fails about 1 in 7 calls, and always when the question contains "error",
/// so error states are easy to test.
class MockChatRepository implements ChatRepository {
  MockChatRepository({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const double _failureRate = 0.15;

  @override
  Future<ChatMessageModel> ask(
    String question,
    List<ChatMessageModel> history,
  ) async {
    await Future<void>.delayed(
      Duration(milliseconds: 1000 + _random.nextInt(1000)),
    );

    final lower = question.toLowerCase();
    if (lower.contains('error') || _random.nextDouble() < _failureRate) {
      throw const RepositoryException(
        'The server took too long to answer. Please try again.',
      );
    }

    final (content, sources) = _answerFor(lower);
    return ChatMessageModel(
      role: MessageRole.assistant,
      content: content,
      sources: sources,
      createdAt: DateTime.now(),
    );
  }

  (String, List<SourceModel>) _answerFor(String question) {
    if (question.contains('refund') || question.contains('return')) {
      return (_refundAnswer, _refundSources);
    }
    if (question.contains('deadline') || question.contains('date')) {
      return (_deadlineAnswer, _deadlineSources);
    }
    if (question.contains('summar') || question.contains('key point')) {
      return (_summaryAnswer, _summarySources);
    }
    return (_fallbackAnswer, _fallbackSources);
  }

  static const _refundAnswer =
      'Customers can request a full refund within 30 days of purchase, as '
      'long as the product is unused and in its original packaging. After '
      '30 days only store credit is offered, and digital products are '
      'non-refundable once downloaded.';

  static const _refundSources = [
    SourceModel(
      document: 'terms_of_service.pdf',
      page: 3,
      text: '4.1 Refunds. A customer may request a full refund within thirty '
          '(30) days of the original purchase date, provided that the product '
          'is unused and returned in its original packaging. Requests '
          'received after this period are eligible for store credit only.',
    ),
    SourceModel(
      document: 'terms_of_service.pdf',
      page: 4,
      text: '4.3 Digital goods. Licences, downloads and other digital '
          'products are non-refundable once the download has started, '
          'except where required by applicable law.',
    ),
  ];

  static const _deadlineAnswer =
      'There are three deadlines in your documents:\n'
      '• Q3 report sign-off — 15 October\n'
      '• Contract renewal notice — 30 days before 1 January\n'
      '• Refund requests — within 30 days of purchase';

  static const _deadlineSources = [
    SourceModel(
      document: 'q3_financial_report.pdf',
      page: 2,
      text: 'The final Q3 figures must be reviewed and signed off by the '
          'finance committee no later than 15 October.',
    ),
    SourceModel(
      document: 'customer_handbook.pdf',
      page: 7,
      text: 'Either party may terminate this agreement by giving written '
          'notice at least thirty (30) days before the renewal date of '
          '1 January.',
    ),
  ];

  static const _summaryAnswer =
      'Key points: the agreement renews every year on 1 January, either '
      'side can cancel with 30 days\' notice, refunds are available for 30 '
      'days, and support responds within two business days.';

  static const _summarySources = [
    SourceModel(
      document: 'customer_handbook.pdf',
      page: 1,
      text: 'This handbook explains renewal terms, cancellation, refunds and '
          'how to reach our support team.',
    ),
    SourceModel(
      document: 'customer_handbook.pdf',
      page: 12,
      text: 'Our team responds within two (2) business days and will provide '
          'a prepaid shipping label for returns.',
    ),
  ];

  static const _fallbackAnswer =
      'I found a related section in your documents. Support can be reached '
      'at support@example.com, and requests are answered within two '
      'business days. Ask a more specific question for a precise answer.';

  static const _fallbackSources = [
    SourceModel(
      document: 'customer_handbook.pdf',
      page: 12,
      text: 'To begin a return, contact support@example.com and include your '
          'order number. Our team responds within two (2) business days.',
    ),
  ];
}
