import 'dart:convert';

import 'package:inject_compile_generator/src/models/lookup_key.dart';
import 'package:inject_compile_generator/src/models/symbol_path.dart';
import 'package:test/test.dart';

final typeSymbolPath1 = const SymbolPath.global('TypeName1');
final typeSymbolPath2 = const SymbolPath.global('TypeName2');
final qualifier = const SymbolPath.global('fakeQualifier');

void main() {
  group('LookupKey', () {
    group('toPrettyString', () {
      test('only root', () {
        final type = LookupKey(root: typeSymbolPath1);
        expect(type.toPrettyString(), 'TypeName1');
      });

      test('qualified type', () {
        final type = LookupKey(root: typeSymbolPath1, qualifier: qualifier);
        expect(type.toPrettyString(), '@fakeQualifier TypeName1');
      });
    });

    group('serialization', () {
      test('with all fields', () {
        final type = LookupKey(root: typeSymbolPath1, qualifier: qualifier);
        final deserialized = deserialize(type);
        expect(deserialized, type);
      });

      test('without qualifier', () {
        final type = LookupKey(root: typeSymbolPath1);
        final deserialized = deserialize(type);
        expect(deserialized, type);
      });
    });

    test('equality', () {
      final a1 = LookupKey(root: typeSymbolPath1);
      final a2 = LookupKey(root: typeSymbolPath1);
      final b1 = LookupKey(root: typeSymbolPath1, qualifier: qualifier);
      final b2 = LookupKey(root: typeSymbolPath1, qualifier: qualifier);

      expect(a1, a2);
      expect(b1, b2);
      expect(a1, isNot(b1));
    });
  });
}

LookupKey deserialize(LookupKey type) {
  final jsonStr = jsonEncode(type.toJson());
  return LookupKey.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
