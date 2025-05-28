import 'package:flutter/material.dart';
import 'screens/Login.dart';
import 'screens/Home.dart';
import 'screens/Grades.dart';
import 'screens/Activities.dart';
import 'screens/Notebooks.dart';

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
        '/grades': (context) => GradesScreen(), // Calificaciones
        '/activities': (context) => ActivitiesScreen(), // Actividades
        '/notebooks': (context) => NotebooksScreen(), // Libretas
      },
    );
  }
}
