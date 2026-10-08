import 'package:ask_my_docs/core/utils/responsive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Responsive.fromWidth', () {
    test('under 600 is compact (bottom navigation bar)', () {
      expect(Responsive.fromWidth(390), ScreenSize.compact);
      expect(Responsive.fromWidth(599), ScreenSize.compact);
    });

    test('600 to 899 is medium (navigation rail)', () {
      expect(Responsive.fromWidth(600), ScreenSize.medium);
      expect(Responsive.fromWidth(899), ScreenSize.medium);
    });

    test('900 and up is expanded (rail + centered content)', () {
      expect(Responsive.fromWidth(900), ScreenSize.expanded);
      expect(Responsive.fromWidth(1440), ScreenSize.expanded);
    });
  });
}
