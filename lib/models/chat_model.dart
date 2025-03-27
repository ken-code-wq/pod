// Document model is referenced via IDs only, no need to import

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.id, required this.content, required this.isUser, required this.timestamp});
}

class Chat {
  final String id;
  final String title;
  final List<String> documentIds; // IDs of documents this chat references
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  final int accessCount;

  Chat({required this.id, required this.title, required this.documentIds, required this.messages, required this.createdAt, required this.lastAccessedAt, this.accessCount = 0});

  // Factory constructor for creating dummy data
  factory Chat.dummy({required String id, required String title, required List<String> documentIds, required DateTime createdAt, DateTime? lastAccessedAt, int accessCount = 0}) {
    return Chat(
      id: id,
      title: title,
      documentIds: documentIds,
      messages: [
        ChatMessage(id: '1', content: 'Tell me about this recording', isUser: true, timestamp: createdAt),
        ChatMessage(id: '2', content: 'This recording discusses the main points about...', isUser: false, timestamp: createdAt.add(const Duration(minutes: 1))),
      ],
      createdAt: createdAt,
      lastAccessedAt: lastAccessedAt ?? createdAt,
      accessCount: accessCount,
    );
  }
}
