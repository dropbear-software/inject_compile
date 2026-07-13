import 'package:test/test.dart';
import 'package:clean_architecture/domain/entities/note.dart';
import 'package:clean_architecture/domain/usecases/create_note_use_case.dart';
import 'package:clean_architecture/domain/usecases/get_notes_use_case.dart';
import 'package:clean_architecture/presentation/note_controller.dart';
import '../helpers/fakes.dart';

void main() {
  group('NoteController', () {
    late FakeNoteRepository fakeRepository;
    late CreateNoteUseCase createUseCase;
    late GetNotesUseCase getUseCase;
    late NoteController controller;

    setUp(() {
      // In a real app we might mock the UseCases themselves,
      // but for this simple example we can use real UseCases with a FakeRepository.
      fakeRepository = FakeNoteRepository();
      createUseCase = CreateNoteUseCase(fakeRepository);
      getUseCase = GetNotesUseCase(fakeRepository);
      controller = NoteController(createUseCase, getUseCase);
    });

    test('addNote executes create use case', () async {
      await controller.addNote('Title', 'Content');

      expect(fakeRepository.notes, hasLength(1));
      expect(fakeRepository.notes.first.title, equals('Title'));
    });

    test('listNotes executes get use case (no notes)', () async {
      // Should not throw, and should handle empty list
      await controller.listNotes();
    });

    test('listNotes executes get use case (with notes)', () async {
      fakeRepository.notes.add(
        Note(id: '1', title: 'T', content: 'C', createdAt: DateTime.now()),
      );

      // Should not throw, should handle listing notes
      await controller.listNotes();
    });
  });
}
