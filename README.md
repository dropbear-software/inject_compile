# `inject_compile`

Compile-time dependency injection for Dart and Flutter.

This workspace contains the modern port of [inject.dart](https://github.com/google/inject.dart) renamed to `inject_compile`, updated to support modern Dart, sound null safety, and the latest analyzer and build systems.

## Packages

This repository is set up as a [Dart Workspace](https://dart.dev/tools/pub/workspaces) containing two main packages:

*   [`inject_compile`](package/inject_compile/README.md): The annotation library (`@provide`, `@module`, `@injector`, etc.) that you include as a regular dependency in your app.
*   [`inject_compile_generator`](package/inject_compile_generator/README.md): The `build_runner` code generator that parses your annotations and generates the boilerplate dependency injection code at compile time.

## Examples

Check out the `example/` directory for sample projects demonstrating how to use `inject_compile`:

*   [`example/coffee`](example/coffee/README.md): A simple command-line coffee shop example (the classic Dagger example).
*   [`example/train`](example/train/README.md): Another example demonstrating modules and asynchronous injection.
*   [`example/clean_architecture`](example/clean_architecture/README.md): Another example demonstrating a canonical clean architecture style application built with `inject_compile`.

## Why Compile-Time?

All dependency injection is analyzed, configured, and generated at compile-time as part of a `build_runner` build process, and does not rely on any runtime setup or configuration (such as reflection with `dart:mirrors`). This provides the best experience in terms of code-size and performance (it's nearly identical to hand written code) and allows us to provide compile-time errors and warnings instead of relying on runtime exceptions.

## Framework Agnostic

`inject_compile` is framework and platform agnostic, meaning it works perfectly well with Flutter, server-side Dart, or any other Dart environment.
