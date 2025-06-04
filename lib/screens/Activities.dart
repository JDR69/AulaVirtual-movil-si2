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
    {
      'id': '4',
      'descripcion': 'Exposición de Literatura',
      'fecha_inicio': '2025-05-12',
      'fecha_entrega': '2025-05-25',
    },
    {
      'id': '5',
      'descripcion': 'Práctico de Laboratorio - Química',
      'fecha_inicio': '2025-05-15',
      'fecha_entrega': '2025-05-22',
    },
    {
      'id': '6',
      'descripcion': 'Informe de Investigación - Biología',
      'fecha_inicio': '2025-05-18',
      'fecha_entrega': '2025-06-01',
    },
    {
      'id': '7',
      'descripcion': 'Debate Grupal - Educación Cívica',
      'fecha_inicio': '2025-05-20',
      'fecha_entrega': '2025-05-27',
    },
    {
      'id': '8',
      'descripcion': 'Proyecto Final - Informática',
      'fecha_inicio': '2025-05-25',
      'fecha_entrega': '2025-06-15',
    },
    {
      'id': '9',
      'descripcion': 'Presentación Oral - Inglés',
      'fecha_inicio': '2025-05-28',
      'fecha_entrega': '2025-06-05',
    },
    {
      'id': '10',
      'descripcion': 'Examen Parcial - Matemáticas',
      'fecha_inicio': '2025-06-01',
      'fecha_entrega': '2025-06-01',
    },
    {
      'id': '11',
      'descripcion': 'Maqueta de Arquitectura - Artes',
      'fecha_inicio': '2025-06-05',
      'fecha_entrega': '2025-06-20',
    },
    {
      'id': '12',
      'descripcion': 'Reporte de Experimento - Física',
      'fecha_inicio': '2025-06-08',
      'fecha_entrega': '2025-06-18',
    },
    {
      'id': '13',
      'descripcion': 'Análisis de Texto - Literatura',
      'fecha_inicio': '2025-06-10',
      'fecha_entrega': '2025-06-17',
    },
    {
      'id': '14',
      'descripcion': 'Investigación de Campo - Geografía',
      'fecha_inicio': '2025-06-15',
      'fecha_entrega': '2025-06-29',
    },
    {
      'id': '15',
      'descripcion': 'Cuestionario en Línea - Historia',
      'fecha_inicio': '2025-06-18',
      'fecha_entrega': '2025-06-18',
    },
    {
      'id': '16',
      'descripcion': 'Taller de Resolución de Problemas - Matemáticas',
      'fecha_inicio': '2025-06-20',
      'fecha_entrega': '2025-06-27',
    },
    {
      'id': '17',
      'descripcion': 'Diseño de Póster Científico - Biología',
      'fecha_inicio': '2025-06-25',
      'fecha_entrega': '2025-07-08',
    },
    {
      'id': '18',
      'descripcion': 'Examen Final - Ciencias Naturales',
      'fecha_inicio': '2025-07-01',
      'fecha_entrega': '2025-07-01',
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
          scrollDirection: Axis.horizontal,
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
