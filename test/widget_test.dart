import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plant_life/core/di/service_locator.dart';
import 'package:plant_life/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
    await tester.pumpWidget(const PlantLife());
    await tester.pumpAndSettle();
    await sl.reset();
  });
}
