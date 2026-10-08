import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/document_repository.dart';
import 'data/repositories/document_repository_impl.dart';
import 'features/dashboard/bloc/chat_bloc.dart';
import 'features/settings/bloc/documents_bloc.dart';

/// Entry point for AskMyDocs.
/// Repositories are provided by their abstract type. To work without a
/// backend, swap in the mocks (one line each):
///   `create: (_) => MockChatRepository()`
///   `create: (_) => MockDocumentRepository()`
/// from `data/repositories/mock_*_repository.dart`.
void main() {
  final apiClient = ApiClient();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ChatRepository>(
          create: (_) => ChatRepositoryImpl(apiClient),
        ),
        RepositoryProvider<DocumentRepository>(
          create: (_) => DocumentRepositoryImpl(apiClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ChatBloc(
              chatRepository: context.read<ChatRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => DocumentsBloc(
              documentRepository: context.read<DocumentRepository>(),
            ),
          ),
        ],
        child: const AskMyDocsApp(),
      ),
    ),
  );
}
