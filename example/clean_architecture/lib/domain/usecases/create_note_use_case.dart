import 'package:inject_compile/inject_compile.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// A use case responsible for creating and saving new notes.
@provide
final class CreateNoteUseCase {
  final NoteRepository _repository;

  /// Creates a [CreateNoteUseCase] with the required [NoteRepository].
  const CreateNoteUseCase(this._repository);

  /// Executes the use case to create a new note with the given [title] and [content].
  ///
  /// Returns the newly created [Note].
  Future<Note> execute({required String title, required String content}) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // Simple ID generation
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    await _repository.save(note);
    return note;
  }
}
