import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/Login.dart';
import 'screens/Home.dart';
import 'screens/Grades.dart';
import 'screens/Activities.dart';
import 'screens/Notebooks.dart';
import 'screens/user_profile_screen.dart';
import 'provider/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/activities': (context) => ActivitiesScreen(),
        '/grades': (context) => GradesScreen(),
        '/profile': (context) => UserProfileScreen(),
      },
    );
  }
}
