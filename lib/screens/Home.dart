import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await ApiService.obtenerUsuario();

      // Agregar depuración para ver la estructura exacta de userData
      print('Datos de usuario obtenidos: $userData');

      setState(() {
        currentUser = userData;
        isLoading = false;
      });

      // Verificar el rol directamente después de cargar (corregido de rol_id a rol)
      if (userData != null) {
        print('Rol del usuario: ${userData['rol']}');
        print('Rol nombre: ${userData['rol_nombre']}');
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - Aula Virtual'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2, // Número de columnas
                crossAxisSpacing: 16, // Espaciado horizontal
                mainAxisSpacing: 16, // Espaciado vertical
                children: [
                  // Botón de Calificaciones - Ahora siempre va a la misma ruta
                  _buildDashboardButton(
                    context,
                    icon: Icons.grade,
                    label: 'Calificaciones',
                    route: '/grades',
                  ),
                  // Botón de Actividades
                  _buildDashboardButton(
                    context,
                    icon: Icons.assignment,
                    label: 'Actividades',
                    route: '/activities',
                  ),
                  // Botón de Libretas
                  _buildDashboardButton(
                    context,
                    icon: Icons.book,
                    label: 'Licencias',
                    route: '/licencias',
                  ),
                  // Botón de Perfil de Usuario
                  _buildDashboardButton(
                    context,
                    icon: Icons.person,
                    label: 'Perfil de Usuario',
                    route: '/profile',
                  ),
                  // Nuevo botón de LibretaIA
                  _buildDashboardButton(
                    context,
                    icon: Icons.psychology,
                    label: 'LibretaIA Predictiva',
                    route: '/libretaia',
                  ),
                ],
              ),
            ),
      // Ejemplo de DrawerMenu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey[700]),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.psychology),
              title: Text('LibretaIA Predictiva'),
              onTap: () {
                Navigator.pushNamed(context, '/libretaia');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget para un botón del Dashboard
  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // Sombra
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blueGrey[700]),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
