import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import '../models/symbol_path.dart';
import '../models/lookup_key.dart';
import '../models/injected_type.dart';

/// Returns a [SymbolPath] for the given [element].
SymbolPath getSymbolPath(
  Element element, {
  List<SymbolPath> typeArguments = const [],
}) {
  final library = element.library;
  if (library == null) {
    throw ArgumentError('Element $element does not belong to a library.');
  }
  final librarySource = library.firstFragment.source;
  final uri = librarySource.uri;

  if (uri.scheme == 'dart') {
    return SymbolPath(
      package: 'dart',
      path: uri.path,
      symbol: element.name!,
      typeArguments: typeArguments,
    );
  }

  if (uri.scheme == 'package') {
    final segments = uri.pathSegments;
    return SymbolPath(
      package: segments.first,
      path: 'lib/${segments.skip(1).join('/')}',
      symbol: element.name!,
      typeArguments: typeArguments,
    );
  }

  if (uri.scheme == 'asset') {
    final segments = uri.pathSegments;
    return SymbolPath(
      package: segments.first,
      path: segments.skip(1).join('/'),
      symbol: element.name!,
      typeArguments: typeArguments,
    );
  }

  throw UnsupportedError('Unsupported URI scheme: ${uri.scheme}');
}

/// Extracts a SymbolPath from a DartType, preserving type arguments.
SymbolPath getSymbolPathFromType(DartType type) {
  if (type is! InterfaceType) {
    if (type is DynamicType) {
      return const SymbolPath.global('dynamic');
    }
    if (type is VoidType) {
      return const SymbolPath.global('void');
    }
    throw UnsupportedError(
      'Only interface types are supported for injection, but got: $type',
    );
  }

  final typeArguments = type.typeArguments
      .map((t) => getSymbolPathFromType(t))
      .toList();

  return getSymbolPath(type.element, typeArguments: typeArguments);
}

/// Returns a [LookupKey] for the given [type].
LookupKey getLookupKey(DartType type, {SymbolPath? qualifier}) {
  if (type is! InterfaceType) {
    throw UnsupportedError('Only interface types are supported for injection.');
  }

  return LookupKey(root: getSymbolPathFromType(type), qualifier: qualifier);
}

/// Returns an [InjectedType] for the given [type].
InjectedType getInjectedType(DartType type, {SymbolPath? qualifier}) {
  // Original inject: zero-arg functions are treated as providers of their return type.
  if (type is FunctionType) {
    if (type.formalParameters.isNotEmpty) {
      throw UnsupportedError(
        'Only zero-argument functions are supported as providers.',
      );
    }
    return InjectedType(
      lookupKey: getLookupKey(type.returnType, qualifier: qualifier),
      isProvider: true,
    );
  }

  return InjectedType(
    lookupKey: getLookupKey(type, qualifier: qualifier),
    isProvider: false,
  );
}
