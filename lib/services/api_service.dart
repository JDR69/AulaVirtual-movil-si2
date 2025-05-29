import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL correcta del backend
  static const String baseUrl =
      'https://backendcolegio-production.up.railway.app';
  static String? token;

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
}
