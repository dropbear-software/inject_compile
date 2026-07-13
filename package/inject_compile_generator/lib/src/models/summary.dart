import 'package:meta/meta.dart';
import 'injected_type.dart';
import 'symbol_path.dart';

/// The kind of provider.
enum ProviderKind {
  /// A method annotated with `@provide` in a module.
  method,

  /// A constructor of a class that is being injected.
  constructor,

  /// A getter or field (if supported in the future).
  getter,
}

/// Metadata for a provider (method or constructor).
@immutable
class ProviderSummary {
  /// The name of the method or constructor.
  final String name;

  /// The type that this provider returns.
  final InjectedType resultType;

  /// The kind of provider.
  final ProviderKind kind;

  /// Whether the provider is a singleton.
  final bool isSingleton;

  /// Whether the provider is asynchronous.
  final bool isAsynchronous;

  /// The dependencies required by this provider.
  final List<InjectedType> dependencies;

  const ProviderSummary({
    required this.name,
    required this.resultType,
    required this.kind,
    this.isSingleton = false,
    this.isAsynchronous = false,
    this.dependencies = const [],
  });

  factory ProviderSummary.fromJson(Map<String, dynamic> json) =>
      ProviderSummary(
        name: json['name'] as String,
        resultType: InjectedType.fromJson(
          json['resultType'] as Map<String, dynamic>,
        ),
        kind: ProviderKind.values.byName(json['kind'] as String),
        isSingleton: json['isSingleton'] as bool? ?? false,
        isAsynchronous: json['isAsynchronous'] as bool? ?? false,
        dependencies:
            (json['dependencies'] as List<dynamic>?)
                ?.map((e) => InjectedType.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'resultType': resultType.toJson(),
    'kind': kind.name,
    'isSingleton': isSingleton,
    'isAsynchronous': isAsynchronous,
    'dependencies': dependencies.map((e) => e.toJson()).toList(),
  };
}

/// Metadata for a module class.
@immutable
class ModuleSummary {
  /// The class that defines the module.
  final SymbolPath clazz;

  /// The providers defined in the module.
  final List<ProviderSummary> providers;

  const ModuleSummary({required this.clazz, required this.providers});

  factory ModuleSummary.fromJson(Map<String, dynamic> json) => ModuleSummary(
    clazz: SymbolPath.fromJson(json['clazz'] as Map<String, dynamic>),
    providers: (json['providers'] as List<dynamic>)
        .map((e) => ProviderSummary.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'clazz': clazz.toJson(),
    'providers': providers.map((e) => e.toJson()).toList(),
  };
}

/// Metadata for an injector class.
@immutable
class InjectorSummary {
  /// The abstract class that defines the injector.
  final SymbolPath clazz;

  /// The modules included in the injector.
  final List<SymbolPath> modules;

  /// The provider methods defined in the injector class itself.
  final List<ProviderSummary> providers;

  const InjectorSummary({
    required this.clazz,
    required this.modules,
    required this.providers,
  });

  factory InjectorSummary.fromJson(Map<String, dynamic> json) =>
      InjectorSummary(
        clazz: SymbolPath.fromJson(json['clazz'] as Map<String, dynamic>),
        modules: (json['modules'] as List<dynamic>)
            .map((e) => SymbolPath.fromJson(e as Map<String, dynamic>))
            .toList(),
        providers: (json['providers'] as List<dynamic>)
            .map((e) => ProviderSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'clazz': clazz.toJson(),
    'modules': modules.map((e) => e.toJson()).toList(),
    'providers': providers.map((e) => e.toJson()).toList(),
  };
}

/// Metadata for a class that can be injected (e.g. annotated with `@provide` on constructor).
@immutable
class InjectableSummary {
  /// The class that is injectable.
  final SymbolPath clazz;

  /// The constructor provider.
  final ProviderSummary constructor;

  const InjectableSummary({required this.clazz, required this.constructor});

  factory InjectableSummary.fromJson(Map<String, dynamic> json) =>
      InjectableSummary(
        clazz: SymbolPath.fromJson(json['clazz'] as Map<String, dynamic>),
        constructor: ProviderSummary.fromJson(
          json['constructor'] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
    'clazz': clazz.toJson(),
    'constructor': constructor.toJson(),
  };
}

/// The top-level summary for a Dart library.
@immutable
class LibrarySummary {
  /// The URI of the library (asset scheme).
  final String assetUri;

  /// The modules defined in the library.
  final List<ModuleSummary> modules;

  /// The injectors defined in the library.
  final List<InjectorSummary> injectors;

  /// The injectable classes defined in the library.
  final List<InjectableSummary> injectables;

  const LibrarySummary({
    required this.assetUri,
    this.modules = const [],
    this.injectors = const [],
    this.injectables = const [],
  });

  factory LibrarySummary.fromJson(Map<String, dynamic> json) => LibrarySummary(
    assetUri: json['assetUri'] as String,
    modules:
        (json['modules'] as List<dynamic>?)
            ?.map((e) => ModuleSummary.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    injectors:
        (json['injectors'] as List<dynamic>?)
            ?.map((e) => InjectorSummary.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    injectables:
        (json['injectables'] as List<dynamic>?)
            ?.map((e) => InjectableSummary.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'assetUri': assetUri,
    'modules': modules.map((e) => e.toJson()).toList(),
    'injectors': injectors.map((e) => e.toJson()).toList(),
    'injectables': injectables.map((e) => e.toJson()).toList(),
  };
}
