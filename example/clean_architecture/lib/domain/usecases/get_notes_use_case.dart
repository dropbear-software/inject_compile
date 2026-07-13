import 'package:inject_compile/inject.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// A use case responsible for fetching all available notes.
@provide
final class GetNotesUseCase {
  final NoteRepository _repository;

  /// Creates a [GetNotesUseCase] with the required [NoteRepository].
  const GetNotesUseCase(this._repository);

  /// Executes the use case to retrieve all notes.
  ///
  /// Returns a list of [Note]s.
  Future<List<Note>> execute() async {
    return await _repository.getAll();
  }
}
