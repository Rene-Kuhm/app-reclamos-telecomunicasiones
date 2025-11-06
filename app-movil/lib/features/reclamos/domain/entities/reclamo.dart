import 'package:equatable/equatable.dart';

/// Reclamo (Claim) entity
class Reclamo extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String prioridad;
  final String estado;
  final String usuarioId;
  final String? tecnicoAsignadoId;
  final DateTime? fechaResolucion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reclamo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.prioridad,
    required this.estado,
    required this.usuarioId,
    this.tecnicoAsignadoId,
    this.fechaResolucion,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        titulo,
        descripcion,
        categoria,
        prioridad,
        estado,
        usuarioId,
        tecnicoAsignadoId,
        fechaResolucion,
        createdAt,
        updatedAt,
      ];

  /// Get estado display name
  String get estadoDisplayName {
    switch (estado.toUpperCase()) {
      case 'ABIERTO':
        return 'Abierto';
      case 'ASIGNADO':
        return 'Asignado';
      case 'EN_CURSO':
        return 'En Curso';
      case 'EN_REVISION':
        return 'En Revisión';
      case 'CERRADO':
        return 'Cerrado';
      case 'RECHAZADO':
        return 'Rechazado';
      default:
        return estado;
    }
  }

  /// Get prioridad display name
  String get prioridadDisplayName {
    switch (prioridad.toUpperCase()) {
      case 'BAJA':
        return 'Baja';
      case 'MEDIA':
        return 'Media';
      case 'ALTA':
        return 'Alta';
      case 'URGENTE':
        return 'Urgente';
      default:
        return prioridad;
    }
  }

  /// Get categoria display name
  String get categoriaDisplayName {
    switch (categoria.toUpperCase()) {
      case 'INTERNET_ADSL':
        return 'Internet ADSL';
      case 'INTERNET_FIBRA':
        return 'Internet Fibra';
      case 'TELEFONO_ADSL':
        return 'Teléfono ADSL';
      case 'TELEFONO_FIBRA':
        return 'Teléfono Fibra';
      case 'TV_SENSA':
        return 'TV Sensa';
      default:
        return categoria;
    }
  }

  /// Check if reclamo is open
  bool get isOpen {
    return estado.toUpperCase() == 'ABIERTO';
  }

  /// Check if reclamo is closed
  bool get isClosed {
    return estado.toUpperCase() == 'CERRADO';
  }

  /// Check if reclamo is assigned
  bool get isAssigned {
    return tecnicoAsignadoId != null;
  }

  /// Copy with method
  Reclamo copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? categoria,
    String? prioridad,
    String? estado,
    String? usuarioId,
    String? tecnicoAsignadoId,
    DateTime? fechaResolucion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reclamo(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      usuarioId: usuarioId ?? this.usuarioId,
      tecnicoAsignadoId: tecnicoAsignadoId ?? this.tecnicoAsignadoId,
      fechaResolucion: fechaResolucion ?? this.fechaResolucion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
