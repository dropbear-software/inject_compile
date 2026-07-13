import 'dart:convert';

import 'package:inject_compile_generator/src/models/injected_type.dart';
import 'package:inject_compile_generator/src/models/lookup_key.dart';
import 'package:inject_compile_generator/src/models/summary.dart';
import 'package:inject_compile_generator/src/models/symbol_path.dart';
import 'package:test/test.dart';

void main() {
  group('Summary models serialization', () {
    test('ProviderSummary serialization', () {
      final summary = ProviderSummary(
        name: 'testProvider',
        kind: ProviderKind.method,
        resultType: InjectedType(
          lookupKey: LookupKey(root: const SymbolPath.global('String')),
        ),
      );
      final jsonStr = jsonEncode(summary.toJson());
      final deserialized = ProviderSummary.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(deserialized.name, summary.name);
      expect(deserialized.kind, summary.kind);
    });

    test('ModuleSummary serialization', () {
      final summary = ModuleSummary(
        clazz: const SymbolPath.global('MyModule'),
        providers: [],
      );
      final jsonStr = jsonEncode(summary.toJson());
      final deserialized = ModuleSummary.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(deserialized.clazz.symbol, summary.clazz.symbol);
    });

    test('InjectorSummary serialization', () {
      final summary = InjectorSummary(
        clazz: const SymbolPath.global('MyInjector'),
        modules: [const SymbolPath.global('MyModule')],
        providers: [],
      );
      final jsonStr = jsonEncode(summary.toJson());
      final deserialized = InjectorSummary.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(deserialized.clazz.symbol, summary.clazz.symbol);
      expect(deserialized.modules.first.symbol, summary.modules.first.symbol);
    });

    test('InjectableSummary serialization', () {
      final summary = InjectableSummary(
        clazz: const SymbolPath.global('MyClass'),
        constructor: ProviderSummary(
          name: '',
          kind: ProviderKind.constructor,
          resultType: InjectedType(
            lookupKey: LookupKey(root: const SymbolPath.global('MyClass')),
          ),
        ),
      );
      final jsonStr = jsonEncode(summary.toJson());
      final deserialized = InjectableSummary.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(deserialized.clazz.symbol, summary.clazz.symbol);
    });

    test('LibrarySummary serialization', () {
      final summary = LibrarySummary(
        assetUri: 'asset:a/lib/a.dart',
        modules: [],
        injectors: [],
        injectables: [],
      );
      final jsonStr = jsonEncode(summary.toJson());
      final deserialized = LibrarySummary.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(deserialized.assetUri, summary.assetUri);
    });
  });
}
