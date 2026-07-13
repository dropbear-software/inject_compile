# Compile-Time Dependency Injection Code Generator

This package provides the `build_runner` code generator for `inject_compile`.
It processes your dependency injection annotations to generate the boilerplate
graph wiring at build time.

## Getting Started

Add `inject_compile_generator` to your `dev_dependencies` alongside `build_runner`,
and `inject_compile` to your regular `dependencies`:

```yaml
dependencies:
  inject_compile: ^0.9.0

dev_dependencies:
  build_runner: ^2.4.0
  inject_compile_generator: ^0.9.0
```

## Running the Generator

To generate the DI files, run the build runner command in your project directory:

```bash
dart run build_runner build
```

To continuously watch files and regenerate them during development:

```bash
dart run build_runner watch
```

## How It Works

The code generator runs in two phases to optimize build speed:

1.  **Summary Extraction**: First, a `SummaryBuilder` extracts metadata from
    `@provide`, `@module`, and `@injector` annotations into lightweight
    `.inject.summary` cache files.
2.  **Code Generation**: Next, an `InjectBuilder` reads these summaries, resolves
    the complete dependency tree, validates it for issues like circular
    dependencies, and outputs concrete `.inject.dart` implementations using
    `code_builder`.

Since validation occurs at compile-time, errors such as missing dependencies or
dependency cycles are reported directly during the build process, preventing
runtime exceptions.

## Next Steps

*   To learn how to define your object graph, visit the `inject_compile` annotations library.
*   For complete samples, see the workspace examples.
