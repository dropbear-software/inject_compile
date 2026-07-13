import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'symbol_path.dart';

part 'lookup_key.g.dart';

/// A representation of a key in the dependency injection graph.
@immutable
@JsonSerializable()
class LookupKey {
  /// SymbolPath of the root type.
  final SymbolPath root;

  /// Optional qualifier for the type.
  final SymbolPath? qualifier;

  const LookupKey({required this.root, this.qualifier});

  factory LookupKey.fromJson(Map<String, dynamic> json) =>
      _$LookupKeyFromJson(json);

  Map<String, dynamic> toJson() => _$LookupKeyToJson(this);

  /// Returns a human-readable string representation of this key.
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
