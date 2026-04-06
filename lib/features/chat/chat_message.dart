enum ChatRole { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    this.createdAt,
  });

  final ChatRole role;
  final String content;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'content': content,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: ChatRole.values.byName(json['role'] as String? ?? 'user'),
        content: json['content'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}
