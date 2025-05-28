import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actividades'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Center(
        child: Text(
          'Aquí se mostrarán las actividades.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}