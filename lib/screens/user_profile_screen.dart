import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class UserProfileScreen extends StatelessWidget {
  final UserProfile user;

  UserProfileScreen({required this.user});

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${user.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Sexo: ${user.gender}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Rol: ${user.role}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Fecha de Nacimiento: ${user.birthDate.toLocal().toString().split(' ')[0]}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Teléfono: ${user.phone}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
