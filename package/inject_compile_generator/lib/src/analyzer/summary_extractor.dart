import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import '../models/summary.dart';
import '../models/symbol_path.dart';
import 'utils.dart';

const moduleChecker = TypeChecker.fromUrl(
  'package:inject_compile/src/annotations.dart#Module',
);
const provideChecker = TypeChecker.fromUrl(
  'package:inject_compile/src/annotations.dart#Provide',
);
const singletonChecker = TypeChecker.fromUrl(
  'package:inject_compile/src/annotations.dart#Singleton',
);
const asynchronousChecker = TypeChecker.fromUrl(
  'package:inject_compile/src/annotations.dart#Asynchronous',
);
const injectorChecker = TypeChecker.fromUrl(
  'package:inject_compile/src/annotations.dart#Injector',
);
const qualifierChecker = TypeChecker.fromUrl(
  'package:inject_compile/src/annotations.dart#Qualifier',
);

/// Scans a library and extracts injection metadata.
class SummaryExtractor {
  final LibraryElement library;

  SummaryExtractor(this.library);

  LibrarySummary extract() {
    final visitor = _SummaryVisitor();
    library.accept(visitor);
    return LibrarySummary(
      assetUri: library.firstFragment.source.uri.toString(),
      modules: visitor.modules,
      injectors: visitor.injectors,
      injectables: visitor.injectables,
    );
  }
}

class _SummaryVisitor extends RecursiveElementVisitor2<void> {
  final List<ModuleSummary> modules = [];
  final List<InjectorSummary> injectors = [];
  final List<InjectableSummary> injectables = [];

  @override
  void visitClassElement(ClassElement element) {
    final isModule = moduleChecker.hasAnnotationOfExact(element);
    final isInjector = injectorChecker.hasAnnotationOfExact(element);
    final isProvide = provideChecker.hasAnnotationOfExact(element);
    final isSingleton = singletonChecker.hasAnnotationOfExact(element);

    final annotationCount =
        (isModule ? 1 : 0) + (isInjector ? 1 : 0) + (isProvide ? 1 : 0);
    if (annotationCount > 1) {
      throw InvalidGenerationSourceError(
        'A class may be an injectable, a module or an injector, '
        'but not more than one of these types.',
        element: element,
      );
    }

    if (isSingleton && !isProvide) {
      throw InvalidGenerationSourceError(
        'A class cannot be annotated with @singleton '
        'without also being annotated with @provide.',
        element: element,
      );
    }

    if (asynchronousChecker.hasAnnotationOfExact(element)) {
      throw InvalidGenerationSourceError(
        'Classes and constructors cannot be annotated with @asynchronous.',
        element: element,
      );
    }

    for (final constructor in element.constructors) {
      if (asynchronousChecker.hasAnnotationOfExact(constructor)) {
        throw InvalidGenerationSourceError(
          'Classes and constructors cannot be annotated with @asynchronous.',
          element: constructor,
        );
      }
      if (singletonChecker.hasAnnotationOfExact(constructor) &&
          !provideChecker.hasAnnotationOfExact(constructor) &&
          !isProvide) {
        throw InvalidGenerationSourceError(
          'A constructor cannot be annotated with @singleton '
          'without also being annotated with @provide.',
          element: constructor,
        );
      }
    }

    if (isModule) {
      modules.add(_extractModule(element));
    } else if (isInjector) {
      injectors.add(_extractInjector(element));
    } else if (isProvide) {
      // Check if it's an injectable class (provide on constructor)
      // or if it's just a provide on the class (which might be legacy or error)
      final constructor = element.unnamedConstructor;
      if (constructor != null) {
        injectables.add(
          InjectableSummary(
            clazz: getSymbolPath(element),
            constructor: _extractProvider(
              constructor,
              ProviderKind.constructor,
            ),
          ),
        );
      }
    }
    super.visitClassElement(element);
  }

  ModuleSummary _extractModule(ClassElement element) {
    final providers = <ProviderSummary>[];

    // Original visits all supertypes (except Object) to support inheritance/mixins.
    for (final type in element.allSupertypes) {
      if (type.isDartCoreObject) continue;
      final typeElement = type.element;
      if (typeElement is ClassElement) {
        _collectProviders(typeElement, providers);
      }
    }
    _collectProviders(element, providers);

    return ModuleSummary(clazz: getSymbolPath(element), providers: providers);
  }

  void _collectProviders(
    ClassElement element,
    List<ProviderSummary> providers,
  ) {
    for (final method in element.methods) {
      if (provideChecker.hasAnnotationOfExact(method)) {
        providers.add(_extractProvider(method, ProviderKind.method));
      } else if (singletonChecker.hasAnnotationOfExact(method)) {
        throw InvalidGenerationSourceError(
          'A method cannot be annotated with @singleton '
          'without also being annotated with @provide.',
          element: method,
        );
      }
    }
    for (final getter in element.getters) {
      if (provideChecker.hasAnnotationOfExact(getter)) {
        providers.add(_extractProvider(getter, ProviderKind.getter));
      } else if (singletonChecker.hasAnnotationOfExact(getter)) {
        throw InvalidGenerationSourceError(
          'A getter cannot be annotated with @singleton '
          'without also being annotated with @provide.',
          element: getter,
        );
      }
    }
  }

  InjectorSummary _extractInjector(ClassElement element) {
    final annotation = injectorChecker.firstAnnotationOfExact(element);
    final reader = ConstantReader(annotation);
    final moduleList = reader.read('modules').listValue;

    final modulePaths = moduleList
        .map((obj) => obj.toTypeValue()?.element)
        .whereType<Element>()
        .map(getSymbolPath)
        .toList();

    final providers = <ProviderSummary>[];

    // Injectors also inherit abstract methods as providers.
    for (final type in element.allSupertypes) {
      if (type.isDartCoreObject) continue;
      final typeElement = type.element;
      if (typeElement is ClassElement) {
        _collectInjectorProviders(typeElement, providers);
      }
    }
    _collectInjectorProviders(element, providers);

    return InjectorSummary(
      clazz: getSymbolPath(element),
      modules: modulePaths,
      providers: providers,
    );
  }

  void _collectInjectorProviders(
    ClassElement element,
    List<ProviderSummary> providers,
  ) {
    for (final method in element.methods) {
      if (method.isAbstract || provideChecker.hasAnnotationOfExact(method)) {
        providers.add(_extractProvider(method, ProviderKind.method));
      }
    }
    for (final getter in element.getters) {
      if (getter.isAbstract || provideChecker.hasAnnotationOfExact(getter)) {
        providers.add(_extractProvider(getter, ProviderKind.getter));
      }
    }
  }

  ProviderSummary _extractProvider(
    ExecutableElement element,
    ProviderKind kind,
  ) {
    if (kind == ProviderKind.getter &&
        asynchronousChecker.hasAnnotationOfExact(element)) {
      throw InvalidGenerationSourceError(
        'Getters cannot be annotated with @asynchronous.',
        element: element,
      );
    }

    final enclosing = element.enclosingElement;
    final isSingleton =
        singletonChecker.hasAnnotationOfExact(element) ||
        (enclosing is ClassElement &&
            singletonChecker.hasAnnotationOfExact(enclosing));
    final isAsynchronous = asynchronousChecker.hasAnnotationOfExact(element);

    var returnType = switch (element) {
      MethodElement e => e.returnType,
      ConstructorElement e => e.returnType,
      PropertyAccessorElement e => e.returnType,
      _ => null,
    };

    if (isAsynchronous && returnType is InterfaceType) {
      if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
        if (returnType.typeArguments.isNotEmpty) {
          returnType = returnType.typeArguments.first;
        }
      }
    }

    if (returnType == null) {
      throw StateError(
        'Could not determine return type for provider ${element.name}',
      );
    }

    final dependencies = element.formalParameters.map((p) {
      return getInjectedType(p.type, qualifier: _extractQualifier(p));
    }).toList();

    return ProviderSummary(
      name: element.name!,
      resultType: getInjectedType(
        returnType,
        qualifier: _extractQualifier(element),
      ),
      kind: kind,
      isSingleton: isSingleton,
      isAsynchronous: isAsynchronous,
      dependencies: dependencies,
    );
  }

  SymbolPath? _extractQualifier(Element element) {
    // Check if any annotation is a Qualifier or has a Qualifier annotation itself.
    for (final annotation in element.metadata.annotations) {
      final value = annotation.computeConstantValue();
      if (value == null) continue;

      final type = value.type;
      if (type == null) continue;

      if (qualifierChecker.isExactlyType(type)) {
        // This is a @Qualifier annotation. Extract the 'name' (Symbol).
        final symbol = value.getField('name')?.toSymbolValue();
        if (symbol != null) {
          return SymbolPath.global(symbol);
        }
      }
    }
    return null;
  }
}
