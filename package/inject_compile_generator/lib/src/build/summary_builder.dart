import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import '../analyzer/summary_extractor.dart';

/// Factory for the summary builder.
Builder summaryBuilder(BuilderOptions options) => const SummaryBuilder();

/// A builder that extracts injection metadata and writes it to a summary file.
class SummaryBuilder implements Builder {
  const SummaryBuilder();

  @override
  Future<void> build(BuildStep buildStep) async {
    // Only process .dart files that are not themselves generated.
    if (buildStep.inputId.path.endsWith('.g.dart') ||
        buildStep.inputId.path.endsWith('.inject.summary')) {
      return;
    }

    final library = await buildStep.inputLibrary;
    final extractor = SummaryExtractor(library);
    final summary = extractor.extract();

    // Only write the summary if it contains any injection metadata.
    if (summary.modules.isNotEmpty ||
        summary.injectors.isNotEmpty ||
        summary.injectables.isNotEmpty) {
      final summaryId = buildStep.inputId.changeExtension('.inject.summary');
      final jsonContent = jsonEncode(summary.toJson());
      await buildStep.writeAsString(summaryId, jsonContent);
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.inject.summary'],
  };
}
