import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  final List<Map<String, String>> activities = [
    {
      'id': '1',
      'descripcion': 'Tarea de Matemáticas',
      'fecha_inicio': '2025-05-01',
      'fecha_entrega': '2025-05-10',
    },
    {
      'id': '2',
      'descripcion': 'Proyecto de Ciencias',
      'fecha_inicio': '2025-05-05',
      'fecha_entrega': '2025-05-15',
    },
    {
      'id': '3',
      'descripcion': 'Ensayo de Historia',
      'fecha_inicio': '2025-05-08',
      'fecha_entrega': '2025-05-20',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actividades'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis
              .horizontal, // Permite desplazamiento horizontal si es necesario
          child: DataTable(
            columns: [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Descripción')),
              DataColumn(label: Text('Fecha Inicio')),
              DataColumn(label: Text('Fecha Entrega')),
            ],
            rows: activities.map((activity) {
              return DataRow(
                cells: [
                  DataCell(Text(activity['id']!)),
                  DataCell(Text(activity['descripcion']!)),
                  DataCell(Text(activity['fecha_inicio']!)),
                  DataCell(Text(activity['fecha_entrega']!)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
