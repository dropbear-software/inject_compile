import 'package:meta/meta.dart';
import 'symbol_path.dart';

/// A representation of a key in the dependency injection graph.
@immutable
class LookupKey {
  /// The [SymbolPath] of the root type.
  final SymbolPath root;

  /// The optional qualifier for the type.
  final SymbolPath? qualifier;

  const LookupKey({required this.root, this.qualifier});

  factory LookupKey.fromJson(Map<String, dynamic> json) => LookupKey(
    root: SymbolPath.fromJson(json['root'] as Map<String, dynamic>),
    qualifier: json['qualifier'] == null
        ? null
        : SymbolPath.fromJson(json['qualifier'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'root': root.toJson(),
    if (qualifier != null) 'qualifier': qualifier!.toJson(),
  };

  /// A human-readable string representation of this key.
  String toPrettyString() {
    if (qualifier != null) {
      return '@${qualifier!.symbol} ${root.symbol}';
    }
    return root.symbol;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LookupKey && root == other.root && qualifier == other.qualifier;

  @override
  int get hashCode => Object.hash(root, qualifier);

  @override
  String toString() => 'LookupKey(root: $root, qualifier: $qualifier)';
}
