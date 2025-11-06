import 'package:equatable/equatable.dart';

/// Notificacion entity
class Notificacion extends Equatable {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final bool leida;
  final String usuarioId;
  final String? reclamoId;
  final DateTime createdAt;

  const Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.leida,
    required this.usuarioId,
    this.reclamoId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        titulo,
        mensaje,
        tipo,
        leida,
        usuarioId,
        reclamoId,
        createdAt,
      ];

  Notificacion copyWith({
    String? id,
    String? titulo,
    String? mensaje,
    String? tipo,
    bool? leida,
    String? usuarioId,
    String? reclamoId,
    DateTime? createdAt,
  }) {
    return Notificacion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      leida: leida ?? this.leida,
      usuarioId: usuarioId ?? this.usuarioId,
      reclamoId: reclamoId ?? this.reclamoId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
