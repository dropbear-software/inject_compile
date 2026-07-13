# Coffee Maker Simulation (Compile-Time DI)

This example demonstrates a basic console application implementing the classic
Dagger coffee maker simulation using `inject_compile` for compile-time
dependency injection.

## Structure

*   **`lib/coffee_shop.dart`**:
    Defines the modules, components, and classes:
    *   `Heater` & `Pump`: Interfaces representing dependencies.
    *   `ElectricHeater` & `Thermosiphon`: Concrete implementations annotated
        with `@provide` to enter the dependency graph.
    *   `DripCoffeeModule`: A `@module` providing the `Heater` asynchronously
        (`@asynchronous`) and as a `@singleton`, and binding `Pump` to
        `Thermosiphon`.
    *   `CoffeeMaker`: Orchestrates coffee brewing, injected with `Heater` and
        `Pump`.
    *   `CoffeeShop`: An abstract class annotated with `@Injector` that defines
        the entry point getter for `CoffeeMaker`.

## Running the Example

Since `inject_compile` is a compile-time dependency injection library, you must
generate the boilerplate dependency wiring code before running the application.

1.  Generate the DI code:
    ```bash
    dart run build_runner build
    ```
    This generates the `lib/coffee_shop.inject.dart` file.

2.  Run the application:
    ```bash
    dart run lib/coffee_shop.dart
    ```
