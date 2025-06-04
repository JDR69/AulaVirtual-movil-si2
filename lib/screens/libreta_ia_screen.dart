import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../provider/student_perfomance_provider.dart';
import '../models/student_performance_model.dart';

class LibretaIAScreen extends StatefulWidget {
  const LibretaIAScreen({Key? key}) : super(key: key);

  @override
  _LibretaIAScreenState createState() => _LibretaIAScreenState();
}

class _LibretaIAScreenState extends State<LibretaIAScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<int> _yearOptions = [1, 2, 3, 4, 5];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    // Cargar estudiantes al iniciar la pantalla
    Future.microtask(
      () => Provider.of<StudentPerformanceProvider>(
        context,
        listen: false,
      ).fetchStudents(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LibretaIA Predictiva'),
        backgroundColor: Colors.indigo[700],
      ),
      body: Consumer<StudentPerformanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: SpinKitDoubleBounce(color: Colors.indigo[700], size: 50.0),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                buildHeader(),

                const SizedBox(height: 20),

                // Selector de gestiones
                buildYearSelector(provider),

                const SizedBox(height: 20),

                // Buscador de estudiantes
                buildStudentSearch(provider),

                const SizedBox(height: 20),

                // Si hay un estudiante seleccionado, mostrar selector de materias
                if (provider.selectedStudent != null)
                  buildSubjectSelector(provider),

                const SizedBox(height: 20),

                // Si hay un estudiante y una materia seleccionados, mostrar gráfico y análisis
                if (provider.selectedStudent != null &&
                    provider.selectedSubject.isNotEmpty)
                  buildPerformanceChart(provider),

                const SizedBox(height: 20),

                // Análisis de IA
                if (provider.selectedStudent != null &&
                    provider.selectedSubject.isNotEmpty)
                  buildAIAnalysis(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[700]!, Colors.indigo[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Text(
                'LibretaIA Predictiva',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Predicción académica anual basada en datos reales',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildYearSelector(StudentPerformanceProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cantidad de gestiones a considerar:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[700],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<int>(
                value: provider.yearsToConsider,
                underline: Container(),
                isExpanded: true,
                hint: const Text('Seleccione años'),
                onChanged: (value) {
                  if (value != null) {
                    provider.setYearsToConsider(value);
                    // Si hay un estudiante seleccionado, recargar sus datos
                    if (provider.selectedStudent != null) {
                      provider.fetchStudentData(
                        provider.selectedStudent!.id,
                        value,
                      );
                    }
                  }
                },
                items: _yearOptions
                    .map(
                      (year) =>
                          DropdownMenuItem(value: year, child: Text('$year')),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStudentSearch(StudentPerformanceProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buscar Estudiante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[700],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ej: Juan Pérez',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _showSuggestions = value.length >= 3;
                });
              },
            ),
            if (_showSuggestions)
              Container(
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.students.length,
                  itemBuilder: (context, index) {
                    final student = provider.students[index];
                    if (student.name.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    )) {
                      return ListTile(
                        title: Text(student.name),
                        onTap: () {
                          setState(() {
                            _searchController.text = student.name;
                            _showSuggestions = false;
                          });
                          // Cargar datos del estudiante seleccionado
                          provider.fetchStudentData(
                            student.id,
                            provider.yearsToConsider,
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSubjectSelector(StudentPerformanceProvider provider) {
    // Obtener lista de materias únicas
    Set<String> subjects = {};

    provider.selectedStudent!.yearlyData.forEach((year, performances) {
      performances.forEach((performance) {
        subjects.add(performance.subjectName);
      });
    });

    List<String> subjectsList = subjects.toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccione una materia:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[700],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: provider.selectedSubject.isEmpty
                    ? null
                    : provider.selectedSubject,
                underline: Container(),
                isExpanded: true,
                hint: const Text('-- Seleccione --'),
                onChanged: (value) {
                  if (value != null) {
                    provider.selectSubject(value);
                  }
                },
                items: subjectsList
                    .map(
                      (subject) => DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPerformanceChart(StudentPerformanceProvider provider) {
    // Preparar datos para la gráfica - Agrupar por año
    Map<String, double> promediosPorAno = {};

    provider.selectedStudent!.yearlyData.forEach((year, yearPerformances) {
      for (var performance in yearPerformances) {
        if (performance.subjectName == provider.selectedSubject) {
          promediosPorAno[year] = performance.average;
        }
      }
    });

    // Convertir el mapa a una lista ordenada por año
    List<MapEntry<String, double>> datosOrdenados =
        promediosPorAno.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    // Recopilar rendimientos para calcular predicción
    List<SubjectPerformance> performances = [];
    datosOrdenados.forEach((entry) {
      performances.add(
        SubjectPerformance(
          subjectName: provider.selectedSubject,
          average: entry.value,
          year: entry.key,
        ),
      );
    });

    // Calcular predicción si hay suficientes datos
    double? prediccion = provider.predictNextScore(performances);
    String? proximoAno;

    if (prediccion != null && datosOrdenados.isNotEmpty) {
      proximoAno = (int.parse(datosOrdenados.last.key) + 1).toString();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desempeño en ${provider.selectedSubject} por gestión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              padding: const EdgeInsets.all(10),
              child: datosOrdenados.isEmpty
                  ? Center(child: Text("No hay datos disponibles"))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();

                                // Mostrar años existentes
                                if (index >= 0 &&
                                    index < datosOrdenados.length) {
                                  return Text(
                                    datosOrdenados[index].key,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                }

                                // Mostrar año de predicción
                                if (prediccion != null &&
                                    index == datosOrdenados.length) {
                                  return Text(
                                    proximoAno!,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                }

                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        minX: 0,
                        maxX: prediccion != null
                            ? datosOrdenados.length.toDouble()
                            : (datosOrdenados.length - 1).toDouble(),
                        minY: 0,
                        maxY: 100, // Nota máxima es 100
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              // Datos reales
                              ...List.generate(
                                datosOrdenados.length,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  datosOrdenados[index].value,
                                ),
                              ),
                              // Predicción para el próximo año
                              if (prediccion != null)
                                FlSpot(
                                  datosOrdenados.length.toDouble(),
                                  prediccion,
                                ),
                            ],
                            isCurved: true,
                            color: Colors.indigo[700],
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.indigo.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAIAnalysis(StudentPerformanceProvider provider) {
    // Obtener datos ordenados por año
    Map<String, double> promediosPorAno = {};
    provider.selectedStudent!.yearlyData.forEach((year, yearPerformances) {
      for (var performance in yearPerformances) {
        if (performance.subjectName == provider.selectedSubject) {
          promediosPorAno[year] = performance.average;
        }
      }
    });

    List<MapEntry<String, double>> datosOrdenados =
        promediosPorAno.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    // Convertir a formato para predicción
    List<SubjectPerformance> performances = datosOrdenados
        .map(
          (entry) => SubjectPerformance(
            subjectName: provider.selectedSubject,
            average: entry.value,
            year: entry.key,
          ),
        )
        .toList();

    // Calcular predicción
    double? prediccion = provider.predictNextScore(performances);

    // Generar comentario
    String comentario = provider.generateComment(performances);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo[700]!, Colors.indigo[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  'Análisis de IA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comentario de análisis
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.indigo[700]!, width: 4),
                    ),
                    color: Colors.grey[50],
                  ),
                  child: Text(
                    comentario,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),

                SizedBox(height: 20),

                // Predicción
                if (prediccion != null && performances.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Predicción para el próximo año:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[700],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo[700],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                prediccion.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              performances.length >= 2 &&
                                      prediccion > performances.last.average
                                  ? '↗️ En ascenso'
                                  : '↘️ En descenso',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 20),

                // Recomendaciones (igual que en la versión web)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recomendaciones:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildRecommendationItem(
                        'Continuar con el plan de estudio personalizado',
                      ),
                      _buildRecommendationItem(
                        'Reforzar los conceptos fundamentales de la materia',
                      ),
                      _buildRecommendationItem(
                        'Implementar técnicas de estudio activo',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 8, color: Colors.indigo),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

// En StudentPerformanceProvider
double? predictNextScore(Map<String, double> promediosAnuales) {
  if (promediosAnuales.length < 2) return null;

  List<double> x = [];
  List<double> y = [];

  int i = 0;
  promediosAnuales.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key))
    ..forEach((entry) {
      x.add(i + 1.0);
      y.add(entry.value);
      i++;
    });

  int n = x.length;
  double sumX = x.reduce((a, b) => a + b);
  double sumY = y.reduce((a, b) => a + b);
  double sumXY = 0;
  double sumXX = 0;

  for (int i = 0; i < n; i++) {
    sumXY += x[i] * y[i];
    sumXX += x[i] * x[i];
  }

  double m = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  double b = (sumY - m * sumX) / n;
  double nextX = n + 1.0;

  return double.parse((m * nextX + b).toStringAsFixed(2));
}
