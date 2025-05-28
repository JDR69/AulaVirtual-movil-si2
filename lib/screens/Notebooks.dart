import 'package:flutter/material.dart';

class NotebooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Libretas'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Center(
        child: Text(
          'Aquí se mostrarán las libretas.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
