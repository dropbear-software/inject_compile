import 'package:build/build.dart';
import 'package:inject_compile_generator/src/graph/injector_graph_resolver.dart';
import 'package:inject_compile_generator/src/graph/summary_reader.dart';
import 'package:inject_compile_generator/src/models/summary.dart';
import 'package:inject_compile_generator/src/models/symbol_path.dart';
import 'package:inject_compile_generator/src/models/lookup_key.dart';
import 'package:inject_compile_generator/src/models/injected_type.dart';
import 'package:test/test.dart';

void main() {
  group('InjectorGraphResolver', () {
    late FakeSummaryReader reader;

    setUp(() {
      reader = FakeSummaryReader();
    });

    test('resolves a simple graph', () async {
      final fooModulePath = SymbolPath(
        package: 'foo',
        path: 'lib/foo.dart',
        symbol: 'FooModule',
      );
      final fooClassPath = SymbolPath(
        package: 'foo',
        path: 'lib/foo.dart',
        symbol: 'Foo',
      );
      final injectorPath = SymbolPath(
        package: 'foo',
        path: 'lib/foo.dart',
        symbol: 'FooInjector',
      );

      final fooModule = ModuleSummary(
        clazz: fooModulePath,
        providers: [
          ProviderSummary(
            name: 'provideFoo',
            kind: ProviderKind.method,
            resultType: InjectedType(lookupKey: LookupKey(root: fooClassPath)),
            isSingleton: false,
            isAsynchronous: false,
            dependencies: [],
          ),
        ],
      );

      reader.addSummary(
        AssetId('foo', 'lib/foo.dart'),
        LibrarySummary(assetUri: 'package:foo/foo.dart', modules: [fooModule]),
      );

      final injectorSummary = InjectorSummary(
        clazz: injectorPath,
        modules: [fooModulePath],
        providers: [
          ProviderSummary(
            name: 'getFoo',
            kind: ProviderKind.method,
            resultType: InjectedType(lookupKey: LookupKey(root: fooClassPath)),
            isSingleton: false,
            isAsynchronous: false,
            dependencies: [],
          ),
        ],
      );

      final resolver = InjectorGraphResolver(reader, injectorSummary);
      final graph = await resolver.resolve();

      expect(graph.modules, contains(fooModulePath));
      expect(graph.mergedDependencies, contains(LookupKey(root: fooClassPath)));
    });

    test('detects cycles', () async {
      final aPath = SymbolPath(package: 'pkg', path: 'lib/a.dart', symbol: 'A');
      final bPath = SymbolPath(package: 'pkg', path: 'lib/b.dart', symbol: 'B');
      final injectorPath = SymbolPath(
        package: 'pkg',
        path: 'lib/main.dart',
        symbol: 'MainInjector',
      );

      reader.addSummary(
        AssetId('pkg', 'lib/a.dart'),
        LibrarySummary(
          assetUri: 'package:pkg/a.dart',
          injectables: [
            InjectableSummary(
              clazz: aPath,
              constructor: ProviderSummary(
                name: '',
                kind: ProviderKind.constructor,
                resultType: InjectedType(lookupKey: LookupKey(root: aPath)),
                isSingleton: false,
                isAsynchronous: false,
                dependencies: [InjectedType(lookupKey: LookupKey(root: bPath))],
              ),
            ),
          ],
        ),
      );

      reader.addSummary(
        AssetId('pkg', 'lib/b.dart'),
        LibrarySummary(
          assetUri: 'package:pkg/b.dart',
          injectables: [
            InjectableSummary(
              clazz: bPath,
              constructor: ProviderSummary(
                name: '',
                kind: ProviderKind.constructor,
                resultType: InjectedType(lookupKey: LookupKey(root: bPath)),
                isSingleton: false,
                isAsynchronous: false,
                dependencies: [InjectedType(lookupKey: LookupKey(root: aPath))],
              ),
            ),
          ],
        ),
      );

      final injectorSummary = InjectorSummary(
        clazz: injectorPath,
        modules: [],
        providers: [
          ProviderSummary(
            name: 'getA',
            kind: ProviderKind.method,
            resultType: InjectedType(lookupKey: LookupKey(root: aPath)),
            isSingleton: false,
            isAsynchronous: false,
            dependencies: [],
          ),
        ],
      );

      final resolver = InjectorGraphResolver(reader, injectorSummary);
      expect(resolver.resolve(), throwsStateError);
    });

    test('fails on missing dependencies', () async {
      final aPath = SymbolPath(package: 'pkg', path: 'lib/a.dart', symbol: 'A');
      final bPath = SymbolPath(package: 'pkg', path: 'lib/b.dart', symbol: 'B');
      final injectorPath = SymbolPath(
        package: 'pkg',
        path: 'lib/main.dart',
        symbol: 'MainInjector',
      );

      reader.addSummary(
        AssetId('pkg', 'lib/a.dart'),
        LibrarySummary(
          assetUri: 'package:pkg/a.dart',
          injectables: [
            InjectableSummary(
              clazz: aPath,
              constructor: ProviderSummary(
                name: '',
                kind: ProviderKind.constructor,
                resultType: InjectedType(lookupKey: LookupKey(root: aPath)),
                isSingleton: false,
                isAsynchronous: false,
                dependencies: [InjectedType(lookupKey: LookupKey(root: bPath))],
              ),
            ),
          ],
        ),
      );

      final injectorSummary = InjectorSummary(
        clazz: injectorPath,
        modules: [],
        providers: [
          ProviderSummary(
            name: 'getA',
            kind: ProviderKind.method,
            resultType: InjectedType(lookupKey: LookupKey(root: aPath)),
            isSingleton: false,
            isAsynchronous: false,
            dependencies: [],
          ),
        ],
      );

      final resolver = InjectorGraphResolver(reader, injectorSummary);
      expect(resolver.resolve(), throwsStateError);
    });
  });
}

class FakeSummaryReader implements SummaryReader {
  final Map<AssetId, LibrarySummary> _summaries = {};

  void addSummary(AssetId id, LibrarySummary summary) {
    _summaries[id] = summary;
  }

  @override
  Future<LibrarySummary?> read(AssetId assetId) async {
    return _summaries[assetId];
  }
}
