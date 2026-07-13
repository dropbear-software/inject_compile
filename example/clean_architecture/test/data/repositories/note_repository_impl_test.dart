import 'package:test/test.dart';
import 'package:clean_architecture/domain/entities/note.dart';
import 'package:clean_architecture/data/repositories/note_repository_impl.dart';
import '../../helpers/fakes.dart';

void main() {
  group('NoteRepositoryImpl', () {
    late FakeNoteDataSource fakeDataSource;
    late NoteRepositoryImpl repository;

    final testNote = Note(
      id: '1',
      title: 'Test',
      content: 'Content',
      createdAt: DateTime.now(),
    );

    setUp(() {
      fakeDataSource = FakeNoteDataSource();
      repository = NoteRepositoryImpl(fakeDataSource);
    });

    test('save delegates to dataSource.insert', () async {
      await repository.save(testNote);
      expect(fakeDataSource.insertCalled, isTrue);
      expect(fakeDataSource.storage['1'], equals(testNote));
    });

    test('getAll delegates to dataSource.fetchAll', () async {
      fakeDataSource.storage['1'] = testNote;
      final notes = await repository.getAll();
      expect(fakeDataSource.fetchAllCalled, isTrue);
      expect(notes, hasLength(1));
      expect(notes.first, equals(testNote));
    });

    test('getById delegates to dataSource.fetchById', () async {
      fakeDataSource.storage['1'] = testNote;
      final note = await repository.getById('1');
      expect(fakeDataSource.fetchByIdCalled, isTrue);
      expect(note, equals(testNote));
    });

    test('delete delegates to dataSource.remove', () async {
      fakeDataSource.storage['1'] = testNote;
      await repository.delete('1');
      expect(fakeDataSource.removeCalled, isTrue);
      expect(fakeDataSource.storage, isEmpty);
    });
  });
}
