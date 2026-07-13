import 'dart:io';
import 'package:inject_compile/inject_compile.dart';
import 'note_controller.dart';

/// The command-line interface view for interacting with notes.
@provide
final class CliView {
  final NoteController _controller;

  /// Creates a [CliView] that delegates user actions to the injected [_controller].
  const CliView(this._controller);

  /// Starts the REPL (Read-Eval-Print Loop) to accept user commands.
  Future<void> start() async {
    print('=== Clean Notes CLI ===');
    print('Available commands: add, list, quit');

    while (true) {
      stdout.write('> ');
      final input = stdin.readLineSync()?.trim();
      if (input == null || input == 'quit' || input == 'q') {
        print('Goodbye!');
        break;
      }

      switch (input.split(' ')) {
        case ['add', ...]:
          stdout.write('Enter title: ');
          final title = stdin.readLineSync() ?? '';
          stdout.write('Enter content: ');
          final content = stdin.readLineSync() ?? '';
          await _controller.addNote(title, content);
        case ['list', ...]:
          await _controller.listNotes();
        case _:
          print('Unknown command. Use: add, list, quit');
      }
    }
  }
}
