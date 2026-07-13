import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'symbol_path.g.dart';

/// The absolute canonical location of a symbol within Dart.
@immutable
@JsonSerializable()
class SymbolPath {
  /// The name of the package containing the Dart source code.
  ///
  /// For Dart core libraries use "dart". For global symbols, this is null.
  final String? package;

  /// The location relative to the package root (e.g., 'lib/foo.dart').
  ///
  /// For global symbols, this is null.
  final String? path;

  /// The name of the top-level symbol within the referenced Dart source code.
  final String symbol;

  /// The type arguments of the symbol, if any.
  final List<SymbolPath> typeArguments;

  const SymbolPath({
    this.package,
    this.path,
    required this.symbol,
    this.typeArguments = const [],
  });

  /// Creates a reference to [symbol] found at [path] within the Dart SDK.
  factory SymbolPath.dartSdk(
    String path,
    String symbol, [
    List<SymbolPath> typeArguments = const [],
  ]) => SymbolPath(
    package: 'dart',
    path: path,
    symbol: symbol,
    typeArguments: typeArguments,
  );

  /// Defines a global symbol that is not scoped to a package/path.
  const SymbolPath.global(this.symbol, [this.typeArguments = const []])
    : package = null,
      path = null;

  factory SymbolPath.fromJson(Map<String, dynamic> json) =>
      _$SymbolPathFromJson(json);

  Map<String, dynamic> toJson() => _$SymbolPathToJson(this);

  /// Whether the [path] points within the Dart SDK, not a pub package.
  bool get isDartSdk => package == 'dart';

  /// Whether [symbol] is a global key.
  bool get isGlobal => package == null && path == null;

  /// A new absolute 'dart:', 'asset:', or 'global:' [Uri] representing this path.
  Uri toAbsoluteUri() {
    if (isGlobal) {
      return Uri(scheme: 'global', fragment: symbol);
    }
    return Uri(
      scheme: isDartSdk ? 'dart' : 'asset',
      path: isDartSdk ? path! : '$package/$path',
      fragment: symbol,
    );
  }

  /// A [Uri] for this path that can be used in a Dart import statement.
  Uri toDartUri() {
    if (isGlobal) {
      throw UnsupportedError('Global keys do not map to Dart source.');
    }

    if (isDartSdk) {
      return Uri(scheme: 'dart', path: path);
    }

    final pathSegments = path!.split('/');
    if (pathSegments.first != 'lib') {
      // For files outside of lib/ (e.g. test/), we cannot construct a package:
      // URI. Return an asset: URI instead, which build_runner understands.
      return Uri(scheme: 'asset', path: '$package/$path');
    }

    final packagePath = pathSegments.skip(1).join('/');
    return Uri(scheme: 'package', path: '$package/$packagePath');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SymbolPath) return false;

    if (package != other.package ||
        path != other.path ||
        symbol != other.symbol ||
        typeArguments.length != other.typeArguments.length) {
      return false;
    }

    for (var i = 0; i < typeArguments.length; i++) {
      if (typeArguments[i] != other.typeArguments[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode =>
      Object.hash(package, path, symbol, Object.hashAll(typeArguments));

  @override
  String toString() {
    if (typeArguments.isEmpty) {
      return 'SymbolPath($package, $path, $symbol)';
    }
    return 'SymbolPath($package, $path, $symbol, <$typeArguments>)';
  }
}
