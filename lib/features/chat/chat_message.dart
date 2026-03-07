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
}
