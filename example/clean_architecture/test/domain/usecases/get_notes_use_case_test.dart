import 'package:test/test.dart';
import 'package:clean_architecture/domain/entities/note.dart';
import 'package:clean_architecture/domain/usecases/get_notes_use_case.dart';
import '../../helpers/fakes.dart';

void main() {
  group('GetNotesUseCase', () {
    late FakeNoteRepository fakeRepository;
    late GetNotesUseCase useCase;

    setUp(() {
      fakeRepository = FakeNoteRepository();
      useCase = GetNotesUseCase(fakeRepository);
    });

    test('should return empty list when no notes exist', () async {
      final notes = await useCase.execute();
      expect(notes, isEmpty);
    });

    test('should return all notes from repository', () async {
      final testNote = Note(
        id: '1',
        title: 'Title',
        content: 'Content',
        createdAt: DateTime.now(),
      );
      fakeRepository.notes.add(testNote);

      final notes = await useCase.execute();

      expect(notes, hasLength(1));
      expect(notes.first, equals(testNote));
    });
  });
}
