import 'package:build/build.dart';
import 'src/build/summary_builder.dart';
import 'src/build/inject_builder.dart';

/// Creates a [Builder] that extracts summaries.
Builder summaryBuilder(BuilderOptions options) => SummaryBuilder();

/// Creates a [Builder] that generates DI code.
Builder injectBuilder(BuilderOptions options) => InjectBuilder();
