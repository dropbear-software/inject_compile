import 'package:inject_compile/inject.dart';
import 'data_module.dart';
import '../presentation/cli_view.dart';
import 'app_injector.inject.dart' as g;

/// The root component for the Clean Architecture example application.
///
/// This injector resolves all the dependencies across the Domain, Data,
/// and Presentation layers using the specified modules.
@Injector([DataModule])
abstract class AppInjector {
  /// The static factory method that delegates to the generated injector.
  static final create = g.AppInjector$Injector.create;

  /// The root component we want to extract from the dependency graph.
  @provide
  CliView get cliView;
}
