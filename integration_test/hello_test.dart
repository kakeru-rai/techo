import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;

void main() {
  testWidgets('failing test example', (tester) async {
    app.main();
    expect(2 + 2, equals(5));
  });
}
