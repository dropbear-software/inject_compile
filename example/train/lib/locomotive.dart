import 'dart:async';

import 'package:inject_compile/inject.dart';

import 'bike.dart';
import 'common.dart';
import 'food.dart';

import 'locomotive.inject.dart' as g;

/// The top level injector that stitches together multiple app features into
/// a complete app.
@Injector([BikeServices, FoodServices, CommonServices])
abstract class TrainServices implements BikeServiceLocator, FoodServiceLocator {
  static final create = g.TrainServices$Injector.create;

  static Future<TrainServices> createWithInitialization(
    BikeServices bikeModule,
    FoodServices foodModule,
    CommonServices commonModule,
  ) async {
    final services = await create(bikeModule, foodModule, commonModule);

    bikeServices = services;
    foodServices = services;
    return services;
  }
}
