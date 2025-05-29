import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../provider/user_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadUserProfile();
  }

  Future<UserProfile> _loadUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Obtener los datos del perfil de usuario
    await userProvider.obtenerPerfilUsuario();
    
    // Si no hay datos, lanzar una excepción
    if (userProvider.perfilUsuario == null) {
      throw Exception('No se pudieron obtener los datos del usuario');
    }
    
    // Convertir a nuestro modelo UserProfile
    return UserProfile.fromJson(userProvider.perfilUsuario!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Text(
                        user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('ID:', user.id.toString()),
                          _buildInfoRow('CI:', user.ci),
                          _buildInfoRow('Nombre:', user.nombre),
                          _buildInfoRow('Sexo:', user.sexo),
                          _buildInfoRow('Teléfono:', user.telefono),
                          _buildInfoRow('Rol:', user.rolNombre),
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No se encontraron datos'));
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}