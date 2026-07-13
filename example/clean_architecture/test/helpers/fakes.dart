import 'package:clean_architecture/domain/entities/note.dart';
import 'package:clean_architecture/domain/repositories/note_repository.dart';
import 'package:clean_architecture/data/datasources/note_data_source.dart';

class FakeNoteRepository implements NoteRepository {
  final List<Note> notes = [];
  Note? lastSavedNote;
  String? lastDeletedId;

  @override
  Future<void> save(Note note) async {
    lastSavedNote = note;
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
  }

  @override
  Future<List<Note>> getAll() async => notes;

  @override
  Future<Note?> getById(String id) async {
    try {
      return notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String id) async {
    lastDeletedId = id;
    notes.removeWhere((n) => n.id == id);
  }
}

class FakeNoteDataSource implements NoteDataSource {
  final Map<String, Note> storage = {};
  bool insertCalled = false;
  bool fetchAllCalled = false;
  bool fetchByIdCalled = false;
  bool removeCalled = false;

  @override
  Future<void> insert(Note note) async {
    insertCalled = true;
    storage[note.id] = note;
  }

  @override
  Future<List<Note>> fetchAll() async {
    fetchAllCalled = true;
    return storage.values.toList();
  }

  @override
  Future<Note?> fetchById(String id) async {
    fetchByIdCalled = true;
    return storage[id];
  }

  @override
  Future<void> remove(String id) async {
    removeCalled = true;
    storage.remove(id);
  }
}
