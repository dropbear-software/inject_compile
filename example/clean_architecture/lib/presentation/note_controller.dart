import 'package:inject_compile/inject.dart';
import '../domain/usecases/create_note_use_case.dart';
import '../domain/usecases/get_notes_use_case.dart';

/// A presentation controller responsible for coordinating between the UI and Domain Use Cases.
@provide
final class NoteController {
  final CreateNoteUseCase _createNoteUseCase;
  final GetNotesUseCase _getNotesUseCase;

  /// Creates a [NoteController] injected with the required Use Cases.
  const NoteController(this._createNoteUseCase, this._getNotesUseCase);

  /// Triggers the creation of a new note using the [CreateNoteUseCase].
  Future<void> addNote(String title, String content) async {
    print('Creating note: $title');
    final note = await _createNoteUseCase.execute(
      title: title,
      content: content,
    );
    print('Note created successfully: ${note.id}');
  }

  /// Fetches and displays all available notes using the [GetNotesUseCase].
  Future<void> listNotes() async {
    print('Fetching all notes...');
    final notes = await _getNotesUseCase.execute();
    if (notes.isEmpty) {
      print('No notes found.');
      return;
    }
    for (final note in notes) {
      print(' - [${note.id}] ${note.title}: ${note.content}');
    }
  }
}
