import 'package:test/test.dart';
import 'package:clean_architecture/domain/entities/note.dart';
import 'package:clean_architecture/data/datasources/note_data_source.dart';

void main() {
  group('InMemoryNoteDataSource', () {
    late InMemoryNoteDataSource dataSource;

    final testNote = Note(
      id: '1',
      title: 'Test',
      content: 'Content',
      createdAt: DateTime.now(),
    );

    setUp(() {
      dataSource = InMemoryNoteDataSource();
    });

    test('should store and fetch a note by id', () async {
      await dataSource.insert(testNote);

      final fetchedNote = await dataSource.fetchById('1');
      expect(fetchedNote, isNotNull);
      expect(fetchedNote, equals(testNote));
    });

    test('should fetch all notes', () async {
      await dataSource.insert(testNote);
      await dataSource.insert(
        Note(
          id: '2',
          title: 'Test 2',
          content: 'Content 2',
          createdAt: DateTime.now(),
        ),
      );

      final allNotes = await dataSource.fetchAll();
      expect(allNotes, hasLength(2));
    });

    test('should remove a note', () async {
      await dataSource.insert(testNote);
      await dataSource.remove('1');

      final fetchedNote = await dataSource.fetchById('1');
      expect(fetchedNote, isNull);
    });
  });
}
