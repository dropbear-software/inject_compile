import 'package:test/test.dart';

import 'package:train/bike.dart';
import 'package:train/common.dart';
import 'package:train/food.dart';
import 'package:train/locomotive.dart';

void main() {
  group('locomotive', () {
    test('can instantiate TrainServices', () async {
      final services = await TrainServices.createWithInitialization(
        BikeServices(),
        FoodServices(),
        CommonServices(),
      );
      expect(services.bikeRack, isNotNull);
      expect(services.kitchen, isNotNull);
    });
  });
}
