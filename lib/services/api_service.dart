import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL correcta del backend
  static const String baseUrl =
      'https://backendcolegio-production.up.railway.app';
  static String? token;

  // Tiempo de espera para las peticiones (similar al timeout del front)
  static const Duration requestTimeout = Duration(seconds: 30);

  // Método para iniciar sesión - con manejo de errores mejorado
  static Future<Map<String, dynamic>?> login(
    String ci,
    String password,
    String fcmToken,
  ) async {
    print('Intentando login con CI: $ci y password: $password');

    try {
      final Map<String, dynamic> requestBody = {'ci': ci, 'password': password};
      print('Body de petición: ${jsonEncode(requestBody)}');

      // Realizar el login
      final response = await http.post(
        Uri.parse('$baseUrl/api/usuario/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      print('Código de respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('access')) {
          token = data['access'];
          print('Token obtenido: $token');

          // Ahora que se tiene un token válido, se envía el fcmToken:
          await ApiService.guardarNuevoToken(ci, fcmToken);
        } else {
          print('ADVERTENCIA: No se encontró token en la respuesta');
        }
        return data;
      } else {
        print(
          'Error en login - Código: ${response.statusCode}, Mensaje: ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      print('Excepción durante login: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Método para obtener datos del usuario
  static Future<Map<String, dynamic>?> obtenerUsuario() async {
    if (token == null) {
      print('Error: No hay token de autenticación disponible');
      return null;
    }

    try {
      final uri = Uri.parse('$baseUrl/api/usuario/obtenerUsuario/');
      print('Obteniendo datos del usuario...');

      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(requestTimeout);
  if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verificar que la respuesta contiene los datos necesarios
        if (data != null && data is Map<String, dynamic>) {
          if (data.containsKey('id') && data.containsKey('nombre')) {
            return data;
          } else {
            print('ERROR: Respuesta no contiene campos id o nombre');
            // Si la respuesta no tiene los campos esperados, imprimir todos los campos disponibles
            print('Campos disponibles: ${data.keys.toList()}');
            return null;
          }
        } else {
          print('ERROR: Formato de respuesta inesperado');
          return null;
        }
      } else if (response.statusCode == 401) {
        print('ERROR: Token expirado o inválido');
        // Aquí podrías implementar una renovación del token o forzar un nuevo login
        return null;
      } else {
        print('ERROR al obtener usuario - Código: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción obtenerUsuario: $e');
      return null;
    }
  }

  // Método para obtener notas de los alumnos por gestión
  static Future<List<dynamic>?> getStudentGradesBySession(
    String studentId,
    String gestion,
  ) async {
    if (token == null) {
      print('ERROR: No hay token disponible para hacer la petición de notas');
      return null;
    }

    try {
      // Construir la URL con el ID del estudiante y la gestión
      final uri = Uri.parse(
        '$baseUrl/api/evaluaciones/obtener-notas/$studentId/$gestion/',
      );

      print(
        'Solicitando notas para estudiante ID: $studentId, gestión: $gestion',
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(requestTimeout);

      print('Código de respuesta (notas del alumno): ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Notas obtenidas con éxito: ${data.length} registros');
        return data;
      } else {
        print(
          'Error al obtener notas - Código: ${response.statusCode}, Mensaje: ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      print('Excepción al obtener notas: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Método para obtener gestiones (años escolares)
  static Future<List<dynamic>?> getAcademicSessions() async {
    if (token == null) {
      print('ERROR: No hay token disponible para obtener gestiones');
      return null;
    }

    try {
      final uri = Uri.parse('$baseUrl/api/periodo/obtener-gestiones/');

      print('Solicitando gestiones académicas');

      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Gestiones obtenidas con éxito: ${data.length} registros');
        return data;
      } else {
        print(
          'Error al obtener gestiones - Código: ${response.statusCode}, Mensaje: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Excepción al obtener gestiones: $e');
      return null;
    }
  }

  // Método para obtener todos los usuarios (para buscar alumnos)
  static Future<List<dynamic>?> getAllUsers() async {
    if (token == null) {
      print('ERROR: No hay token disponible para obtener usuarios');
      return null;
    }

    try {
      final uri = Uri.parse('$baseUrl/api/usuario/obtenerUsuario/');

      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Usuarios obtenidos con éxito');
        return data is List ? data : [data];
      } else {
        print(
          'Error al obtener usuarios - Código: ${response.statusCode}, Mensaje: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Excepción al obtener usuarios: $e');
      return null;
    }
  }

  // Método para enviar el TokenFCM y CI al backend
  static Future<bool> guardarNuevoToken(String ci, String fcmToken) async {
    print('estoy aqui con el token: $fcmToken y ci: $ci');

    try {
      final uri = Uri.parse('$baseUrl/api/periodo/guardar-nuevo-token/');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'ci': ci, 'fcm_token': fcmToken}),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('TokenFCM guardado con éxito');
        return true;
      } else {
        print(
          'Error al guardar TokenFCM - Código: ${response.statusCode}, Mensaje: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Excepción al guardar TokenFCM: $e');
      return false;
    }
  }

  // Método para crear una nueva licencia
  static Future<Map<String, dynamic>?> crearLicencia({
    required String descripcion,
    required String fecha,
    required String imagen,
    required int alumno,
    required String nombreUsuario,
  }) async {
    if (token == null) {
      print('ERROR: No hay token disponible para crear licencia');
      return null;
    }

    try {
      final uri = Uri.parse('$baseUrl/api/periodo/crear-licencia/');
      final body = {
        'descripcion': descripcion,
        'fecha': fecha,
        'imagen': imagen,
        'alumno': alumno,
        'nombre_usuario': nombreUsuario,
      };

      print('Creando licencia con datos: $body');

      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Licencia creada con éxito');
        return jsonDecode(response.body);
      } else {
        print(
          'Error al crear licencia - Código: ${response.statusCode}, Mensaje: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Excepción al crear licencia: $e');
      return null;
    }
  }

  // Método para obtener notificaciones del usuario
  static Future<List<dynamic>?> getNotifications(int userId) async {
    if (token == null) {
      print('ERROR: No hay token disponible para obtener notificaciones');
      return null;
    }

    try {
      final uri = Uri.parse('$baseUrl/api/periodo/obtener-notificacion-uni/$userId/');

      print('Solicitando notificaciones para usuario ID: $userId');

      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(requestTimeout);

      print('Código de respuesta (notificaciones): ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Notificaciones obtenidas con éxito: ${data.length} registros');
        return data;
      } else {
        print(
          'Error al obtener notificaciones - Código: ${response.statusCode}, Mensaje: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Excepción al obtener notificaciones: $e');
      return null;
    }
  }
}
