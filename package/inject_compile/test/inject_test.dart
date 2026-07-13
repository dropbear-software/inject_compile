import 'package:inject_compile/inject.dart';
import 'package:test/test.dart';

void main() {
  group('Annotations', () {
    test('provide is a constant', () {
      expect(provide, isNotNull);
    });
  });
}
