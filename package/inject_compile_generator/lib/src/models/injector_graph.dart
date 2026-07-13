import 'injected_type.dart';
import 'summary.dart';
import 'symbol_path.dart';
import 'lookup_key.dart';

/// The result of resolving an injector's dependency graph.
class InjectorGraph {
  /// All modules that are part of this graph.
  final List<SymbolPath> modules;

  /// All providers defined on the injector class itself.
  final List<InjectorProvider> injectorProviders;

  /// Map from a [LookupKey] to the dependency that provides it.
  final Map<LookupKey, ResolvedDependency> mergedDependencies;

  InjectorGraph({
    required this.modules,
    required this.injectorProviders,
    required this.mergedDependencies,
  });
}

/// A dependency that has been resolved to a specific provider.
sealed class ResolvedDependency {
  /// The type of the dependency.
  InjectedType get resultType;

  /// Other dependencies required by this provider.
  List<InjectedType> get dependencies;

  /// Whether this dependency is a singleton.
  bool get isSingleton;

  /// Whether this dependency is asynchronous.
  bool get isAsynchronous;
}

/// A dependency provided by a module.
class DependencyProvidedByModule extends ResolvedDependency {
  final SymbolPath module;
  final ProviderSummary provider;

  DependencyProvidedByModule({required this.module, required this.provider});

  @override
  InjectedType get resultType => provider.resultType;

  @override
  List<InjectedType> get dependencies => provider.dependencies;

  @override
  bool get isSingleton => provider.isSingleton;

  @override
  bool get isAsynchronous => provider.isAsynchronous;
}

/// A dependency provided by an @provide-annotated class.
class DependencyProvidedByInjectable extends ResolvedDependency {
  final InjectableSummary summary;

  DependencyProvidedByInjectable({required this.summary});

  @override
  InjectedType get resultType =>
      InjectedType(lookupKey: LookupKey(root: summary.clazz));

  @override
  List<InjectedType> get dependencies => summary.constructor.dependencies;

  @override
  bool get isSingleton => summary.constructor.isSingleton;

  @override
  bool get isAsynchronous => false;
}

/// A provider requested by the injector class.
class InjectorProvider {
  final InjectedType resultType;
  final String name;
  final bool isGetter;

  InjectorProvider({
    required this.resultType,
    required this.name,
    required this.isGetter,
  });
}
