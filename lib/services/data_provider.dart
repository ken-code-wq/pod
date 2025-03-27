import '../models/chat_model.dart';
import '../models/document_model.dart';

class DataProvider {
  // Singleton pattern
  static final DataProvider _instance = DataProvider._internal();
  factory DataProvider() => _instance;
  DataProvider._internal();

  // Generate sample documents
  List<Document> getSampleDocuments() {
    return [
      Document.dummy(
        id: 'doc1',
        title: 'Meeting with Marketing Team',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        accessCount: 5,
      ),
      Document.dummy(
        id: 'doc2',
        title: 'Product Roadmap Discussion',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        lastAccessedAt: DateTime.now().subtract(const Duration(hours: 5)),
        accessCount: 8,
      ),
      Document.dummy(
        id: 'doc3',
        title: 'Interview with CEO',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastAccessedAt: DateTime.now().subtract(const Duration(hours: 1)),
        accessCount: 12,
      ),
      Document.dummy(
        id: 'doc4',
        title: 'Quarterly Results Analysis',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        accessCount: 3,
      ),
      Document.dummy(
        id: 'doc5',
        title: 'Team Brainstorming Session',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        accessCount: 1,
      ),
    ];
  }

  // Generate sample chats
  List<Chat> getSampleChats() {
    return [
      Chat.dummy(
        id: 'chat1',
        title: 'Marketing Strategy Analysis',
        documentIds: ['doc1', 'doc3'],
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        accessCount: 4,
      ),
      Chat.dummy(
        id: 'chat2',
        title: 'Product Development Insights',
        documentIds: ['doc2'],
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        lastAccessedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        accessCount: 7,
      ),
      Chat.dummy(
        id: 'chat3',
        title: 'Financial Performance Review',
        documentIds: ['doc4'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        accessCount: 2,
      ),
    ];
  }

  // Get recent documents (sorted by creation date)
  List<Document> getRecentDocuments({int limit = 3}) {
    final docs = getSampleDocuments();
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return docs.take(limit).toList();
  }

  // Get most accessed documents
  List<Document> getMostAccessedDocuments({int limit = 3}) {
    final docs = getSampleDocuments();
    docs.sort((a, b) => b.accessCount.compareTo(a.accessCount));
    return docs.take(limit).toList();
  }

  // Get recent chats
  List<Chat> getRecentChats({int limit = 3}) {
    final chats = getSampleChats();
    chats.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chats.take(limit).toList();
  }

  // Get most accessed chats
  List<Chat> getMostAccessedChats({int limit = 3}) {
    final chats = getSampleChats();
    chats.sort((a, b) => b.accessCount.compareTo(a.accessCount));
    return chats.take(limit).toList();
  }
}
