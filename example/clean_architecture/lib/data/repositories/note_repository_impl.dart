import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_data_source.dart';

/// The concrete implementation of the Domain layer's [NoteRepository].
///
/// This class acts as an adapter, translating domain operations into
/// [NoteDataSource] calls.
final class NoteRepositoryImpl implements NoteRepository {
  final NoteDataSource _dataSource;

  /// Creates a [NoteRepositoryImpl] relying on the provided [_dataSource].
  const NoteRepositoryImpl(this._dataSource);

  @override
  Future<void> save(Note note) async {
    await _dataSource.insert(note);
  }

  @override
  Future<List<Note>> getAll() async {
    return await _dataSource.fetchAll();
  }

  @override
  Future<Note?> getById(String id) async {
    return await _dataSource.fetchById(id);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.remove(id);
  }
}
