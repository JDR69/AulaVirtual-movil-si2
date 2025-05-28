import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  UserProfileScreen({required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<UserProfile> userProfile;

  @override
  void initState() {
    super.initState();
    userProfile = _fetchUserProfile();
  }

  Future<UserProfile> _fetchUserProfile() async {
    final apiService = ApiService();
    final data = await apiService.fetchUserProfile(widget.userId);

    return UserProfile(
      name: data['name'],
      gender: data['gender'],
      role: data['role'],
      birthDate: DateTime.parse(data['birthDate']),
      phone: data['phone'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      body: FutureBuilder<UserProfile>(
        future: userProfile,
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
            );
          } else {
            return Center(child: Text('No se encontraron datos'));
          }
        },
      ),
    );
  }
}