import 'package:train/bike.dart';
import 'package:train/common.dart';
import 'package:train/food.dart';
import 'package:train/locomotive.dart';

void main() async {
  final services = await TrainServices.createWithInitialization(
    BikeServices(),
    FoodServices(),
    CommonServices(),
  );
  print(services.bikeRack.pleaseFix());
}
