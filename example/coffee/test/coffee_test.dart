import 'package:coffee/coffee_shop.dart';
import 'package:test/test.dart';

void main() {
  group('CoffeeShop', () {
    test('should brew coffee', () async {
      final shop = await CoffeeShop.create(DripCoffeeModule());
      final maker = shop.coffeeMaker;

      expect(maker, isNotNull);
      expect(maker.heater, isNotNull);
      expect(maker.pump, isNotNull);

      // Verify initial state
      expect(maker.heater.isHot, isFalse);

      // Brew coffee
      maker.brew();

      // Verify that heater was turned on and off during brew
      // (Since brew() turns it on, then off, it should be off now)
      expect(maker.heater.isHot, isFalse);
    });

    test('should provide a singleton heater', () async {
      final shop = await CoffeeShop.create(DripCoffeeModule());
      final maker = shop.coffeeMaker;
      final thermosiphon = maker.pump as Thermosiphon;

      // Both CoffeeMaker and Thermosiphon should share the same Heater instance
      expect(maker.heater, same(thermosiphon.heater));
    });
  });
}
