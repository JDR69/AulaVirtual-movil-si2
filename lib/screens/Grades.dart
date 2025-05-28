import 'package:flutter/material.dart';

class GradesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calificaciones'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Center(
        child: Text(
          'Aquí se mostrarán las calificaciones.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
