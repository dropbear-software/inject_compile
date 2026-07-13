/// The core entity representing a single note in the application.
final class Note {
  /// The unique identifier for the note.
  final String id;

  /// The title of the note.
  final String title;

  /// The body content of the note.
  final String content;

  /// The timestamp of when the note was created.
  final DateTime createdAt;

  /// Creates a new [Note] instance.
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'Note(id: $id, title: $title, content: $content, createdAt: $createdAt)';
  }

  /// Creates a copy of this [Note] with the given fields replaced by the new values.
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, content, createdAt);
  }
}
