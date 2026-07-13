import 'package:inject_compile/inject_compile.dart';
import 'coffee_shop.inject.dart' as g;

@module
class DripCoffeeModule {
  @provide
  @singleton
  @asynchronous
  Future<Heater> provideHeater() async {
    print('Initializing heater...');
    await Future.delayed(const Duration(milliseconds: 100));
    return ElectricHeater();
  }

  @provide
  Pump providePump(Thermosiphon pump) => pump;
}

@provide
class ElectricHeater implements Heater {
  @override
  bool isHot = false;
  @override
  void on() {
    isHot = true;
  }

  @override
  void off() {
    isHot = false;
  }
}

abstract class Heater {
  bool get isHot;
  void on();
  void off();
}

abstract class Pump {
  void pump();
}

@provide
class Thermosiphon implements Pump {
  final Heater heater;
  Thermosiphon(this.heater);
  @override
  void pump() {
    if (heater.isHot) print('=> => pumping => =>');
  }
}

@provide
class CoffeeMaker {
  final Heater heater;
  final Pump pump;
  CoffeeMaker(this.heater, this.pump);
  void brew() {
    heater.on();
    pump.pump();
    print(' [_]P coffee! [_]P');
    heater.off();
  }
}

@Injector([DripCoffeeModule])
abstract class CoffeeShop {
  static final create = g.CoffeeShop$Injector.create;

  @provide
  CoffeeMaker get coffeeMaker;
}

void main() async {
  final shop = await CoffeeShop.create(DripCoffeeModule());
  shop.coffeeMaker.brew();
}
