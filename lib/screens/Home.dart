import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - Aula Virtual'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Número de columnas
          crossAxisSpacing: 16, // Espaciado horizontal
          mainAxisSpacing: 16, // Espaciado vertical
          children: [
            // Botón de Calificaciones
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
              label: 'Libretas',
              route: '/notebooks',
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
