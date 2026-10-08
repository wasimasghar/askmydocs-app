import 'package:equatable/equatable.dart';

import 'source_model.dart';

/// Who wrote a message.
enum MessageRole { user, assistant }

/// One message in the conversation. Assistant messages may carry [sources].
class ChatMessageModel extends Equatable {
  const ChatMessageModel({
    required this.role,
    required this.content,
    required this.createdAt,
    this.sources = const [],
  });

  /// Convenience constructor for a message the user just typed.
  factory ChatMessageModel.user(String content) => ChatMessageModel(
        role: MessageRole.user,
        content: content,
        createdAt: DateTime.now(),
      );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role: MessageRole.values.asNameMap()[json['role']] ??
          MessageRole.assistant,
      content: json['content'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>? ?? const [])
          .map((e) => SourceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  final MessageRole role;
  final String content;
  final List<SourceModel> sources;
  final DateTime createdAt;

  bool get isUser => role == MessageRole.user;

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'content': content,
        'sources': sources.map((s) => s.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [role, content, sources, createdAt];
}
