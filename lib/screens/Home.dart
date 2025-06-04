import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? currentUser;
  bool isLoading = true;

  // Definir una paleta de colores consistente
  final Color primaryColor = Color(0xFF0088CC); // Azul primario
  final Color secondaryColor = Color(0xFF64B5F6); // Azul más claro
  final Color accentColor = Color(0xFFF5F9FC); // Fondo claro azulado
  final Color textColor = Color(0xFF2C3E50); // Texto oscuro con tono azulado

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await ApiService.obtenerUsuario();
      setState(() {
        currentUser = userData;
        isLoading = false;
      });
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
        title: Text(
          'Dashboard - Aula Virtual',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        elevation: 0, // Sin sombra en la AppBar para un look más moderno
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                // Gradiente sutil para el fondo
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor.withOpacity(0.1), accentColor],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saludo al usuario
                      if (currentUser != null &&
                          currentUser!.containsKey('nombre'))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text(
                            '¡Hola, ${currentUser!['nombre']}!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),

                      // Dashboard grid
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              1.1, // Hacer botones ligeramente rectangulares
                          children: [
                            _buildDashboardButton(
                              context,
                              icon: Icons.grade,
                              label: 'Calificaciones',
                              route: '/grades',
                            ),
                            _buildDashboardButton(
                              context,
                              icon: Icons.assignment,
                              label: 'Actividades',
                              route: '/activities',
                            ),
                            _buildDashboardButton(
                              context,
                              icon: Icons.book,
                              label: 'Licencias',
                              route: '/licencias',
                            ),
                            _buildDashboardButton(
                              context,
                              icon: Icons.person,
                              label: 'Perfil de Usuario',
                              route: '/profile',
                            ),
                            _buildDashboardButton(
                              context,
                              icon: Icons.psychology,
                              label: 'LibretaIA Predictiva',
                              route: '/libretaia',
                            ),
                            _buildDashboardButton(
                              context,
                              icon: Icons.notifications,
                              label: 'Notificaciones',
                              route: '/notificaciones',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Aula Virtual',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  currentUser != null && currentUser!.containsKey('nombre')
                      ? currentUser!['nombre']
                      : 'Menú Principal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Dashboard',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.grade,
            title: 'Calificaciones',
            onTap: () => _navigateTo(context, '/grades'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.assignment,
            title: 'Actividades',
            onTap: () => _navigateTo(context, '/activities'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.book,
            title: 'Licencias',
            onTap: () => _navigateTo(context, '/licencias'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Perfil de Usuario',
            onTap: () => _navigateTo(context, '/profile'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.psychology,
            title: 'LibretaIA Predictiva',
            onTap: () => _navigateTo(context, '/libretaia'),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.notifications,
            title: 'Notificaciones',
            onTap: () => _navigateTo(context, '/notificaciones'),
          ),
          Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () {
              // Aquí deberías llamar a la función de logout
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Cierra el drawer
    Navigator.pushNamed(context, route);
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.15),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: primaryColor),
              ),
              SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
