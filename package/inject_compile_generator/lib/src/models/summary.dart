import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'injected_type.dart';
import 'symbol_path.dart';

part 'summary.g.dart';

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
@JsonSerializable()
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
      _$ProviderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderSummaryToJson(this);
}

/// Metadata for a module class.
@immutable
@JsonSerializable()
class ModuleSummary {
  /// The class that defines the module.
  final SymbolPath clazz;

  /// The providers defined in the module.
  final List<ProviderSummary> providers;

  const ModuleSummary({required this.clazz, required this.providers});

  factory ModuleSummary.fromJson(Map<String, dynamic> json) =>
      _$ModuleSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleSummaryToJson(this);
}

/// Metadata for an injector class.
@immutable
@JsonSerializable()
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
      _$InjectorSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$InjectorSummaryToJson(this);
}

/// Metadata for a class that can be injected (e.g. annotated with `@provide` on constructor).
@immutable
@JsonSerializable()
class InjectableSummary {
  /// The class that is injectable.
  final SymbolPath clazz;

  /// The constructor provider.
  final ProviderSummary constructor;

  const InjectableSummary({required this.clazz, required this.constructor});

  factory InjectableSummary.fromJson(Map<String, dynamic> json) =>
      _$InjectableSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$InjectableSummaryToJson(this);
}

/// The top-level summary for a Dart library.
@immutable
@JsonSerializable()
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

  factory LibrarySummary.fromJson(Map<String, dynamic> json) =>
      _$LibrarySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$LibrarySummaryToJson(this);
}
