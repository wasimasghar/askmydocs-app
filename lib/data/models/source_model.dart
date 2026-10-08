import 'package:equatable/equatable.dart';

/// A passage from an uploaded PDF that an answer was based on.
class SourceModel extends Equatable {
  const SourceModel({
    required this.document,
    required this.page,
    required this.text,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      document: json['document'] as String? ?? '',
      page: (json['page'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
    );
  }

  /// File name of the PDF, e.g. "terms_of_service.pdf".
  final String document;

  /// 1-based page number inside the PDF.
  final int page;

  /// The retrieved passage.
  final String text;

  /// Short chip label, e.g. "my_file.pdf · p.3".
  String get label => '$document · p.$page';

  Map<String, dynamic> toJson() => {
        'document': document,
        'page': page,
        'text': text,
      };

  @override
  List<Object?> get props => [document, page, text];
}
