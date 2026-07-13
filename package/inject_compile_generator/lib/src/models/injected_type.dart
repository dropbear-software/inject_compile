import 'package:meta/meta.dart';
import 'lookup_key.dart';

/// A type that is being injected, with metadata about how it is being injected.
@immutable
class InjectedType {
  /// The type the user is trying to inject.
  final LookupKey lookupKey;

  /// Whether the user is trying to inject a provider (factory function) of the type.
  final bool isProvider;

  const InjectedType({required this.lookupKey, this.isProvider = false});

  factory InjectedType.fromJson(Map<String, dynamic> json) => InjectedType(
    lookupKey: LookupKey.fromJson(json['lookupKey'] as Map<String, dynamic>),
    isProvider: json['isProvider'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'lookupKey': lookupKey.toJson(),
    'isProvider': isProvider,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InjectedType &&
          lookupKey == other.lookupKey &&
          isProvider == other.isProvider;

  @override
  int get hashCode => Object.hash(lookupKey, isProvider);

  @override
  String toString() =>
      'InjectedType(lookupKey: $lookupKey, isProvider: $isProvider)';
}
