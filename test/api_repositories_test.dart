import 'dart:convert';
import 'dart:typed_data';

import 'package:ask_my_docs/core/network/api_client.dart';
import 'package:ask_my_docs/data/models/chat_message_model.dart';
import 'package:ask_my_docs/data/models/document_model.dart';
import 'package:ask_my_docs/data/repositories/chat_repository_impl.dart';
import 'package:ask_my_docs/data/repositories/document_repository_impl.dart';
import 'package:ask_my_docs/data/repositories/repository_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request from [handler] instead of the network.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ApiClient _clientWith(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = adapter;
  return ApiClient(dio: dio);
}

ChatMessageModel _msg(MessageRole role, String content) =>
    ChatMessageModel(role: role, content: content, createdAt: DateTime(2026));

void main() {
  group('ChatRepositoryImpl', () {
    test('posts question + last 6 messages and maps the answer', () async {
      final adapter = _FakeAdapter((_) => _json({
            'answer': 'Within 30 days.',
            'sources': [
              {'document': 'terms.pdf', 'page': 3, 'text': 'Refunds...'},
            ],
          }));
      final repository = ChatRepositoryImpl(_clientWith(adapter));
      final history = [
        for (var i = 0; i < 8; i++)
          _msg(i.isEven ? MessageRole.user : MessageRole.assistant, 'm$i'),
      ];

      final answer = await repository.ask('Refund policy?', history);

      expect(adapter.lastRequest!.path, '/ask');
      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body['question'], 'Refund policy?');
      final sent = body['history'] as List;
      expect(sent, hasLength(6));
      expect(sent.first, {'role': 'user', 'content': 'm2'});
      expect(sent.last, {'role': 'assistant', 'content': 'm7'});

      expect(answer.role, MessageRole.assistant);
      expect(answer.content, 'Within 30 days.');
      expect(answer.sources.single.label, 'terms.pdf · p.3');
    });

    test('server "detail" becomes the error message', () async {
      final adapter = _FakeAdapter(
        (_) => _json({'detail': 'No documents indexed yet'}, 400),
      );
      final repository = ChatRepositoryImpl(_clientWith(adapter));

      await expectLater(
        repository.ask('Hi', const []),
        throwsA(isA<RepositoryException>().having(
          (e) => e.message,
          'message',
          'No documents indexed yet',
        )),
      );
    });

    test('connection failure gives an offline message', () async {
      final adapter = _FakeAdapter(
        (options) => throw DioException.connectionError(
          requestOptions: options,
          reason: 'refused',
        ),
      );
      final repository = ChatRepositoryImpl(_clientWith(adapter));

      await expectLater(
        repository.ask('Hi', const []),
        throwsA(isA<RepositoryException>().having(
          (e) => e.message,
          'message',
          contains("Can't reach the server"),
        )),
      );
    });
  });

  group('DocumentRepositoryImpl', () {
    test('lists documents as indexed', () async {
      final adapter = _FakeAdapter((_) => _json([
            {'name': 'a.pdf', 'pages': 6, 'chunks': 26},
          ]));
      final docs =
          await DocumentRepositoryImpl(_clientWith(adapter)).getDocuments();

      expect(docs.single.name, 'a.pdf');
      expect(docs.single.status, DocumentStatus.indexed);
    });

    test('missing /documents route (404) gives an empty list', () async {
      final adapter = _FakeAdapter((_) => _json({'detail': 'Not Found'}, 404));
      final docs =
          await DocumentRepositoryImpl(_clientWith(adapter)).getDocuments();

      expect(docs, isEmpty);
    });

    test('missing upload route (404) gives a clear message', () async {
      final adapter = _FakeAdapter((_) => _json({'detail': 'Not Found'}, 404));
      final repository = DocumentRepositoryImpl(_clientWith(adapter));

      await expectLater(
        repository.uploadPdf('a.pdf', [1, 2, 3]),
        throwsA(isA<RepositoryException>().having(
          (e) => e.message,
          'message',
          DocumentRepositoryImpl.uploadUnavailable,
        )),
      );
    });

    test('upload sends multipart field "file" and maps the reply', () async {
      final adapter = _FakeAdapter(
        (_) => _json({'name': 'a.pdf', 'pages': 2, 'chunks': 9}),
      );
      final doc = await DocumentRepositoryImpl(_clientWith(adapter))
          .uploadPdf('a.pdf', [1, 2, 3]);

      final form = adapter.lastRequest!.data as FormData;
      expect(form.files.single.key, 'file');
      expect(form.files.single.value.filename, 'a.pdf');
      expect(adapter.lastRequest!.receiveTimeout, const Duration(minutes: 5));
      expect(doc, const DocumentModel(name: 'a.pdf', pages: 2, chunks: 9));
    });

    test('upload 409 shows the server detail', () async {
      final adapter = _FakeAdapter(
        (_) => _json({'detail': 'a.pdf is already uploaded.'}, 409),
      );

      await expectLater(
        DocumentRepositoryImpl(_clientWith(adapter)).uploadPdf('a.pdf', [1]),
        throwsA(isA<RepositoryException>().having(
          (e) => e.message,
          'message',
          'a.pdf is already uploaded.',
        )),
      );
    });

    test('delete calls DELETE with a URL-encoded name', () async {
      final adapter = _FakeAdapter((_) => _json({'deleted': 'my file.pdf'}));

      await DocumentRepositoryImpl(_clientWith(adapter))
          .deleteDocument('my file.pdf');

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(adapter.lastRequest!.path, '/documents/my%20file.pdf');
    });

    test('delete 404 shows "Document not found."', () async {
      final adapter =
          _FakeAdapter((_) => _json({'detail': 'Document not found.'}, 404));

      await expectLater(
        DocumentRepositoryImpl(_clientWith(adapter)).deleteDocument('x.pdf'),
        throwsA(isA<RepositoryException>().having(
          (e) => e.message,
          'message',
          'Document not found.',
        )),
      );
    });

    test('reads the chunk count from /health', () async {
      final adapter =
          _FakeAdapter((_) => _json({'status': 'ok', 'chunks': 426}));
      final chunks =
          await DocumentRepositoryImpl(_clientWith(adapter)).getIndexedChunks();

      expect(adapter.lastRequest!.path, '/health');
      expect(chunks, 426);
    });
  });
}
