import 'package:inject_compile/inject_compile.dart';
import 'package:test/test.dart';

void main() {
  group('Annotations', () {
    test('provide is a constant', () {
      expect(provide, isNotNull);
    });
  });
}
