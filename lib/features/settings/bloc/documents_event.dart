part of 'documents_bloc.dart';

/// Base class for everything the Settings UI can ask the [DocumentsBloc] to do.
sealed class DocumentsEvent extends Equatable {
  const DocumentsEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the document list and chunk count.
final class DocumentsRequested extends DocumentsEvent {
  const DocumentsRequested();
}

/// Upload a picked PDF.
final class DocumentUploadRequested extends DocumentsEvent {
  const DocumentUploadRequested({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;

  // Only the length of the bytes is compared: comparing megabytes is wasteful.
  @override
  List<Object?> get props => [fileName, bytes.length];
}

/// Delete an uploaded PDF (after the user confirmed).
final class DocumentDeleteRequested extends DocumentsEvent {
  const DocumentDeleteRequested(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}
