import 'package:flutter_test/flutter_test.dart';
import 'package:media_alacarte/app.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const App());
  });
}
