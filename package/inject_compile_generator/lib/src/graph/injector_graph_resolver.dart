import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import '../models/injector_graph.dart';
import '../models/lookup_key.dart';
import '../models/summary.dart';
import '../models/symbol_path.dart';
import 'summary_reader.dart';

/// A resolver for building the dependency graph of an injector.
class InjectorGraphResolver {
  final SummaryReader _reader;
  final InjectorSummary _injectorSummary;
  final Logger _logger;

  InjectorGraphResolver(this._reader, this._injectorSummary, {Logger? logger})
    : _logger = logger ?? Logger('InjectorGraphResolver');

  /// The resolved dependency graph.
  Future<InjectorGraph> resolve() async {
    final allModules = <ModuleSummary>[];
    final providersByModules = <LookupKey, DependencyProvidedByModule>{};
    final injectables = <LookupKey, InjectableSummary>{};
    final requestedByMap = <LookupKey, Set<SymbolPath>>{};

    void recordRequest(LookupKey key, SymbolPath requestedBy) {
      requestedByMap.putIfAbsent(key, () => {}).add(requestedBy);
    }

    // 1. Collect all modules starting from the injector.
    for (final modulePath in _injectorSummary.modules) {
      await _collectModules(modulePath, allModules, providersByModules);
    }

    // 2. Resolve all dependencies (both from injector and modules).
    Future<void> resolveKey(
      LookupKey key, {
      required SymbolPath requestedBy,
    }) async {
      recordRequest(key, requestedBy);

      // Modules take precedence.
      if (providersByModules.containsKey(key) || injectables.containsKey(key)) {
        return;
      }

      if (!key.root.isGlobal) {
        final summary = await _reader.read(
          AssetId(key.root.package!, key.root.path!),
        );
        if (summary != null) {
          for (final injectable in summary.injectables) {
            if (injectable.clazz == key.root) {
              injectables[key] = injectable;
              for (final dep in injectable.constructor.dependencies) {
                await resolveKey(dep.lookupKey, requestedBy: injectable.clazz);
              }
              return;
            }
          }
        }
      }
    }

    // Resolve dependencies for all providers in all modules.
    for (final module in allModules) {
      for (final provider in module.providers) {
        for (final dep in provider.dependencies) {
          await resolveKey(dep.lookupKey, requestedBy: module.clazz);
        }
      }
    }

    // Resolve dependencies for all injector providers.
    for (final provider in _injectorSummary.providers) {
      await resolveKey(
        provider.resultType.lookupKey,
        requestedBy: _injectorSummary.clazz,
      );
    }

    // Check for missing dependency providers.
    final missingDependencies = <LookupKey, Set<SymbolPath>>{};
    for (final key in requestedByMap.keys) {
      if (!providersByModules.containsKey(key) &&
          !injectables.containsKey(key)) {
        missingDependencies[key] = requestedByMap[key]!;
      }
    }

    if (missingDependencies.isNotEmpty) {
      final message = StringBuffer('Missing dependency providers:\n');
      missingDependencies.forEach((key, requesters) {
        message.writeln('  - ${key.toPrettyString()}');
        message.writeln('    requested by:');
        for (final req in requesters) {
          message.writeln('      * ${req.symbol} (${req.toAbsoluteUri()})');
        }
      });
      throw StateError(message.toString());
    }

    // 3. Construct the merged dependencies map.
    final mergedDependencies = <LookupKey, ResolvedDependency>{};
    injectables.forEach((key, summary) {
      mergedDependencies[key] = DependencyProvidedByInjectable(
        summary: summary,
      );
    });
    // Modules overwrite injectables (precedence).
    mergedDependencies.addAll(providersByModules);

    // 4. Cycle detection.
    _detectCycles(mergedDependencies);

    final injectorProviders = _injectorSummary.providers.map((p) {
      return InjectorProvider(
        resultType: p.resultType,
        name: p.name,
        isGetter: p.kind == ProviderKind.getter,
      );
    }).toList();

    return InjectorGraph(
      modules: allModules.map((m) => m.clazz).toList(),
      injectorProviders: injectorProviders,
      mergedDependencies: mergedDependencies,
    );
  }

  Future<void> _collectModules(
    SymbolPath modulePath,
    List<ModuleSummary> allModules,
    Map<LookupKey, DependencyProvidedByModule> providersByModules,
  ) async {
    final summary = await _reader.read(
      AssetId(modulePath.package!, modulePath.path!),
    );
    if (summary == null) {
      _logger.severe('Module summary not found for $modulePath.');
      return;
    }
    final module = summary.modules.firstWhereOrNull(
      (m) => m.clazz == modulePath,
    );

    if (module == null) {
      _logger.severe('Module $modulePath not found in its summary.');
      return;
    }

    if (allModules.any((m) => m.clazz == modulePath)) return;
    allModules.add(module);

    for (final provider in module.providers) {
      providersByModules[provider.resultType.lookupKey] =
          DependencyProvidedByModule(module: modulePath, provider: provider);
    }
  }

  void _detectCycles(Map<LookupKey, ResolvedDependency> merged) {
    final checked = <LookupKey>{};
    final cycles = <_Cycle>{};

    for (final key in merged.keys) {
      if (checked.contains(key)) continue;

      final chain = <LookupKey>[];
      void visit(LookupKey current) {
        final index = chain.indexOf(current);
        if (index != -1) {
          final cycle = _Cycle(chain.sublist(index)..add(current));
          cycles.add(cycle);
          return;
        }

        chain.add(current);
        final dep = merged[current];
        if (dep != null) {
          for (final next in dep.dependencies) {
            visit(next.lookupKey);
          }
        }
        chain.removeLast();
        checked.add(current);
      }

      visit(key);
    }

    if (cycles.isNotEmpty) {
      final message = StringBuffer('Detected circular dependencies:\n');
      for (final cycle in cycles) {
        message.writeln(cycle.format());
      }
      throw StateError(message.toString());
    }
  }
}

class _Cycle {
  final List<LookupKey> keys;
  _Cycle(this.keys);

  String format() => keys.map((k) => '  ${k.toPrettyString()}').join('\n');

  @override
  bool operator ==(Object other) =>
      other is _Cycle &&
      const SetEquality().equals(keys.toSet(), other.keys.toSet());

  @override
  int get hashCode => const SetEquality().hash(keys.toSet());
}
