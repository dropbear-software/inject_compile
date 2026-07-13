# Clean Architecture & Compile-Time DI Example

This package provides a canonical example of implementing **Clean Architecture**
in Dart, utilizing `inject_compile` for compile-time dependency injection.

The purpose of this example is to demonstrate how to rigorously decouple your
application into layers using abstract interfaces, and how to seamlessly stitch
those layers back together using `@module` and `@Injector`.

## The Application: Clean Notes

The example is a simple Command-Line Interface (CLI) application that allows
users to perform CRUD operations on a single resource: a **Note**.

## Architecture Layers

This project strictly adheres to the Clean Architecture dependency rule:
*dependencies can only point inwards*.

### 1. Domain (`lib/domain/`)
The innermost layer. It contains pure business logic and knows absolutely
nothing about databases, APIs, or user interfaces.
*   **Entities**: The `Note` data structure.
*   **Repositories (Interfaces)**: An abstract `NoteRepository` defining how
    notes can be stored and retrieved.
*   **Use Cases**: Single-responsibility classes like `CreateNoteUseCase` and
    `GetNotesUseCase` that orchestrate business logic using repository
    interfaces.

### 2. Data (`lib/data/`)
The infrastructure layer. It implements the interfaces defined by the Domain.
*   **Data Sources**: Contains the actual data access logic (in this case, an
    `InMemoryNoteDataSource`).
*   **Repositories (Implementations)**: `NoteRepositoryImpl` implements the
    Domain's `NoteRepository` and coordinates with the data sources.

### 3. Presentation (`lib/presentation/`)
The user interface layer.
*   **Controllers**: `NoteController` is injected with Use Cases and handles the
    interaction between user input and domain logic.
*   **View**: `CliView` provides a simple REPL (Read-Eval-Print Loop) for the
    user to interact with the application.

### 4. Dependency Injection (`lib/di/`)
The outermost boundary where `inject_compile` shines.
*   **Modules**: `DataModule` explicitly binds the abstract `NoteRepository` to
    the concrete `NoteRepositoryImpl`. This is where **Dependency Inversion**
    happens.
*   **Injector**: `AppInjector` defines the root component (`CliView`) and
    instructs the framework to resolve the entire dependency graph.

## Running the Example

Because `inject_compile` operates at compile-time, you must first generate the
dependency injection wiring using `build_runner`.

1.  Generate the `.inject.dart` files:
    ```bash
    dart run build_runner build
    ```

2.  Run the application:
    ```bash
    dart run bin/main.dart
    ```
