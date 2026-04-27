import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/app.dart';
import 'package:panaderia_erp/data/database/app_database.dart';

void main() {
  testWidgets('app starts with products and sales tabs', (WidgetTester tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    addTearDown(database.close);

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pump();

    expect(find.text('Panaderia ERP'), findsOneWidget);
    expect(find.text('No hay productos registrados'), findsOneWidget);
    expect(find.text('Nuevo producto'), findsOneWidget);
    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Ventas'), findsOneWidget);
  });
}
