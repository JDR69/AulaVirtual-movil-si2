// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_aula_virtual_app/main.dart';

void main() {
  testWidgets('Login navigation to Dashboard test', (
    WidgetTester tester,
  ) async {
    // Construir la aplicación y mostrar la pantalla inicial (Login).
    await tester.pumpWidget(MyApp());

    // Verificar que la pantalla de Login se muestra.
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);

    // Ingresar credenciales correctas.
    await tester.enterText(find.byType(TextField).at(0), 'admin'); // Usuario
    await tester.enterText(find.byType(TextField).at(1), '1234'); // Contraseña

    // Tocar el botón de "Iniciar Sesión".
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pumpAndSettle(); // Esperar a que la navegación termine.

    // Verificar que la pantalla del Dashboard se muestra.
    expect(find.text('Dashboard - Aula Virtual'), findsOneWidget);
    expect(find.text('Calificaciones'), findsOneWidget);
    expect(find.text('Actividades'), findsOneWidget);
    expect(find.text('Libretas'), findsOneWidget);
  });
}
