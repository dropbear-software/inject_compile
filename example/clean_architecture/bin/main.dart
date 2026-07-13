import 'package:clean_architecture/di/app_injector.dart';
import 'package:clean_architecture/di/data_module.dart';

void main() async {
  // 1. Initialize the dependency graph by providing required modules
  final injector = await AppInjector.create(DataModule());

  // 2. Extract the root component
  final app = injector.cliView;

  // 3. Start the application
  await app.start();
}
