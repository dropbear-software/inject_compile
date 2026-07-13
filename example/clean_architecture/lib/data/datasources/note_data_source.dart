import '../../domain/entities/note.dart';

/// The low-level interface for accessing and mutating note data.
///
/// This interface abstracts away the specific storage mechanism
/// (e.g., SQLite, Firebase, SharedPreferences) from the rest of the application.
abstract interface class NoteDataSource {
  /// Inserts a new [note] into the data source.
  Future<void> insert(Note note);

  /// Fetches all stored [Note]s from the data source.
  Future<List<Note>> fetchAll();

  /// Fetches a specific [Note] by its [id].
  Future<Note?> fetchById(String id);

  /// Removes a [Note] matching the given [id] from the data source.
  Future<void> remove(String id);
}

/// A simple, in-memory implementation of [NoteDataSource] for demonstration purposes.
final class InMemoryNoteDataSource implements NoteDataSource {
  final Map<String, Note> _storage = {};

  @override
  Future<void> insert(Note note) async {
    _storage[note.id] = note;
  }

  @override
  Future<List<Note>> fetchAll() async {
    return _storage.values.toList();
  }

  @override
  Future<Note?> fetchById(String id) async {
    return _storage[id];
  }

  @override
  Future<void> remove(String id) async {
    _storage.remove(id);
  }
}
