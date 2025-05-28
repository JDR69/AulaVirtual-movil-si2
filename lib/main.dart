import 'package:flutter/material.dart';
import 'screens/Login.dart';
import 'screens/Home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aula Virtual',
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => LoginScreen(), // Pantalla de Login
        '/home': (context) => HomeScreen(), // Dashboard
      },
    );
  }
}
