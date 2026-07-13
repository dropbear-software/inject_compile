import 'package:meta/meta.dart';

/// A reserved name that can be used alongside a [provide] annotation to further
/// specify the key.
///
/// [Qualifier] must be placed at the same level as a `@provide` annotation. It
/// is **illegal** to have more than one [Qualifier] for a given provider.
///
/// # Example
/// ```dart
/// const baseUri = const Qualifier(#baseUri);
///
/// abstract class RpcModule {
///   @provide
///   @baseUri
///   String provideBaseUri() => 'https://foo.bar/service/v2';
/// }
/// ```
///
/// The symbol `#baseUri` AND `String` are used to form the key in the
/// dependency tree.
@immutable
class Qualifier {
  /// Unique name of the identifier.
  final Symbol name;

  /// Create a named provider qualifier from [name].
  @literal
  const Qualifier(this.name);
}

/// Annotates a class as a collection of providers for dependency injection.
///
/// A class annotated with [module] is a class that can be used to insert
/// dependencies into the object graph. Modules may extend or mixin other
/// modules, or rely on composition to fill in dependencies. Methods can have
/// parameters that are in the object graph and will be invoked with the objects
/// created from the [Injector] the module is installed on.
///
/// An example:
///
/// ```dart
/// @module
/// class CarModule {
///   @provide
///   Car provideCar(Manufacturer manufacturer) =>
///       Car(manufacturer: manufacturer, year: 2019);
/// }
/// ```
///
/// In this instance, an injector that includes `CarModule` will know how to
/// provide an instance of `Car`, given that all parameters of `provideCar` are
/// satisfied in the final object graph.
const module = Module._();

/// **INTERNAL ONLY**: Might be exposed if we add flags or other properties.
@visibleForTesting
class Module {
  const Module._();
}

/// Annotation for a method (in an [Injector] or [module]), class, or
/// constructor that provides an instance.
///
/// - If the annotation is on a class or constructor, the class is entered into
///   the dependency graph and its constructor's arguments are injected when the
///   class is injected.
/// - If the annotation is on a method in a module, the return type is entered
///   into the dependency graph. The method will be executed with injected
///   arguments when the return type is injected.
/// - If the annotation is on an [Injector], this indicates that the injector
///   should provide instances of the type when the method is called.
///
/// The type provided by this annotation can be further specified by including a
/// [Qualifier] annotation.
const provide = Provide._();

/// **INTERNAL ONLY**: Might be exposed if we add flags or other properties.
@visibleForTesting
class Provide {
  const Provide._();
}

/// An injectable class or module provider that provides a single instance.
///
/// A dependency annotated with [singleton] will only be instantiated once. The
/// same instance will be used to satisfy all dependencies.
///
/// For example:
/// ```dart
/// @provide
/// @singleton
/// class Foo {}
///
/// @injector
/// abstract class FooMaker {
///   static final create = FooMaker$Injector.create;
///
///   // identical(getFoo(), getFoo()) is guaranteed to be true.
///   Foo getFoo();
/// }
/// ```
const singleton = Singleton._();

/// **INTERNAL ONLY**: Might be exposed if we add flags or other properties.
@visibleForTesting
class Singleton {
  const Singleton._();
}

/// Annotates a module provider method that returns a `Future`.
///
/// Such a provider is referred to as _asynchronous provider_. Asynchronous
/// providers are resolved from futures into dependency instances prior to
/// returning the injector to the application.
///
/// For example:
/// ```dart
/// @module
/// abstract class CarModule {
///   @provide
///   @asynchronous
///   Future<Car> provideCar();
/// }
///
/// class Dealership {
///   @provide
///   Dealership(Car car);
/// }
/// ```
///
/// Note that in the example `Dealership` depends on `Car` rather than
/// `Future<Car>`. This is the quintessential property of the [asynchronous]
/// annotation. It guarantees that `Future<Car>` is resolved into `Car`
/// _prior to_ instantiating objects that depend on it.
///
/// If you wish to inject the `Future` itself without resolving it, simply
/// omit this annotation and the `Future` will be treated as a normal type, and
/// the framework will not attempt to resolve it.
const asynchronous = Asynchronous._();

/// **INTERNAL ONLY**: Might be exposed if we add flags or other properties.
@visibleForTesting
class Asynchronous {
  const Asynchronous._();
}

/// Annotates an abstract class used as a blueprint to generate an injector.
///
/// Example:
/// ```dart
/// import 'coffee_shop.inject.dart';
///
/// @Injector([DripCoffeeModule])
/// abstract class CoffeeShop {
///   static final create = CoffeeShop$Injector.create;
///
///   CoffeeMaker get coffeeMaker;
/// }
///
/// main() async {
///   var coffeeShop = await CoffeeShop.create(DripCoffeeModule());
///   print(coffeeShop.coffeeMaker.brewCoffee());
/// }
/// ```
///
/// In the example, we define an injector class `CoffeeShop`, which provides a
/// `CoffeeMaker`. It uses `DripCoffeeModule` as a source of dependency
/// providers for the injector.
///
/// The framework generates a concrete class `CoffeeShop$Injector` that has a
/// static asynchronous function named `create`, which takes `DripCoffeeModule`
/// as an argument and returns a `Future<CoffeeShop>`.
///
/// `CoffeeShop` defines `static final create` as a convenience accessor to
/// `CoffeeShop$Injector.create`. This is not strictly necessary, but useful to
/// hide the generated code from the call sites.
class Injector {
  /// Modules supplying providers for the injector.
  ///
  /// Each [Type] must be a `class` definition annotated with [module].
  final List<Type> modules;

  /// Create a blueprint for an injector.
  @literal
  const Injector([this.modules = const <Type>[]]);
}

/// An annotation to mark something as an [Injector] with no included modules.
const injector = Injector();
