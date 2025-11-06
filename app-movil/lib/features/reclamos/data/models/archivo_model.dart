import 'package:freezed_annotation/freezed_annotation.dart';

part 'archivo_model.freezed.dart';
part 'archivo_model.g.dart';

/// Archivo entity
class Archivo {
  final String id;
  final String nombreArchivo;
  final String urlArchivo;
  final String tipoArchivo;
  final int tamano;
  final String reclamoId;
  final DateTime createdAt;

  const Archivo({
    required this.id,
    required this.nombreArchivo,
    required this.urlArchivo,
    required this.tipoArchivo,
    required this.tamano,
    required this.reclamoId,
    required this.createdAt,
  });

  /// Get file extension
  String get extension {
    return nombreArchivo.split('.').last.toLowerCase();
  }

  /// Check if it's an image
  bool get isImage {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Check if it's a PDF
  bool get isPDF {
    return extension == 'pdf';
  }

  /// Format file size
  String get formattedSize {
    if (tamano < 1024) {
      return '$tamano B';
    } else if (tamano < 1024 * 1024) {
      return '${(tamano / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(tamano / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Archivo data model
@freezed
class ArchivoModel with _$ArchivoModel {
  const factory ArchivoModel({
    required String id,
    @JsonKey(name: 'nombre_archivo') required String nombreArchivo,
    @JsonKey(name: 'url_archivo') required String urlArchivo,
    @JsonKey(name: 'tipo_archivo') required String tipoArchivo,
    required int tamano,
    @JsonKey(name: 'reclamo_id') required String reclamoId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ArchivoModel;

  const ArchivoModel._();

  /// From JSON
  factory ArchivoModel.fromJson(Map<String, dynamic> json) =>
      _$ArchivoModelFromJson(json);

  /// To domain entity
  Archivo toEntity() {
    return Archivo(
      id: id,
      nombreArchivo: nombreArchivo,
      urlArchivo: urlArchivo,
      tipoArchivo: tipoArchivo,
      tamano: tamano,
      reclamoId: reclamoId,
      createdAt: createdAt,
    );
  }
}
