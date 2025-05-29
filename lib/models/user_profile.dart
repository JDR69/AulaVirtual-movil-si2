class UserProfile {
  final int id;
  final String ci;
  final String nombre;
  final String sexo;
  final String telefono;
  final int rol;
  final String rolNombre;

  UserProfile({
    required this.id,
    required this.ci,
    required this.nombre,
    required this.sexo,
    required this.telefono,
    required this.rol,
    required this.rolNombre,

  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      ci: json['ci'],
      nombre: json['nombre'],
      sexo: json['sexo'],
      telefono: json['telefono'],
      rol: json['rol'],
      rolNombre: json['rol_nombre'],
      );
  }
}