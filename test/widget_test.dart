import 'package:flutter_test/flutter_test.dart';

import 'package:plant_life/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const PlantLife());
    await tester.pumpAndSettle();
  });
}
