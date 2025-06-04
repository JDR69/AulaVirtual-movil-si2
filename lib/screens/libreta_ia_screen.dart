import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../provider/student_perfomance_provider.dart';
import '../models/student_performance_model.dart';
import '../provider/user_provider.dart';

class LibretaIAScreen extends StatefulWidget {
  const LibretaIAScreen({Key? key}) : super(key: key);

  @override
  _LibretaIAScreenState createState() => _LibretaIAScreenState();
}

class _LibretaIAScreenState extends State<LibretaIAScreen> {
  // Replace year options with academic sessions
  List<String> availableSessions = [];
  String? initialSession;
  String? predictiveSession;
  bool _isLoadingSessions = true;

  @override
  void initState() {
    super.initState();
    // Load available sessions first
    _loadAcademicSessions();
  }

  // Fetch academic sessions from API
  Future<void> _loadAcademicSessions() async {
    setState(() {
      _isLoadingSessions = true;
    });

    try {
      final sessions = await Provider.of<StudentPerformanceProvider>(
        context,
        listen: false,
      ).fetchAcademicSessions();

      // Ordenar las sesiones de más reciente a más antigua
      sessions.sort((a, b) {
        try {
          int yearA = int.parse(a);
          int yearB = int.parse(b);
          return yearB.compareTo(yearA); // Orden descendente
        } catch (e) {
          return 0;
        }
      });

      setState(() {
        availableSessions = sessions;

        // Set default values if sessions available
        if (sessions.isNotEmpty) {
          // Usar la gestión más reciente como inicial
          initialSession = sessions.first;

          // Y la siguiente más reciente como predictiva (o la misma si solo hay una)
          if (sessions.length > 1) {
            predictiveSession = sessions[1];
          } else {
            predictiveSession = sessions.first;
          }
        }

        _isLoadingSessions = false;
      });

      // Now load user data
      _loadCurrentUserData();
    } catch (e) {
      print('Error loading sessions: $e');
      setState(() {
        _isLoadingSessions = false;
      });
    }
  }

  // Load current user's data
  Future<void> _loadCurrentUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user != null) {
      final userId = userProvider.user!['id'].toString();

      if (initialSession != null && predictiveSession != null) {
        // Intercambiar gestiones si la inicial es mayor que la predictiva
        if (_compareSessionYears(initialSession!, predictiveSession!) > 0) {
          String temp = initialSession!;
          setState(() {
            initialSession = predictiveSession;
            predictiveSession = temp;
          });
        }

        // Cargar datos del estudiante con el rango de sesiones seleccionado
        await Provider.of<StudentPerformanceProvider>(
          context,
          listen: false,
        ).fetchStudentDataWithRange(
          userId,
          initialSession!,
          predictiveSession!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, StudentPerformanceProvider>(
      builder: (context, userProvider, performanceProvider, child) {
        // Check if user is logged in
        if (userProvider.user == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('LibretaIA Predictiva'),
              backgroundColor: Colors.indigo[700],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'No hay información de usuario disponible',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: Text('Volver al Login'),
                  ),
                ],
              ),
            ),
          );
        }

        if (performanceProvider.isLoading || _isLoadingSessions) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('LibretaIA Predictiva'),
              backgroundColor: Colors.indigo[700],
            ),
            body: Center(
              child: SpinKitDoubleBounce(color: Colors.indigo[700], size: 50.0),
            ),
          );
        }

        final userName = userProvider.user!['nombre'] ?? 'Usuario';

        return Scaffold(
          appBar: AppBar(
            title: const Text('LibretaIA Predictiva'),
            backgroundColor: Colors.indigo[700],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                buildHeader(),

                const SizedBox(height: 20),

                // User Info Card
                buildUserInfoCard(userName),

                const SizedBox(height: 20),

                // Session Range Selector
                buildSessionRangeSelector(performanceProvider),

                const SizedBox(height: 20),

                // If student data is loaded, show subject selector
                if (performanceProvider.selectedStudent != null)
                  buildSubjectSelector(performanceProvider),

                const SizedBox(height: 20),

                // If student and subject are selected, show chart and analysis
                if (performanceProvider.selectedStudent != null &&
                    performanceProvider.selectedSubject.isNotEmpty)
                  buildPerformanceChart(performanceProvider),

                const SizedBox(height: 20),

                // AI Analysis
                if (performanceProvider.selectedStudent != null &&
                    performanceProvider.selectedSubject.isNotEmpty)
                  buildAIAnalysis(performanceProvider),
              ],
            ),
          ),
        );
      },
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
            'Predicción académica basada en datos reales',
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

  Widget buildUserInfoCard(String userName) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estudiante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[700],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo[100],
                  child: Icon(Icons.person, color: Colors.indigo[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    userName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSessionRangeSelector(StudentPerformanceProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rango de Gestiones a Analizar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[700],
              ),
            ),
            const SizedBox(height: 15),

            // Initial Session Selector
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Gestión Inicial:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.indigo.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: initialSession,
                      underline: Container(),
                      isExpanded: true,
                      hint: const Text('Seleccione'),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            initialSession = newValue;
                          });
                          _updateDataWithNewRange(provider);
                        }
                      },
                      items: availableSessions
                          .map(
                            (session) => DropdownMenuItem<String>(
                              value: session,
                              child: Text(session),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Predictive Session Selector
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Gestión Predictiva:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.indigo.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: predictiveSession,
                      underline: Container(),
                      isExpanded: true,
                      hint: const Text('Seleccione'),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            predictiveSession = newValue;
                          });
                          _updateDataWithNewRange(provider);
                        }
                      },
                      items: availableSessions
                          .map(
                            (session) => DropdownMenuItem<String>(
                              value: session,
                              child: Text(session),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),

            // Advertencia si el orden está mal
            if (initialSession != null &&
                predictiveSession != null &&
                _compareSessionYears(initialSession!, predictiveSession!) > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '⚠️ La gestión inicial debe ser anterior a la predictiva',
                  style: TextStyle(color: Colors.orange[800], fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Actualiza el método para comparar años
  int _compareSessionYears(String session1, String session2) {
    try {
      int year1 = int.parse(session1);
      int year2 = int.parse(session2);
      return year1.compareTo(year2);
    } catch (e) {
      print('Error comparando años: $e');
      return 0;
    }
  }

  // Actualiza el método para cargar datos con el nuevo rango
  void _updateDataWithNewRange(StudentPerformanceProvider provider) {
    if (initialSession == null || predictiveSession == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user == null) return;

    final userId = userProvider.user!['id'].toString();

    // Si la gestión inicial es mayor que la predictiva, intercambiarlas
    if (_compareSessionYears(initialSession!, predictiveSession!) > 0) {
      setState(() {
        String temp = initialSession!;
        initialSession = predictiveSession;
        predictiveSession = temp;
      });

      // Mostrar un mensaje al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se han intercambiado las gestiones para mantener un orden cronológico',
          ),
          backgroundColor: Colors.orange[700],
          duration: Duration(seconds: 3),
        ),
      );
    }

    // Cargar datos para el rango seleccionado
    provider.fetchStudentDataWithRange(
      userId,
      initialSession!,
      predictiveSession!,
    );
  }

  Widget buildSubjectSelector(StudentPerformanceProvider provider) {
    // Get unique subjects
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
    // Prepare data for chart - Group by year
    Map<String, double> promediosPorAno = {};

    provider.selectedStudent!.yearlyData.forEach((year, yearPerformances) {
      for (var performance in yearPerformances) {
        if (performance.subjectName == provider.selectedSubject) {
          promediosPorAno[year] = performance.average;
        }
      }
    });

    // Sort entries by year
    List<MapEntry<String, double>> datosOrdenados =
        promediosPorAno.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    // Collect performances for prediction
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

    // Calculate prediction if enough data
    double? prediccion = provider.predictNextScore(performances);
    String? proximoAno;

    if (prediccion != null && datosOrdenados.isNotEmpty) {
      // For next year prediction
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

                                // Show existing years
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

                                // Show prediction year
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
                        maxY: 100, // Maximum score is 100
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              // Real data
                              ...List.generate(
                                datosOrdenados.length,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  datosOrdenados[index].value,
                                ),
                              ),
                              // Prediction for next year
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
    // Get data ordered by year
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

    // Convert to format for prediction
    List<SubjectPerformance> performances = datosOrdenados
        .map(
          (entry) => SubjectPerformance(
            subjectName: provider.selectedSubject,
            average: entry.value,
            year: entry.key,
          ),
        )
        .toList();

    // Calculate prediction
    double? prediccion = provider.predictNextScore(performances);

    // Generate comment
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
                // Analysis comment
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

                // Prediction
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
                                prediccion.toStringAsFixed(2),
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

                // Recommendations
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

  @override
  void dispose() {
    super.dispose();
  }
}
