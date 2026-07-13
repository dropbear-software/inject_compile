import 'dart:convert';

import 'package:inject_compile_generator/src/models/injected_type.dart';
import 'package:inject_compile_generator/src/models/lookup_key.dart';
import 'package:inject_compile_generator/src/models/symbol_path.dart';
import 'package:test/test.dart';

final lookupKey1 = LookupKey(root: const SymbolPath.global('1'));
final lookupKey2 = LookupKey(root: const SymbolPath.global('2'));

void main() {
  group('InjectedType', () {
    test('serialization', () {
      final type = InjectedType(lookupKey: lookupKey1, isProvider: true);
      final deserialized = deserialize(type);
      expect(deserialized, type);
    });

    test('equality', () {
      final a1 = InjectedType(lookupKey: lookupKey1);
      final a2 = InjectedType(lookupKey: lookupKey1);
      final b1 = InjectedType(lookupKey: lookupKey2);
      final b2 = InjectedType(lookupKey: lookupKey2);
      final c1 = InjectedType(lookupKey: lookupKey1, isProvider: true);
      final c2 = InjectedType(lookupKey: lookupKey1, isProvider: true);

      expect(a1, a2);
      expect(b1, b2);
      expect(c1, c2);
      expect(a1, isNot(b1));
      expect(a1, isNot(c1));

      // Test hashCode and toString
      expect(a1.hashCode, a2.hashCode);
      expect(a1.hashCode, isNot(b1.hashCode));
      expect(c1.toString(), contains('isProvider: true'));
      expect(a1.toString(), contains('isProvider: false'));
    });
  });
}

InjectedType deserialize(InjectedType type) {
  final jsonStr = jsonEncode(type.toJson());
  return InjectedType.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
