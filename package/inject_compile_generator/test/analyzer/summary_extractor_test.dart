import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:inject_compile_generator/src/analyzer/summary_extractor.dart';
import 'package:inject_compile_generator/src/models/summary.dart';
import 'package:test/test.dart';

void main() {
  group('SummaryExtractor', () {
    test('extracts modules and providers', () async {
      final library = await resolveSources(
        {
          'inject_compile|lib/src/annotations.dart': '''
          class Module { const Module(); }
          class Provide { const Provide(); }
          class Singleton { const Singleton(); }
          class Asynchronous { const Asynchronous(); }
          class Injector { final List<Type> modules; const Injector({this.modules}); }
          class Qualifier { const Qualifier(); }
        ''',
          'inject_compile|lib/inject_compile.dart': '''
          import 'src/annotations.dart';
          export 'src/annotations.dart';
          const module = Module();
          const provide = Provide();
          const singleton = Singleton();
          const asynchronous = Asynchronous();
          const injector = Injector();
        ''',
          'a|lib/a.dart': '''
          import 'package:inject_compile/inject_compile.dart';
          
          @module
          class MyModule {
            @provide
            String provideString() => 'hello';
          }
        ''',
        },
        (resolver) async {
          return await resolver.libraryFor(AssetId('a', 'lib/a.dart'));
        },
      );

      final extractor = SummaryExtractor(library);
      final summary = extractor.extract();

      expect(summary.modules, hasLength(1));
      expect(summary.modules.first.clazz.symbol, 'MyModule');
    });

    test('extracts inherited modules and providers', () async {
      final library = await resolveSources(
        {
          'inject_compile|lib/src/annotations.dart': '''
          class Module { const Module(); }
          class Provide { const Provide(); }
        ''',
          'inject_compile|lib/inject.dart': '''
          import 'src/annotations.dart';
          export 'src/annotations.dart';
          const module = Module();
          const provide = Provide();
        ''',
          'a|lib/a.dart': '''
          import 'package:inject_compile/inject.dart';
          
          class BaseModule {
            @provide
            String provideBase() => 'base';
          }

          @module
          class ChildModule extends BaseModule {
            @provide
            int provideInt() => 42;
          }
        ''',
        },
        (resolver) async {
          return await resolver.libraryFor(AssetId('a', 'lib/a.dart'));
        },
      );

      final extractor = SummaryExtractor(library);
      final summary = extractor.extract();

      expect(summary.modules, hasLength(1));
      final module = summary.modules.first;
      expect(module.clazz.symbol, 'ChildModule');
      expect(module.providers, hasLength(2));
      expect(module.providers.any((p) => p.name == 'provideBase'), isTrue);
      expect(module.providers.any((p) => p.name == 'provideInt'), isTrue);
    });

    test('extracts qualifiers with names', () async {
      final library = await resolveSources(
        {
          'inject_compile|lib/src/annotations.dart': '''
          class Module { const Module(); }
          class Provide { const Provide(); }
          class Qualifier { final Symbol name; const Qualifier(this.name); }
        ''',
          'inject_compile|lib/inject.dart': '''
          import 'src/annotations.dart';
          export 'src/annotations.dart';
          const module = Module();
          const provide = Provide();
        ''',
          'a|lib/a.dart': '''
          import 'package:inject_compile/inject.dart';
          
          const manual = Qualifier(#manual);

          @module
          class MyModule {
            @provide
            @manual
            String provideString() => 'hello';
          }
        ''',
        },
        (resolver) async {
          return await resolver.libraryFor(AssetId('a', 'lib/a.dart'));
        },
      );

      final extractor = SummaryExtractor(library);
      final summary = extractor.extract();

      final provider = summary.modules.first.providers.first;
      expect(provider.resultType.lookupKey.qualifier?.symbol, 'manual');
    });

    test('extracts function types as providers', () async {
      final library = await resolveSources(
        {
          'inject_compile|lib/src/annotations.dart': '''
          class Module { const Module(); }
          class Provide { const Provide(); }
        ''',
          'inject_compile|lib/inject.dart': '''
          import 'src/annotations.dart';
          export 'src/annotations.dart';
          const module = Module();
          const provide = Provide();
        ''',
          'a|lib/a.dart': '''
          import 'package:inject_compile/inject.dart';
          
          typedef String MyProvider();

          @module
          class MyModule {
            @provide
            int provideInt(MyProvider provider) => 42;
          }
        ''',
        },
        (resolver) async {
          return await resolver.libraryFor(AssetId('a', 'lib/a.dart'));
        },
      );

      final extractor = SummaryExtractor(library);
      final summary = extractor.extract();

      final provider = summary.modules.first.providers.first;
      final dependency = provider.dependencies.first;
      expect(dependency.isProvider, isTrue);
      expect(dependency.lookupKey.root.symbol, 'String');
    });

    test('extracts injector with modules and getters', () async {
      final library = await resolveSources(
        {
          'inject_compile|lib/src/annotations.dart': '''
          class Module { const Module(); }
          class Provide { const Provide(); }
          class Injector { final List<Type> modules; const Injector({this.modules = const []}); }
        ''',
          'inject_compile|lib/inject.dart': '''
          import 'src/annotations.dart';
          export 'src/annotations.dart';
          const module = Module();
          const provide = Provide();
        ''',
          'a|lib/a.dart': '''
          import 'package:inject_compile/inject.dart';
          
          @module
          class MyModule {}
          
          @Injector(modules: [MyModule])
          abstract class MyInjector {
            @provide
            String get stringProvider;
            
            int intProvider();
          }
        ''',
        },
        (resolver) async =>
            await resolver.libraryFor(AssetId('a', 'lib/a.dart')),
      );

      final extractor = SummaryExtractor(library);
      final summary = extractor.extract();

      expect(summary.injectors, hasLength(1));
      final injector = summary.injectors.first;
      expect(injector.clazz.symbol, 'MyInjector');
      expect(injector.modules, hasLength(1));
      expect(injector.modules.first.symbol, 'MyModule');
      expect(injector.providers, hasLength(2));

      final stringP = injector.providers.firstWhere(
        (p) => p.name == 'stringProvider',
      );
      expect(stringP.kind, ProviderKind.getter);

      final intP = injector.providers.firstWhere(
        (p) => p.name == 'intProvider',
      );
      expect(intP.kind, ProviderKind.method);
    });

    test('extracts injectable class (provide on class)', () async {
      final library = await resolveSources(
        {
          'inject_compile|lib/src/annotations.dart':
              'class Provide { const Provide(); }',
          'inject_compile|lib/inject.dart':
              "import 'src/annotations.dart'; export 'src/annotations.dart'; const provide = Provide();",
          'a|lib/a.dart': '''
          import 'package:inject_compile/inject.dart';
          
          @provide
          class MyInjectable {}
        ''',
        },
        (resolver) async =>
            await resolver.libraryFor(AssetId('a', 'lib/a.dart')),
      );

      final extractor = SummaryExtractor(library);
      final summary = extractor.extract();

      expect(summary.injectables, hasLength(1));
      expect(summary.injectables.first.clazz.symbol, 'MyInjectable');
      expect(
        summary.injectables.first.constructor.kind,
        ProviderKind.constructor,
      );
    });

    test('extracts inherited injector providers', () async {
      final library = await resolveSources({
        'inject_compile|lib/src/annotations.dart':
            'class Injector { final List<Type> modules; const Injector({this.modules = const []}); }',
        'inject_compile|lib/inject.dart':
            "import 'src/annotations.dart'; export 'src/annotations.dart'; const injector = Injector();",
        'a|lib/a.dart': '''
          import 'package:inject_compile/inject.dart';
          
          abstract class BaseInjector {
            String get stringProvider;
          }
          
          @injector
          abstract class MyInjector extends BaseInjector {}
        ''',
      }, (resolver) async => await resolver.libraryFor(AssetId('a', 'lib/a.dart')));

      final extractor = SummaryExtractor(library);
      final summary = extractor.extract();

      expect(summary.injectors, hasLength(1));
      final injector = summary.injectors.first;
      expect(injector.providers, hasLength(1));
      expect(injector.providers.first.name, 'stringProvider');
    });

    test('extracts asynchronous provider and unwraps Future', () async {
      final library = await resolveSources(
        {
          'inject_compile|lib/src/annotations.dart': '''
          class Module { const Module(); }
          class Provide { const Provide(); }
          class Asynchronous { const Asynchronous(); }
        ''',
          'inject_compile|lib/inject.dart': '''
          import 'src/annotations.dart'; export 'src/annotations.dart';
          const module = Module(); const provide = Provide(); const asynchronous = Asynchronous();
        ''',
          'a|lib/a.dart': '''
          import 'dart:async';
          import 'package:inject_compile/inject.dart';
          
          @module
          class MyModule {
            @provide
            @asynchronous
            Future<String> provideAsyncString() async => 'hello';
          }
        ''',
        },
        (resolver) async =>
            await resolver.libraryFor(AssetId('a', 'lib/a.dart')),
      );

      final extractor = SummaryExtractor(library);
      final summary = extractor.extract();

      final provider = summary.modules.first.providers.first;
      expect(provider.isAsynchronous, isTrue);
      // The Future<String> should be unwrapped to String
      expect(provider.resultType.lookupKey.root.symbol, 'String');
    });

    group('validation errors', () {
      Future<void> expectError(String code) async {
        final library = await resolveSources(
          {
            'inject_compile|lib/src/annotations.dart': '''
            class Module { const Module(); }
            class Provide { const Provide(); }
            class Singleton { const Singleton(); }
            class Asynchronous { const Asynchronous(); }
            class Injector { final List<Type> modules; const Injector({this.modules = const []}); }
          ''',
            'inject_compile|lib/inject.dart': '''
            import 'src/annotations.dart';
            export 'src/annotations.dart';
            const module = Module();
            const provide = Provide();
            const singleton = Singleton();
            const asynchronous = Asynchronous();
          ''',
            'a|lib/a.dart':
                "import 'package:inject_compile/inject.dart';\n$code",
          },
          (resolver) async =>
              await resolver.libraryFor(AssetId('a', 'lib/a.dart')),
        );
        final extractor = SummaryExtractor(library);
        expect(
          () => extractor.extract(),
          throwsA(anything),
        ); // InvalidGenerationSourceError
      }

      test(
        'multiple annotations on class',
        () => expectError('''
        @module @provide class BadClass {}
      '''),
      );

      test(
        '@singleton on class without @provide',
        () => expectError('''
        @singleton class BadClass {}
      '''),
      );

      test(
        '@asynchronous on class',
        () => expectError('''
        @asynchronous @provide class BadClass {}
      '''),
      );

      test(
        '@asynchronous on constructor',
        () => expectError('''
        class BadClass { @asynchronous @provide BadClass(); }
      '''),
      );

      test(
        '@singleton on constructor without @provide',
        () => expectError('''
        class BadClass { @singleton BadClass(); }
      '''),
      );

      test(
        '@singleton on method without @provide',
        () => expectError('''
        @module class MyModule { @singleton int badMethod() => 1; }
      '''),
      );

      test(
        '@singleton on getter without @provide',
        () => expectError('''
        @module class MyModule { @singleton int get badGetter => 1; }
      '''),
      );

      test(
        '@asynchronous on getter',
        () => expectError('''
        @module class MyModule { @asynchronous @provide int get badGetter => 1; }
      '''),
      );
    });
  });
}
