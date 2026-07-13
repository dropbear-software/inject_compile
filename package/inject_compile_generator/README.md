# `inject_compile_generator`

The `build_runner` code generator for `inject_compile`.

This package parses the annotations defined in the `inject_compile` package and generates compile-time dependency injection code.

## Getting Started

Add `inject_compile_generator` to your `dev_dependencies` alongside `build_runner`, and `inject_compile` to your regular `dependencies`:

```yaml
dependencies:
  inject_compile: ^0.9.0

dev_dependencies:
  build_runner: ^2.4.0
  inject_compile_generator: ^0.9.0
```

## Running the Generator

Because this package integrates with `build_runner`, you do not need to invoke it directly. Simply run:

```bash
dart run build_runner build
```

This will analyze your code, resolve the dependency graph, and output the generated `.inject.dart` files. 

For continuous generation during development, use the `watch` command:

```bash
dart run build_runner watch
```

## How It Works

The generator works in a two-step process to ensure fast incremental builds:

1.  **Summary Extraction**: First, a `SummaryBuilder` reads your Dart files and extracts lightweight metadata (`.inject.summary` files) about the `@provide`, `@module`, and `@injector` annotations.
2.  **Code Generation**: Next, an `InjectBuilder` resolves the dependency graph using these summaries and generates the final dependency injection wiring code using `code_builder`. 

Because it operates at compile-time, you get instant feedback via analyzer errors or generator exceptions if your dependency graph is invalid (e.g., missing dependencies, circular dependencies, or conflicting annotations).

## Usage

See the workspace `example/` directory for full examples.
