import 'package:inject_compile_generator/src/models/symbol_path.dart';
import 'package:test/test.dart';

void main() {
  group('SymbolPath', () {
    test('should set the package as "dart" with the dartSdk factory', () {
      expect(
        SymbolPath.dartSdk('core', 'List'),
        const SymbolPath(package: 'dart', path: 'core', symbol: 'List'),
      );
    });

    test('should generate a valid asset URI for a Dart package', () {
      expect(
        const SymbolPath(
          package: 'collection',
          path: 'lib/collection.dart',
          symbol: 'MapEquality',
        ).toAbsoluteUri().toString(),
        'asset:collection/lib/collection.dart#MapEquality',
      );
    });

    test('should generate a valid asset URI for a Dart SDK package', () {
      expect(
        SymbolPath.dartSdk('core', 'List').toAbsoluteUri().toString(),
        'dart:core#List',
      );
    });

    test('should generate a valid import URI for a Dart SDK package', () {
      expect(
        SymbolPath.dartSdk('core', 'DateTime').toDartUri().toString(),
        'dart:core',
      );
    });

    test('should generate a valid asset URI for a global symbol', () {
      expect(
        const SymbolPath.global('baseUri').toAbsoluteUri().toString(),
        'global:#baseUri',
      );
    });

    test('should generate a valid package URI for a lib file', () {
      expect(
        const SymbolPath(
          package: 'inject_compile',
          path: 'lib/inject_compile.dart',
          symbol: 'Module',
        ).toDartUri().toString(),
        'package:inject_compile/inject_compile.dart',
      );
    });
  });
}
