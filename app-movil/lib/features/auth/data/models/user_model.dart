import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum RolUsuario {
  @JsonValue('PROFESIONAL')
  profesional,
  @JsonValue('TECNICO')
  tecnico,
  @JsonValue('SUPERVISOR')
  supervisor,
  @JsonValue('ADMINISTRADOR')
  administrador,
}

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String nombre,
    String? apellido,
    required String email,
    String? telefono,
    String? direccion,
    String? dni,
    required RolUsuario rol,
    @Default(true) bool activo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert model to entity
  User toEntity() {
    return User(
      id: id,
      nombre: nombre,
      apellido: apellido,
      email: email,
      telefono: telefono,
      direccion: direccion,
      dni: dni,
      rol: rol.name.toUpperCase(),
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      nombre: user.nombre,
      apellido: user.apellido,
      email: user.email,
      telefono: user.telefono,
      direccion: user.direccion,
      dni: user.dni,
      rol: _parseRol(user.rol),
      activo: user.activo,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  static RolUsuario _parseRol(String rol) {
    switch (rol.toUpperCase()) {
      case 'PROFESIONAL':
        return RolUsuario.profesional;
      case 'TECNICO':
        return RolUsuario.tecnico;
      case 'SUPERVISOR':
        return RolUsuario.supervisor;
      case 'ADMINISTRADOR':
        return RolUsuario.administrador;
      default:
        return RolUsuario.profesional;
    }
  }
}
