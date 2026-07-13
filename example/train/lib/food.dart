import 'package:inject_compile/inject_compile.dart';

import 'common.dart';

/// Provides service locator for food car feature code.
late FoodServiceLocator foodServices;

/// Declares dependencies used by the food car.
abstract class FoodServiceLocator {
  @provide
  Kitchen get kitchen;
}

/// Declares dependencies needed by the food car.
@module
class FoodServices {
  @provide
  Kitchen kitchen(CarMaintenance cm) => Kitchen(cm);
}

class Kitchen {
  final CarMaintenance maintenance;
  Kitchen(this.maintenance);
}
