import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _perfilUsuario;
  List<dynamic>? _permisos;
  bool _isLoading = false;

  // <-- Nueva propiedad para el Token FCM
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Otros getters y propiedades...
  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? get perfilUsuario => _perfilUsuario;
  List<dynamic>? get permisos => _permisos;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  // Getters para información específica del usuario
  String get rolNombre => _user != null && _user!.containsKey('rol_nombre')
      ? _user!['rol_nombre']
      : '';

  void setUser(Map<String, dynamic> userData) {
    _user = userData;

    notifyListeners();
  }

  void setPermisos(List<dynamic> permisosData) {
    _permisos = permisosData;
    notifyListeners();
  }

  // <-- Nuevo método para guardar el Token FCM
  void setFcmToken(String token) {
    _fcmToken = token;
    print('FCM Token guardado en Provider: $_fcmToken');
    notifyListeners();
  }

  void logout() {
    _user = null;
    _perfilUsuario = null;
    _permisos = null;
    _fcmToken = null; // Limpiar token FCM
    notifyListeners();
  }

  Future<void> obtenerPerfilUsuario() async {
    if (!isLoggedIn) return;

    _isLoading = true;
    notifyListeners();

    try {
      final perfilData = await ApiService.obtenerUsuario();
      if (perfilData != null) {
        _perfilUsuario = perfilData;
        print('Perfil de usuario obtenido: $_perfilUsuario');
      }
    } catch (e) {
      print('Error al obtener perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para verificar si el usuario tiene cierto permiso
  bool tienePermiso(String nombrePermiso) {
    if (_permisos == null) return false;

    return _permisos!.any(
      (permiso) =>
          permiso['nombre'] == nombrePermiso && permiso['estado'] == true,
    );
  }
}
