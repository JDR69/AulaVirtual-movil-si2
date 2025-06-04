import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Add this import
import '../provider/user_provider.dart'; // Add this import

extension SortedListExtension<T extends Comparable<T>> on Iterable<T> {
  List<T> sorted() => toList()..sort();
}

class GradesScreen extends StatefulWidget {
  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  bool isLoading = true;
  String? errorMessage;
  List<dynamic>? gradesData;

  // Session management
  List<dynamic> availableSessions = [];
  String currentSession = "9";

  // User data
  List<dynamic> allUsers = [];
  List<dynamic> filteredStudents = [];
  Map<String, dynamic>? selectedStudent;
  Map<String, dynamic>? currentUser;
  String searchText = "";
  bool showSuggestions = false;
  bool isStudent = false; // Flag to identify student role

  // Add this as a class variable at the top of your _GradesScreenState class
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: searchText);
    _loadInitialData();
  }

  // Simplified to only load sessions
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Get available sessions (gestiones)
      final sessions = await ApiService.getAcademicSessions();

      if (sessions != null && sessions.isNotEmpty) {
        availableSessions = sessions;

        // Set default session to most recent one
        if (sessions.isNotEmpty && sessions[0]['anio_escolar'] != null) {
          setState(() {
            currentSession = sessions[0]['anio_escolar'].toString();
          });
        }
      }

      // Let the build method get user data from provider
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error cargando datos iniciales: $e";
      });
      print('Error en carga inicial: $e');
    }
  }

  // Load grades for the specified student and session
  Future<void> _loadGrades(String studentId, String session) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print(
        'Cargando calificaciones para estudiante $studentId en gestión $session',
      );
      final result = await ApiService.getStudentGradesBySession(
        studentId,
        session,
      );

      setState(() {
        isLoading = false;
        if (result != null) {
          gradesData = result is List ? result : [];
          print('Calificaciones cargadas: ${gradesData?.length} items');
        } else {
          gradesData = [];
          errorMessage = "No se pudieron cargar las calificaciones";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
    }
  }

  // Filter students based on search text - only used for non-student roles
  void _filterStudents(String query) {
    setState(() {
      searchText = query;
      if (query.trim().length >= 3) {
        final filteredResults = allUsers
            .where(
              (user) =>
                  user['nombre'] != null &&
                  user['nombre'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) &&
                  user['rol_nombre'] == 'Alumno',
            )
            .toList();
        filteredStudents = filteredResults;
        showSuggestions = filteredStudents.isNotEmpty;
      } else {
        showSuggestions = false;
      }
    });
  }

  // Select a student from suggestions - only used for non-student roles
  void _selectStudent(Map<String, dynamic> student) {
    setState(() {
      selectedStudent = student;
      searchText = student['nombre'] ?? 'Estudiante';
      _searchController.text = searchText; // Update controller text
      showSuggestions = false;
    });

    if (student['id'] != null && currentSession.isNotEmpty) {
      _loadGrades(student['id'].toString(), currentSession);
    }
  }

  // Process the grades data to match the React component structure
  List<Map<String, dynamic>> processGradesData() {
    if (gradesData == null || gradesData!.isEmpty) {
      return [];
    }

    Map<String, Map<String, dynamic>> materiasMap = {};

    for (var item in gradesData!) {
      final materiaId = item['materia_id']?.toString() ?? '';
      final trimestre = item['trimestre']?['nro'] ?? 0;
      final nombreMateria = item['nombre_materia'] ?? 'Sin nombre';

      // Calculate average of all dimensions for this trimester
      double? promedioTrimestre;
      if (item['dimensiones'] != null &&
          item['dimensiones'] is List &&
          (item['dimensiones'] as List).isNotEmpty) {
        List<dynamic> dimensiones = item['dimensiones'];
        var validPromedios = dimensiones
            .where((dim) => dim['promedio'] != null)
            .map((dim) => dim['promedio'] as num)
            .toList();

        if (validPromedios.isNotEmpty) {
          promedioTrimestre =
              validPromedios.reduce((sum, val) => sum + val) / 1;
        }
      }

      if (!materiasMap.containsKey(materiaId)) {
        materiasMap[materiaId] = {
          'materia_id': materiaId,
          'nombre_materia': nombreMateria,
          'trimestre1': null,
          'trimestre2': null,
          'trimestre3': null,
        };
      }

      // Set the average for the correct trimester
      if (trimestre >= 1 && trimestre <= 3) {
        materiasMap[materiaId]!['trimestre$trimestre'] = promedioTrimestre;
      }
    }

    return materiasMap.values.toList();
  }

  // Calculate final grade from trimester grades
  double calcularNotaFinal(
    double? trimestre1,
    double? trimestre2,
    double? trimestre3,
  ) {
    List<double> notas = [
      if (trimestre1 != null) trimestre1,
      if (trimestre2 != null) trimestre2,
      if (trimestre3 != null) trimestre3,
    ];

    if (notas.isEmpty) return 0.0;

    double suma = notas.reduce((a, b) => a + b);
    return suma / notas.length;
  }

  // Determine if student passed based on average
  String determinarAprobacion(List<Map<String, dynamic>> materias) {
    if (materias.isEmpty) return 'Sin materias';

    double totalPromedio = 0;
    int materiasConNotas = 0;

    for (var materia in materias) {
      double notaFinal = calcularNotaFinal(
        materia['trimestre1'],
        materia['trimestre2'],
        materia['trimestre3'],
      );

      if (notaFinal > 0) {
        totalPromedio += notaFinal;
        materiasConNotas++;
      }
    }

    if (materiasConNotas == 0) return 'Sin calificaciones';

    double promedio = totalPromedio / materiasConNotas;
    return promedio >= 60 ? 'Aprobado' : 'Reprobado';
  }

  @override
  Widget build(BuildContext context) {
    // Process data for displaying
    List<Map<String, dynamic>> processedData = [];
    String overallStatus = 'Sin calificaciones';

    if (gradesData != null && gradesData!.isNotEmpty) {
      processedData = processGradesData();
      overallStatus = determinarAprobacion(processedData);
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Get current user data from provider
        if (userProvider.user == null) {
          // If not logged in, show message
          return Scaffold(
            appBar: AppBar(
              title: Text('Calificaciones'),
              backgroundColor: Colors.blueGrey[700],
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

        // Now we know we have a user
        final userData = userProvider.user!;
        final userId = userData['id'].toString();
        final userName = userData['nombre'] ?? 'Usuario';

        return Scaffold(
          appBar: AppBar(
            title: Text('Mis Calificaciones'),
            backgroundColor: Colors.blueGrey[700],
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  _loadGrades(userId, currentSession);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Only show the session selector
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Gestión: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: currentSession,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              currentSession = newValue;
                            });
                            // Load grades for current user with new session
                            _loadGrades(userId, newValue);
                          }
                        },
                        items: [
                          ...availableSessions.map<DropdownMenuItem<String>>((
                            session,
                          ) {
                            return DropdownMenuItem<String>(
                              value: session['anio_escolar'].toString(),
                              child: Text(session['anio_escolar'].toString()),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _loadGrades(userId, currentSession);
                              },
                              child: Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Student data card
                            Card(
                              elevation: 4,
                              margin: EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mis Datos',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[800],
                                      ),
                                    ),
                                    Divider(),
                                    SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow(
                                          'Nombre Completo:',
                                          userName,
                                        ),
                                        SizedBox(height: 8),
                                        _buildInfoRow(
                                          'CI:',
                                          userData['ci'] ?? 'No disponible',
                                        ),
                                        SizedBox(height: 8),
                                        _buildInfoRow(
                                          'Estado del Curso:',
                                          overallStatus,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Grades card
                            Card(
                              elevation: 4,
                              margin: EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Materias y Calificaciones',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[800],
                                      ),
                                    ),
                                    Divider(),
                                    SizedBox(height: 8),

                                    // Grades Table
                                    processedData.isEmpty
                                        ? Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                32.0,
                                              ),
                                              child: Text(
                                                'No hay calificaciones disponibles para la gestión seleccionada.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          )
                                        : SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              headingRowColor:
                                                  MaterialStateProperty.all(
                                                    Colors.blueGrey[100],
                                                  ),
                                              columnSpacing: 20,
                                              columns: [
                                                DataColumn(
                                                  label: Text(
                                                    'Materia',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    '1er Trimestre',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    '2do Trimestre',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    '3er Trimestre',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Nota Final',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Estado',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              rows: processedData.map((
                                                materia,
                                              ) {
                                                final notaFinal =
                                                    calcularNotaFinal(
                                                      materia['trimestre1'],
                                                      materia['trimestre2'],
                                                      materia['trimestre3'],
                                                    );

                                                final estado = notaFinal >= 60
                                                    ? 'Aprobado'
                                                    : (notaFinal > 0
                                                          ? 'Reprobado'
                                                          : 'Sin calificar');

                                                return DataRow(
                                                  cells: _buildDataCells(
                                                    materia,
                                                    notaFinal,
                                                    estado,
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Extract the grades card to a separate method for better organization
  Widget _buildGradesCard(List<Map<String, dynamic>> processedData) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Materias y Calificaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            Divider(),
            SizedBox(height: 8),

            // Grades Table
            processedData.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No hay calificaciones disponibles para la gestión seleccionada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        Colors.blueGrey[100],
                      ),
                      columnSpacing: 20,
                      columns: [
                        DataColumn(
                          label: Text(
                            'Materia',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            '1er Trimestre',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            '2do Trimestre',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            '3er Trimestre',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nota Final',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Estado',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: processedData.map((materia) {
                        final notaFinal = calcularNotaFinal(
                          materia['trimestre1'],
                          materia['trimestre2'],
                          materia['trimestre3'],
                        );

                        final estado = notaFinal >= 60
                            ? 'Aprobado'
                            : (notaFinal > 0 ? 'Reprobado' : 'Sin calificar');

                        return DataRow(
                          cells: _buildDataCells(materia, notaFinal, estado),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Extract data cells creation to a separate method
  List<DataCell> _buildDataCells(
    Map<String, dynamic> materia,
    double notaFinal,
    String estado,
  ) {
    return [
      DataCell(
        Text(
          materia['nombre_materia'] ?? 'Sin nombre',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataCell(
        Text(
          materia['trimestre1'] != null
              ? materia['trimestre1'].toStringAsFixed(2)
              : '-',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataCell(
        Text(
          materia['trimestre2'] != null
              ? materia['trimestre2'].toStringAsFixed(2)
              : '-',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataCell(
        Text(
          materia['trimestre3'] != null
              ? materia['trimestre3'].toStringAsFixed(2)
              : '-',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataCell(
        Text(
          notaFinal > 0 ? notaFinal.toStringAsFixed(2) : '-',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataCell(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: estado == 'Aprobado'
                ? Colors.green[100]
                : estado == 'Reprobado'
                ? Colors.red[100]
                : Colors.grey[100],
          ),
          child: Text(
            estado,
            style: TextStyle(
              color: estado == 'Aprobado'
                  ? Colors.green[800]
                  : estado == 'Reprobado'
                  ? Colors.red[800]
                  : Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: label == 'Estado del Curso:'
                  ? (value == 'Aprobado'
                        ? Colors.green[800]
                        : (value == 'Reprobado'
                              ? Colors.red[800]
                              : Colors.grey[800]))
                  : Colors.black,
              fontWeight: label == 'Estado del Curso:'
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Add this in your dispose method to clean up resources
    _searchController.dispose();
    super.dispose();
  }
}
