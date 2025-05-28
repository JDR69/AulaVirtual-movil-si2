import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  // Función para realizar el login con CI
  Future<Map<String, dynamic>> login(String ci, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/usuario/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ci': ci, // Enviar el CI
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  // Ejemplo de función para obtener datos del backend
  Future<dynamic> fetchUserProfile(String userId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener el perfil de usuario');
    }
  }
}