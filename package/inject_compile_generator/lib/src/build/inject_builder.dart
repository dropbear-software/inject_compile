import 'dart:async';
import 'dart:convert';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import '../graph/injector_graph_resolver.dart';
import '../graph/summary_reader.dart';
import '../models/summary.dart';
import 'injector_generator.dart';

/// A builder that generates DI implementations for [Injector]-annotated classes.
class InjectBuilder implements Builder {
  final DartFormatter _formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  @override
  Map<String, List<String>> get buildExtensions => {
    '.inject.summary': ['.inject.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final summaryId = buildStep.inputId;
    final content = await buildStep.readAsString(summaryId);
    final librarySummary = LibrarySummary.fromJson(
      jsonDecode(content) as Map<String, dynamic>,
    );

    if (librarySummary.injectors.isEmpty) return;

    final reader = AssetSummaryReader(buildStep);
    final results = <String>[];

    for (final injector in librarySummary.injectors) {
      final resolver = InjectorGraphResolver(reader, injector);
      final graph = await resolver.resolve();
      final generator = InjectorGenerator(graph, injector.clazz);
      final library = generator.generate();

      final targetUri = summaryId.uri.toString().replaceFirst(
        '.inject.summary',
        '.dart',
      );
      final emitter = DartEmitter(
        allocator: _AssetRelativeAllocator(targetUri),
        useNullSafetySyntax: true,
      );
      results.add(library.accept(emitter).toString());
    }

    if (results.isNotEmpty) {
      final outputId = summaryId.changeExtension('.dart');
      final combinedSource = results.join('\n\n');
      await buildStep.writeAsString(
        outputId,
        _formatter.format(combinedSource),
      );
    }
  }
}

class _AssetRelativeAllocator implements Allocator {
  final String _targetUri;
  final Allocator _delegate = Allocator.simplePrefixing();

  _AssetRelativeAllocator(this._targetUri);

  @override
  String allocate(Reference reference) {
    final url = reference.url;
    if (url != null && url.startsWith('asset:')) {
      final targetAssetPath = _targetUri.replaceFirst('asset:', '');
      final targetDir = targetAssetPath.substring(
        0,
        targetAssetPath.lastIndexOf('/') + 1,
      );
      final refAssetPath = url.replaceFirst('asset:', '');

      if (refAssetPath.startsWith(targetDir)) {
        reference = Reference(
          reference.symbol,
          refAssetPath.substring(targetDir.length),
        );
      }
    }
    return _delegate.allocate(reference);
  }

  @override
  Iterable<Directive> get imports => _delegate.imports;
}
