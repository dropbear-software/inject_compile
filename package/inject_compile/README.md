# Compile-Time Dependency Injection for Dart & Flutter

This package provides the annotations used to declare a compile-time dependency
injection (DI) graph. It is a modern, sound null-safe port of the original
[inject.dart](https://github.com/google/inject.dart/) from Google.

Since this library generates code at compile time, it does not rely on runtime
reflection or any kind of dynamic lookup. This ensures maximum performance and
minimal build sizes for Flutter and standalone Dart applications.

## Getting Started

Add `inject_compile` as a dependency and `inject_compile_generator` as a dev
dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  inject_compile: ^0.9.0

dev_dependencies:
  build_runner: ^2.4.0
  inject_compile_generator: ^0.9.0
```

## Annotations

### `@provide`

Marks a constructor, method, or getter as providing a dependency.
*   **On a class constructor**: Registers the class in the dependency graph
    so the framework knows how to instantiate it.
*   **On a module method/getter**: Registers the return type as a dependency.
    The framework calls this member to obtain the instance.

### `@module`

Marks a class as a module. Modules contain provider methods for dependencies
that cannot be easily instantiated directly (such as interfaces, third-party
classes, or asynchronous resources).

### `@injector`

Marks an abstract class as the root of a dependency injection graph. The code
generator creates a concrete implementation subclass (e.g., `YourClass$Injector`)
implementing this interface.

### `@singleton`

Combined with `@provide`, indicates that a dependency is instantiated only once
per injector instance. All subsequent requests return the same instance.

### `@asynchronous`

Marks a provider method returning a `Future` as asynchronous. The generated
injector awaits the future during creation, resolving the value synchronously
for any dependent classes.

### `@Qualifier`

Differentiates multiple bindings of the same type by associating a symbol
(e.g., `@Qualifier(#name)`) with the provider.

## Next Steps

*   To run the generator, refer to the `inject_compile_generator` package page.
*   For complete samples, see the workspace examples.

## Acknowledgement

Please note that all of the original code in [inject.dart](https://github.com/google/inject.dart/) 
which these packages is heavily based on is Copyright by Google and originally licenced under a 
MIT Licence which has been kept. Special thanks to Matan Lurey who was the primary original author.