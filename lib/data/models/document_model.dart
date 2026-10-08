import 'package:equatable/equatable.dart';

/// Processing state of an uploaded PDF.
enum DocumentStatus { indexed, processing, failed }

/// A PDF in the knowledge base.
class DocumentModel extends Equatable {
  const DocumentModel({
    required this.name,
    required this.pages,
    required this.chunks,
    this.status = DocumentStatus.indexed,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      name: json['name'] as String? ?? '',
      pages: (json['pages'] as num?)?.toInt() ?? 0,
      chunks: (json['chunks'] as num?)?.toInt() ?? 0,
      status: DocumentStatus.values.asNameMap()[json['status']] ??
          DocumentStatus.processing,
    );
  }

  /// File name, e.g. "terms_of_service.pdf".
  final String name;
  final int pages;

  /// Number of text chunks stored in the vector index.
  final int chunks;
  final DocumentStatus status;

  Map<String, dynamic> toJson() => {
        'name': name,
        'pages': pages,
        'chunks': chunks,
        'status': status.name,
      };

  @override
  List<Object?> get props => [name, pages, chunks, status];
}
