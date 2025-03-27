class Document {
  final String id;
  final String title;
  final String transcription;
  final String audioPath;
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  final int accessCount;

  Document({required this.id, required this.title, required this.transcription, required this.audioPath, required this.createdAt, required this.lastAccessedAt, this.accessCount = 0});

  // Factory constructor for creating dummy data
  factory Document.dummy({required String id, required String title, required DateTime createdAt, DateTime? lastAccessedAt, int accessCount = 0}) {
    return Document(id: id, title: title, transcription: 'This is a sample transcription for $title...', audioPath: '/path/to/audio/$id.mp3', createdAt: createdAt, lastAccessedAt: lastAccessedAt ?? createdAt, accessCount: accessCount);
  }
}
