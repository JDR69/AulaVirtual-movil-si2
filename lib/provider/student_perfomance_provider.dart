import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/student_performance_model.dart';
import '../services/api_service.dart'; // Importamos el servicio API existente

class StudentPerformanceProvider with ChangeNotifier {
  bool _isLoading = false;
  List<StudentPerformance> _students = [];
  StudentPerformance? _selectedStudent;
  String _selectedSubject = '';
  int _yearsToConsider = 3;

  bool get isLoading => _isLoading;
  List<StudentPerformance> get students => _students;
  StudentPerformance? get selectedStudent => _selectedStudent;
  String get selectedSubject => _selectedSubject;
  int get yearsToConsider => _yearsToConsider;

  // Cargar la lista de estudiantes
  Future<void> fetchStudents() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Usamos el servicio API existente para obtener usuarios
      final usersData = await ApiService.getAllUsers();

      if (usersData != null) {
        // Filtrar solo los estudiantes
        final studentUsers = usersData
            .where((user) => user['rol_nombre'] == 'Alumno')
            .toList();

        _students = studentUsers
            .map(
              (student) => StudentPerformance(
                id: student['id'].toString(),
                name: _normalizeString(student['nombre'] ?? 'Sin nombre'),
                yearlyData: {}, // Se llenará cuando se seleccione un estudiante
              ),
            )
            .toList();
      } else {
        throw Exception('No se pudieron cargar los estudiantes');
      }
    } catch (e) {
      print('Error cargando estudiantes: $e');
      // En caso de error, usar algunos datos de ejemplo
      _mockStudentData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar datos de un estudiante específico
  Future<void> fetchStudentData(String studentId, int years) async {
    _isLoading = true;
    _yearsToConsider = years;
    notifyListeners();

    try {
      // Primero, conseguimos las gestiones disponibles
      final sessions = await ApiService.getAcademicSessions();

      if (sessions == null || sessions.isEmpty) {
        throw Exception('No se pudieron cargar las gestiones académicas');
      }

      // Seleccionar las últimas 'n' gestiones según el parámetro years
      final recentSessions = sessions.take(years).toList();
      Map<String, List<SubjectPerformance>> yearlyData = {};

      // Para cada gestión, cargar las notas del estudiante
      for (var session in recentSessions) {
        final sessionYear = session['anio_escolar'].toString();
        final grades = await ApiService.getStudentGradesBySession(
          studentId,
          sessionYear,
        );

        if (grades != null && grades.isNotEmpty) {
          // Procesar los datos de notas para esta gestión
          yearlyData[sessionYear] = _processGradesForYear(grades, sessionYear);
        }
      }

      // Buscar los datos del estudiante para obtener su nombre
      final userData = _students.firstWhere(
        (s) => s.id == studentId,
        orElse: () => StudentPerformance(
          id: studentId,
          name: 'Estudiante',
          yearlyData: {},
        ),
      );

      _selectedStudent = StudentPerformance(
        id: studentId,
        name: userData.name,
        yearlyData: yearlyData,
      );
    } catch (e) {
      print('Error cargando datos del estudiante: $e');
      // En caso de error, usar el estudiante de la lista de ejemplo
      _selectedStudent = _students.firstWhere(
        (student) => student.id == studentId,
        orElse: () => StudentPerformance(
          id: studentId,
          name: 'Estudiante Desconocido',
          yearlyData: _mockYearlyData(),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Procesar las notas para un año específico
  List<SubjectPerformance> _processGradesForYear(
    List<dynamic> grades,
    String year,
  ) {
    // Mapa para agrupar materias por nombre
    Map<String, Map<String, dynamic>> materiasMap = {};

    // Procesar cada entrada de calificaciones
    for (var item in grades) {
      final nombreMateria = _normalizeString(
        item['nombre_materia'] ?? 'Sin nombre',
      );

      // Si es la primera vez que vemos esta materia, inicializar
      if (!materiasMap.containsKey(nombreMateria)) {
        materiasMap[nombreMateria] = {
          'nombre_materia': nombreMateria,
          'notas': [],
          'total_dimensiones': 0.0,
        };
      }

      // Calcular promedio de dimensiones para este trimestre
      if (item['dimensiones'] != null &&
          item['dimensiones'] is List &&
          (item['dimensiones'] as List).isNotEmpty) {
        List<dynamic> dimensiones = item['dimensiones'];
        for (var dim in dimensiones) {
          if (dim['promedio'] != null) {
            materiasMap[nombreMateria]!['total_dimensiones'] +=
                dim['promedio'] as num;
            materiasMap[nombreMateria]!['notas'].add(dim['promedio']);
          }
        }
      }
    }

    // Calcular promedio anual para cada materia
    List<SubjectPerformance> result = [];

    materiasMap.forEach((nombre, data) {
      // Contar los trimestres (cantidad de registros para esta materia)
      int cantidadTrimestres = grades
          .where((g) => _normalizeString(g['nombre_materia'] ?? '') == nombre)
          .length;

      cantidadTrimestres = cantidadTrimestres > 0 ? cantidadTrimestres : 1;

      // Calcular promedio: total de notas de dimensiones / cantidad de trimestres
      double promedioAnual = data['total_dimensiones'] / cantidadTrimestres;

      // La nota máxima es 100
      promedioAnual = promedioAnual > 100 ? 100 : promedioAnual;

      result.add(
        SubjectPerformance(
          subjectName: nombre,
          average: double.parse(promedioAnual.toStringAsFixed(2)),
          year: year,
        ),
      );
    });

    return result;
  }

  void selectSubject(String subjectName) {
    _selectedSubject = subjectName;
    notifyListeners();
  }

  void setYearsToConsider(int years) {
    _yearsToConsider = years;
    notifyListeners();
  }

  // Método para calcular predicción
  double? predictNextScore(List<SubjectPerformance> performances) {
    if (performances.length < 2) return null;

    List<double> x = [];
    List<double> y = [];

    for (int i = 0; i < performances.length; i++) {
      x.add(i + 1.0);
      y.add(performances[i].average);
    }

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

  // Actualizar generación de comentarios para usar el mismo formato que en LibretaIA.jsx
  String generateComment(List<SubjectPerformance> performances) {
    if (performances.length < 2) {
      return "No hay suficientes datos para analizar la evolución del estudiante.";
    }

    double inicio = performances.first.average;
    double fin = performances.last.average;
    double tendencia = fin - inicio;

    if (tendencia > 5) {
      return "El estudiante muestra una mejora notable en su desempeño, subiendo de ${inicio.toStringAsFixed(2)} a ${fin.toStringAsFixed(2)}. Se espera que continúe con buenos resultados si mantiene este ritmo.";
    } else if (tendencia > 0) {
      return "El estudiante presenta una leve mejora, pasando de ${inicio.toStringAsFixed(2)} a ${fin.toStringAsFixed(2)}. Puede reforzar su estudio para acelerar el progreso.";
    } else if (tendencia == 0) {
      return "El promedio del estudiante se ha mantenido constante (${inicio.toStringAsFixed(2)}). Es recomendable implementar nuevas estrategias de aprendizaje.";
    } else {
      return "El rendimiento del estudiante ha disminuido de ${inicio.toStringAsFixed(2)} a ${fin.toStringAsFixed(2)}. Se sugiere intervención pedagógica para mejorar su desempeño.";
    }
  }

  // Función para normalizar texto con caracteres especiales
  String _normalizeString(String text) {
    return text
        .replaceAll('Ã¡', 'á')
        .replaceAll('Ã©', 'é')
        .replaceAll('Ã­', 'í')
        .replaceAll('Ã³', 'ó')
        .replaceAll('Ãº', 'ú')
        .replaceAll('Ã±', 'ñ')
        .replaceAll('Ã', 'í');
  }

  // Datos de ejemplo para desarrollo (solo se usan en caso de error)
  void _mockStudentData() {
    _students = [
      StudentPerformance(
        id: '1',
        name: 'Juan Pérez',
        yearlyData: {
          '2022': [
            SubjectPerformance(
              subjectName: 'Matemáticas',
              average: 75,
              year: '2022',
            ),
            SubjectPerformance(
              subjectName: 'Ciencias',
              average: 82,
              year: '2022',
            ),
            SubjectPerformance(
              subjectName: 'Historia',
              average: 65,
              year: '2022',
            ),
          ],
          '2023': [
            SubjectPerformance(
              subjectName: 'Matemáticas',
              average: 78,
              year: '2023',
            ),
            SubjectPerformance(
              subjectName: 'Ciencias',
              average: 85,
              year: '2023',
            ),
            SubjectPerformance(
              subjectName: 'Historia',
              average: 70,
              year: '2023',
            ),
          ],
          '2024': [
            SubjectPerformance(
              subjectName: 'Matemáticas',
              average: 83,
              year: '2024',
            ),
            SubjectPerformance(
              subjectName: 'Ciencias',
              average: 88,
              year: '2024',
            ),
            SubjectPerformance(
              subjectName: 'Historia',
              average: 75,
              year: '2024',
            ),
          ],
        },
      ),
      // Puedes añadir más estudiantes de ejemplo si lo deseas
    ];
  }

  Map<String, List<SubjectPerformance>> _mockYearlyData() {
    return {
      '2022': [
        SubjectPerformance(
          subjectName: 'Matemáticas',
          average: 0,
          year: '2022',
        ),
        SubjectPerformance(subjectName: 'Ciencias', average: 0, year: '2022'),
        SubjectPerformance(subjectName: 'Historia', average: 0, year: '2022'),
      ],
      '2023': [
        SubjectPerformance(
          subjectName: 'Matemáticas',
          average: 0,
          year: '2023',
        ),
        SubjectPerformance(subjectName: 'Ciencias', average: 0, year: '2023'),
        SubjectPerformance(subjectName: 'Historia', average: 0, year: '2023'),
      ],
      '2024': [
        SubjectPerformance(
          subjectName: 'Matemáticas',
          average: 0,
          year: '2024',
        ),
        SubjectPerformance(subjectName: 'Ciencias', average: 0, year: '2024'),
        SubjectPerformance(subjectName: 'Historia', average: 0, year: '2024'),
      ],
    };
  }

  // Fetch available academic sessions
  Future<List<String>> fetchAcademicSessions() async {
    try {
      final sessions = await ApiService.getAcademicSessions();
      if (sessions != null && sessions.isNotEmpty) {
        return sessions
            .map((session) => session['anio_escolar'].toString())
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching academic sessions: $e');
      return [];
    }
  }

  // Fetch student data with a specific session range
  Future<void> fetchStudentDataWithRange(
    String studentId,
    String initialSession,
    String predictiveSession,
  ) async {
    try {
      setLoading(true);

      // Primero cargamos todos los datos del estudiante
      final allSessions = await ApiService.getAcademicSessions();

      if (allSessions == null || allSessions.isEmpty) {
        throw Exception('No se pudieron cargar las gestiones académicas');
      }

      // Filtrar solo las sesiones dentro del rango solicitado
      List<dynamic> filteredSessions = allSessions.where((session) {
        String yearStr = session['anio_escolar'].toString();
        int year = int.tryParse(yearStr) ?? 0;
        int initialYear = int.tryParse(initialSession) ?? 0;
        int predictiveYear = int.tryParse(predictiveSession) ?? 0;

        return year >= initialYear && year <= predictiveYear;
      }).toList();

      // Ordenar las sesiones por año (ascendente)
      filteredSessions.sort((a, b) {
        int yearA = int.tryParse(a['anio_escolar'].toString()) ?? 0;
        int yearB = int.tryParse(b['anio_escolar'].toString()) ?? 0;
        return yearA.compareTo(yearB);
      });

      // Si no hay sesiones en el rango, mostrar mensaje
      if (filteredSessions.isEmpty) {
        _selectedStudent = StudentPerformance(
          id: studentId,
          name: 'Estudiante',
          yearlyData: {},
        );
        setLoading(false);
        return;
      }

      // Cargar datos de cada sesión filtrada
      Map<String, List<SubjectPerformance>> yearlyData = {};

      for (var session in filteredSessions) {
        final sessionYear = session['anio_escolar'].toString();
        final grades = await ApiService.getStudentGradesBySession(
          studentId,
          sessionYear,
        );

        if (grades != null && grades.isNotEmpty) {
          // Procesar los datos de notas para esta gestión
          yearlyData[sessionYear] = _processGradesForYear(grades, sessionYear);
        }
      }

      // Buscar nombre del estudiante - usando getAllUsers en lugar de getUserById
      String studentName = 'Estudiante';
      try {
        final usersData = await ApiService.getAllUsers();
        if (usersData != null) {
          final matchingUser = usersData.firstWhere(
            (user) => user['id'].toString() == studentId,
            orElse: () => {'nombre': 'Estudiante'},
          );

          if (matchingUser['nombre'] != null) {
            studentName = _normalizeString(matchingUser['nombre']);
          }
        }
      } catch (e) {
        print('Error obteniendo nombre del estudiante: $e');
      }

      _selectedStudent = StudentPerformance(
        id: studentId,
        name: studentName,
        yearlyData: yearlyData,
      );

      // Limpiar selección de materia anterior si es necesario
      if (_selectedSubject.isNotEmpty) {
        // Verificar si la materia anteriormente seleccionada existe en el nuevo rango
        bool materiaExiste = false;
        yearlyData.forEach((year, performances) {
          for (var perf in performances) {
            if (perf.subjectName == _selectedSubject) {
              materiaExiste = true;
              break;
            }
          }
        });

        if (!materiaExiste) {
          _selectedSubject = '';
        }
      }

      setLoading(false);
    } catch (e) {
      print('Error cargando datos del estudiante en rango: $e');

      // En caso de error, usar datos de ejemplo
      _selectedStudent = StudentPerformance(
        id: studentId,
        name: 'Estudiante',
        yearlyData: {},
      );

      setLoading(false);
    }
  }

  // Método auxiliar para modificar el estado de carga
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Método auxiliar para establecer el estudiante seleccionado
  void setSelectedStudent(StudentPerformance student) {
    _selectedStudent = student;
    notifyListeners();
  }
}
