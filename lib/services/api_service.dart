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
  static Future<Map<String, dynamic>?> login(String ci, String password) async {
    print('Intentando login con CI: $ci y password: $password');

    try {
      // Construir el cuerpo de la petición exactamente como espera el backend
      final Map<String, dynamic> requestBody = {'ci': ci, 'password': password};

      print('Body de petición: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/usuario/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Guardar token para futuras peticiones
        if (data.containsKey('access')) {
          token = data['access'];
          print('Token obtenido: $token');
        } else {
          print('ADVERTENCIA: No se encontró token en la respuesta');
        }
        return data;
      } else {
        // Imprimir detalles del error
        print(
          'Error en login - Código: ${response.statusCode}, Mensaje: ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      // Capturar la excepción con más detalles
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
      final response = await http.get(
        Uri.parse('$baseUrl/api/usuario/obtenerUsuario/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        'obtenerUsuario - Código: ${response.statusCode}, Respuesta: ${response.body}',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Error obtenerUsuario: ${response.statusCode} - ${response.body}',
        );
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
}
