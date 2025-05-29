import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Verificar si tenemos datos de usuario
          if (!userProvider.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red),
                  SizedBox(height: 16),
                  Text('No hay información de usuario disponible',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: Text('Volver al Login'),
                  )
                ],
              ),
            );
          }

          final userData = userProvider.user!;
          
          // Extraer valores con manejo de nulos
          final String nombre = _normalizeString(userData['nombre'] ?? 'No disponible');
          final String ci = userData['ci']?.toString() ?? 'No disponible';
          final String rolNombre = _normalizeString(userProvider.rolNombre);
          final String correo = userData['correo'] ?? 'No disponible';
          final String telefono = userData['telefono']?.toString() ?? 'No disponible';
          final String sexo = userData['sexo'] ?? 'No disponible';
          final String fechaNacimiento = userData['fecha_nacimiento'] ?? 'No disponible';
          
          // Información específica de profesor si está disponible
          final bool esProfesor = userData['rol_nombre'] == 'Profesor';
          final Map<String, dynamic>? profesorData = userData['profesor'] is Map ? 
              Map<String, dynamic>.from(userData['profesor']) : null;
          final String especialidad = esProfesor && profesorData != null ? 
              _normalizeString(profesorData['especialidad'] ?? 'No especificada') : '';

          // Obtener la primera letra del nombre para el avatar
          final String avatarLetter = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar y nombre
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blueGrey[700],
                        child: Text(
                          avatarLetter,
                          style: TextStyle(fontSize: 50, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        nombre,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        rolNombre,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (esProfesor && especialidad.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Especialidad: $especialidad",
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Información personal
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información Personal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                        Divider(),
                        _buildInfoItem(Icons.badge, 'CI', ci),
                        _buildInfoItem(Icons.calendar_today, 'Fecha de Nacimiento', fechaNacimiento),
                        _buildInfoItem(Icons.mail, 'Correo', correo),
                        _buildInfoItem(Icons.phone, 'Teléfono', telefono),
                        _buildInfoItem(Icons.person, 'Sexo', _formatSexo(sexo)),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Permisos
                if (userProvider.permisos != null && userProvider.permisos!.isNotEmpty)
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permisos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                          Divider(),
                          ...userProvider.permisos!
                              .where((permiso) => permiso['estado'] == true)
                              .map((permiso) => _buildPermissionItem(
                                  _normalizeString(permiso['nombre'] ?? 'Sin nombre'))),
                        ],
                      ),
                    ),
                  ),
                
                SizedBox(height: 24),
                
                // Botón de cerrar sesión
                ElevatedButton(
                  onPressed: () {
                    userProvider.logout();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Cerrar Sesión',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Función para normalizar las cadenas con caracteres especiales mal codificados
  String _normalizeString(String text) {
    return text
        .replaceAll('Ã¡', 'á')
        .replaceAll('Ã©', 'é')
        .replaceAll('Ã­', 'í')
        .replaceAll('Ã³', 'ó')
        .replaceAll('Ãº', 'ú')
        .replaceAll('Ã±', 'ñ')
        .replaceAll('Ã', 'í');
  }

  // Función para mostrar el sexo de forma más legible
  String _formatSexo(String sexo) {
    if (sexo == 'M') return 'Masculino';
    if (sexo == 'F') return 'Femenino';
    return sexo;
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String permission) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text(permission),
        ],
      ),
    );
  }
}