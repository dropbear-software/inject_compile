# `inject_compile`

The annotation library for `inject_compile`, a compile-time dependency injection framework for Dart and Flutter.

This package provides the annotations used to define your dependency injection graph. It does **not** contain the code generator; you must also use `inject_compile_generator` as a `dev_dependency` to actually generate the DI code.

## Getting Started

Add this package as a regular dependency, and `inject_compile_generator` as a dev dependency, in your `pubspec.yaml`:

```yaml
dependencies:
  inject_compile: ^0.9.0

dev_dependencies:
  build_runner: ^2.4.0
  inject_compile_generator: ^0.9.0
```

## Annotations

### `@provide` (or `@Provide()`)
Marks a constructor, method, or getter as providing a dependency. 
- When applied to a **class constructor**, the framework will know how to instantiate that class.
- When applied to a **method or getter in a `@module`**, the framework will call it to retrieve a dependency.

### `@module` (or `@Module()`)
Marks a class as a module. Modules encapsulate provider methods that supply dependencies which are not easily instantiated directly (such as interfaces, third-party classes, or async dependencies).

### `@injector` (or `@Injector([ModuleType, ...])`)
Marks a class as the root of a dependency injection graph. Injectors define the dependencies that the rest of your application requires. 
The generator will create a concrete subclass (e.g. `YourClass$Injector`) that implements your injector interface.

### `@singleton` (or `@Singleton()`)
When combined with `@provide`, indicates that the dependency should be instantiated only once per injector instance. All subsequent requests for this type will return the same instance.

### `@asynchronous` (or `@Asynchronous()`)
Marks a `@provide` method as asynchronous. The generated injector will await the provided `Future` during its `create()` phase, making the resolved value available synchronously to other dependencies.

### `@qualifier` (or `@Qualifier(#name)`)
Used to differentiate multiple bindings of the same type. You can create custom qualifier annotations by annotating them with `@qualifier`.

## Usage

See the workspace `example/` directory for full examples.
