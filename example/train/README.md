# Train Example

This example demonstrates a multi-module train simulation application showcasing modular dependency injection, service locator composition, and compile-time verification using `inject_compile`.

## Structure

The example consists of multiple feature modules and local service locator interfaces that are composed together:

*   **`lib/common.dart`**: Provides common system-wide dependencies (like `CarMaintenance`).
*   **`lib/bike.dart`**: Defines the bike car feature:
    *   `BikeServiceLocator`: A feature-specific locator interface.
    *   `BikeServices`: A module that declares how to instantiate `BikeRack`, specifying a dependency on `CarMaintenance` which it expects to be provided by a sibling module in the final injector.
*   **`lib/food.dart`**: Defines the food car feature, containing `FoodServices` module and `FoodServiceLocator`.
*   **`lib/locomotive.dart`**: The central module composition layer:
    *   `TrainServices`: The root injector annotated with `@Injector([BikeServices, FoodServices, CommonServices])` that implements the individual feature locator interfaces (`BikeServiceLocator`, `FoodServiceLocator`).
*   **`example/train_example.dart`**: The entry point that instantiates the modules and initializes the locator.

## Running the Example

Since `inject_compile` is a compile-time dependency injection library, you must generate the boilerplate dependency wiring code before running the application.

1.  Generate the DI code:
    ```bash
    dart run build_runner build
    ```
    This generates the `lib/locomotive.inject.dart` file.

2.  Run the application:
    ```bash
    dart run example/train_example.dart
    ```
