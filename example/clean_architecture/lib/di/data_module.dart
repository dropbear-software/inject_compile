import 'package:inject_compile/inject.dart';
import '../domain/repositories/note_repository.dart';
import '../data/repositories/note_repository_impl.dart';
import '../data/datasources/note_data_source.dart';

/// A Dependency Injection module responsible for providing Data Layer dependencies.
@module
final class DataModule {
  /// Provides the [NoteDataSource] implementation as a singleton.
  @provide
  @singleton
  NoteDataSource provideNoteDataSource() {
    return InMemoryNoteDataSource();
  }

  /// Binds the abstract [NoteRepository] to the concrete [NoteRepositoryImpl].
  ///
  /// This is where Dependency Inversion happens! The framework resolves a
  /// request for the domain interface by returning the data implementation.
  @provide
  NoteRepository provideNoteRepository(NoteDataSource dataSource) {
    return NoteRepositoryImpl(dataSource);
  }
}
