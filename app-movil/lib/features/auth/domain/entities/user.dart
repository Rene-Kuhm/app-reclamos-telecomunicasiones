import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  final String id;
  final String nombre;
  final String? apellido;
  final String email;
  final String? telefono;
  final String? direccion;
  final String? dni;
  final String rol;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.nombre,
    this.apellido,
    required this.email,
    this.telefono,
    this.direccion,
    this.dni,
    required this.rol,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        apellido,
        email,
        telefono,
        direccion,
        dni,
        rol,
        activo,
        createdAt,
        updatedAt,
      ];

  /// Check if user is admin
  bool get isAdmin => rol.toUpperCase() == 'ADMINISTRADOR';

  /// Check if user is supervisor
  bool get isSupervisor => rol.toUpperCase() == 'SUPERVISOR';

  /// Check if user is tecnico
  bool get isTecnico => rol.toUpperCase() == 'TECNICO';

  /// Check if user is profesional
  bool get isProfesional => rol.toUpperCase() == 'PROFESIONAL';

  /// Get role display name
  String get rolDisplayName {
    switch (rol.toUpperCase()) {
      case 'ADMINISTRADOR':
        return 'Administrador';
      case 'SUPERVISOR':
        return 'Supervisor';
      case 'TECNICO':
        return 'Técnico';
      case 'PROFESIONAL':
        return 'Profesional';
      default:
        return rol;
    }
  }

  /// Copy with method
  User copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? direccion,
    String? dni,
    String? rol,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      dni: dni ?? this.dni,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
