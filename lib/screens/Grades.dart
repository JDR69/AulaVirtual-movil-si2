import 'package:flutter/material.dart';

class GradesScreen extends StatelessWidget {
  GradesScreen({super.key});

  final List<Map<String, dynamic>> trimestre1 = [
    {'materia': 'Matemáticas', 'actividad': '8.5', 'examen': '9.0'},
    {'materia': 'Ciencias', 'actividad': '7.0', 'examen': '8.5'},
    {'materia': 'Historia', 'actividad': '9.0', 'examen': '9.5'},
  ];

  final List<Map<String, dynamic>> trimestre2 = [
    {'materia': 'Matemáticas', 'actividad': '8.0', 'examen': '8.5'},
    {'materia': 'Ciencias', 'actividad': '7.5', 'examen': '8.0'},
    {'materia': 'Historia', 'actividad': '8.5', 'examen': '9.0'},
  ];

  final List<Map<String, dynamic>> trimestre3 = [
    {'materia': 'Matemáticas', 'actividad': '9.0', 'examen': '9.5'},
    {'materia': 'Ciencias', 'actividad': '8.5', 'examen': '9.0'},
    {'materia': 'Historia', 'actividad': '9.5', 'examen': '10.0'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificaciones'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabla para el Primer Trimestre
              const Text(
                'Primer Trimestre',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTable(trimestre1),
              const SizedBox(height: 16),

              // Tabla para el Segundo Trimestre
              const Text(
                'Segundo Trimestre',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTable(trimestre2),
              const SizedBox(height: 16),

              // Tabla para el Tercer Trimestre
              const Text(
                'Tercer Trimestre',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTable(trimestre3),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir una tabla
  Widget _buildTable(List<Map<String, dynamic>> data) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Materia')),
        DataColumn(label: Text('Actividad')),
        DataColumn(label: Text('Examen')),
      ],
      rows: data.map((row) {
        return DataRow(
          cells: [
            DataCell(Text(row['materia'])),
            DataCell(Text(row['actividad'])),
            DataCell(Text(row['examen'])),
          ],
        );
      }).toList(),
    );
  }
}