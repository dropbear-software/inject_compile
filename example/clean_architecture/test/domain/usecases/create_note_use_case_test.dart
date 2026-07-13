import 'package:test/test.dart';
import 'package:clean_architecture/domain/usecases/create_note_use_case.dart';
import '../../helpers/fakes.dart';

void main() {
  group('CreateNoteUseCase', () {
    late FakeNoteRepository fakeRepository;
    late CreateNoteUseCase useCase;

    setUp(() {
      fakeRepository = FakeNoteRepository();
      useCase = CreateNoteUseCase(fakeRepository);
    });

    test('should create and save a new note', () async {
      final note = await useCase.execute(
        title: 'Test Title',
        content: 'Test Content',
      );

      expect(note.title, equals('Test Title'));
      expect(note.content, equals('Test Content'));
      expect(note.id, isNotEmpty);

      expect(fakeRepository.lastSavedNote, equals(note));
      expect(fakeRepository.notes, contains(note));
    });
  });
}
