# Compile-Time Dependency Injection for Dart & Flutter

A compile-time, Dagger-inspired dependency injection (DI) framework for Dart and
Flutter. 

This repository contains a port of the original [inject.dart](https://github.com/google/inject.dart/) package
from Google, updated to support Dart 3, sound null safety, the latest
analyzer, and modern build tooling.

## Packages

This repository is organized as a [Dart Workspace](https://dart.dev/tools/pub/workspaces)
containing two core packages:

*   [`inject_compile`](package/inject_compile/README.md): The annotation library
    (`@provide`, `@module`, `@injector`, etc.) included in your application.
*   [`inject_compile_generator`](package/inject_compile_generator/README.md): The
    `build_runner` code generator that constructs the dependency graph at build
    time.

## Examples

Explore the `example/` directory for sample projects:

*   [`example/coffee`](example/coffee/README.md): A basic command-line coffee
    shop simulation (the classic Dagger example).
*   [`example/train`](example/train/README.md): An example demonstrating multi-module
    composition and asynchronous injection (`@asynchronous`).
*   [`example/clean_architecture`](example/clean_architecture/README.md): A complete
    command-line notes application demonstrating clean architecture (Domain,
    Data, and Presentation layers) integrated with compile-time DI.

## Why Compile-Time?

All dependency injection is resolved, validated, and generated at compile-time by
`build_runner`. This eliminates the need for runtime reflection (like
`dart:mirrors`) or service locator lookups, yielding:
*   **Fast startup times** and smaller binary footprints (ideal for Flutter).
*   **Compile-time safety**: Dependency cycles, missing providers, or conflicts
    are caught during code generation, not at runtime.

## Framework Agnostic

`inject_compile` does not depend on Flutter or any specific framework, making it
equally suitable for command-line applications, server-side Dart, or Flutter apps.

## Acknowledgement

Please note that all of the original code in [inject.dart](https://github.com/google/inject.dart/) 
which these packages is heavily based on is Copyright by Google and originally licenced under a 
MIT Licence which has been kept. Special thanks to @matanlurey who was the primary original author.