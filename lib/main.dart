import 'package:flutter/material.dart';
import 'screens/Login.dart';
import 'screens/Home.dart';
import 'screens/Grades.dart';
import 'screens/Activities.dart';
import 'screens/Notebooks.dart';
import 'screens/user_profile_screen.dart'; // Importa la pantalla de perfil
import 'models/user_profile.dart'; // Importa el modelo de datos del usuario

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
        '/profile': (context) => UserProfileScreen(
          user: UserProfile(
            name: 'Juan Pérez',
            gender: 'Masculino',
            role: 'Estudiante',
            birthDate: DateTime(2000, 5, 28),
            phone: '123456789',
          ),
        ), // Perfil de Usuario
      },
    );
  }
}
