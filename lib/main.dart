import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/Login.dart';
import 'screens/Home.dart';
import 'screens/Grades.dart';
import 'screens/Activities.dart';
import 'screens/Notebooks.dart';
import 'screens/user_profile_screen.dart';
import 'provider/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aula Virtual',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/grades': (context) => GradesScreen(),
        '/activities': (context) => ActivitiesScreen(),
        '/notebooks': (context) => NotebooksScreen(),
        '/profile': (context) => UserProfileScreen(),
      },
    );
  }
}