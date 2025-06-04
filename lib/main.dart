import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/Login.dart';
import 'screens/Home.dart';
import 'screens/Grades.dart';
import 'screens/Activities.dart';
import 'screens/Licencias.dart';
import 'screens/user_profile_screen.dart';
import 'screens/libreta_ia_screen.dart'; // Nueva pantalla
import 'screens/Notificaciones.dart';
import 'provider/user_provider.dart';
import 'provider/student_perfomance_provider.dart'; // Nuevo proveedor
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Instancia global para notificaciones locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Función para manejar notificaciones en segundo plano.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Mensaje en segundo plano: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inicializar notificaciones locales
    await _initializeLocalNotifications();

    // Registra la función para mensajes en segundo plano.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(
            create: (_) => StudentPerformanceProvider(),
          ), // Nuevo proveedor
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error inicializando Firebase: $e');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(
            create: (_) => StudentPerformanceProvider(),
          ), // Nuevo proveedor
        ],
        child: const MyApp(),
      ),
    );
  }
}

Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Crear canal de notificación para Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

Future<void> _setupFirebaseMessaging(BuildContext context) async {
  try {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

    print('Permisos de notificación: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print('Token FCM: $fcmToken');

      Provider.of<UserProvider>(
        context,
        listen: false,
      ).setFcmToken(fcmToken ?? '');

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('Nuevo token FCM: $newToken');
        _sendTokenToServer(newToken);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Mensaje recibido en primer plano: ${message.messageId}');
        print('Título: ${message.notification?.title}');
        print('Cuerpo: ${message.notification?.body}');
        _showForegroundNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App abierta desde notificación: ${message.messageId}');
        _handleNotificationTap(message);
      });

      RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        print(
          'App abierta desde notificación inicial: ${initialMessage.messageId}',
        );
        _handleNotificationTap(initialMessage);
      }
    }
  } catch (e) {
    print('Error configurando Firebase Messaging: $e');
  }
}

void _showForegroundNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: false,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? 'Nueva notificación',
    message.notification?.body ?? 'Has recibido un nuevo mensaje',
    platformChannelSpecifics,
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _handleNotificationTap(RemoteMessage message) {
  // Manejar la navegación cuando se toca una notificación
  print('Manejando tap de notificación: ${message.data}');

  // Navegar a la pantalla de notificaciones
  navigatorKey.currentState?.pushNamed('/notificaciones');
}

void _sendTokenToServer(String token) {
  // Aquí implementarías el envío del token a tu servidor
  print('Enviando token al servidor: $token');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Una vez construido el widget, usamos addPostFrameCallback para tener acceso al context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupFirebaseMessaging(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Añadir esta línea
      title: 'Aula Virtual',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/grades': (context) => GradesScreen(),
        '/activities': (context) => ActivitiesScreen(),
        '/licencias': (context) => LicenciasScreen(),
        '/profile': (context) => UserProfileScreen(),
        '/libretaia': (context) => LibretaIAScreen(),
        '/notificaciones': (context) => NotificacionesScreen(),
      },
    );
  }
}
