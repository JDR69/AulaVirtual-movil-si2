class StudentPerformance {
  final String id;
  final String name;
  final Map<String, List<SubjectPerformance>> yearlyData;

  StudentPerformance({
    required this.id,
    required this.name,
    required this.yearlyData,
  });

  factory StudentPerformance.fromJson(Map<String, dynamic> json) {
    Map<String, List<SubjectPerformance>> processedData = {};
    
    // Procesar datos por año
    (json['datos'] as Map<String, dynamic>).forEach((year, subjects) {
      processedData[year] = (subjects as List)
          .map((subject) => SubjectPerformance.fromJson(subject))
          .toList();
    });

    return StudentPerformance(
      id: json['id'],
      name: json['nombre'],
      yearlyData: processedData,
    );
  }
}

class SubjectPerformance {
  final String subjectName;
  final double average;
  final String year;

  SubjectPerformance({
    required this.subjectName,
    required this.average,
    required this.year,
  });

  factory SubjectPerformance.fromJson(Map<String, dynamic> json) {
    return SubjectPerformance(
      subjectName: json['nombre_materia'],
      average: json['promedio']?.toDouble() ?? 0.0,
      year: json['anio'] ?? '',
    );
  }
}