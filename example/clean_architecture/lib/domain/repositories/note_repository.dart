import '../entities/note.dart';

/// The abstract boundary representing how the application interacts with [Note] data.
///
/// This interface is part of the Domain layer, meaning it has no knowledge
/// of how notes are actually stored (e.g., in memory, local DB, or network).
abstract interface class NoteRepository {
  /// Saves a new [Note] or updates an existing one.
  Future<void> save(Note note);

  /// Retrieves a list of all available [Note]s.
  Future<List<Note>> getAll();

  /// Retrieves a specific [Note] by its [id], or null if not found.
  Future<Note?> getById(String id);

  /// Deletes a [Note] by its [id].
  Future<void> delete(String id);
}
