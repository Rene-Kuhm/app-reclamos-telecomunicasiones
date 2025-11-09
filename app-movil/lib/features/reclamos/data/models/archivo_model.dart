import 'package:freezed_annotation/freezed_annotation.dart';

part 'archivo_model.freezed.dart';
part 'archivo_model.g.dart';

/// Archivo entity
class Archivo {
  final String id;
  final String nombre;
  final String url;
  final String tipo;
  final int tamano;
  final String? reclamoId;
  final DateTime uploadedAt;
  final Map<String, dynamic>? uploadedBy;

  const Archivo({
    required this.id,
    required this.nombre,
    required this.url,
    required this.tipo,
    required this.tamano,
    this.reclamoId,
    required this.uploadedAt,
    this.uploadedBy,
  });

  /// Get file extension
  String get extension {
    return nombre.split('.').last.toLowerCase();
  }

  /// Check if it's an image
  bool get isImage {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension) ||
        tipo.startsWith('image/');
  }

  /// Check if it's a PDF
  bool get isPDF {
    return extension == 'pdf' || tipo == 'application/pdf';
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
    required String nombre,
    required String url,
    required String tipo,
    required int tamano,
    @JsonKey(name: 'reclamo_id') String? reclamoId,
    @JsonKey(name: 'uploadedAt') required DateTime uploadedAt,
    @JsonKey(name: 'uploadedBy') Map<String, dynamic>? uploadedBy,
  }) = _ArchivoModel;

  const ArchivoModel._();

  /// From JSON
  factory ArchivoModel.fromJson(Map<String, dynamic> json) =>
      _$ArchivoModelFromJson(json);

  /// To domain entity
  Archivo toEntity() {
    return Archivo(
      id: id,
      nombre: nombre,
      url: url,
      tipo: tipo,
      tamano: tamano,
      reclamoId: reclamoId,
      uploadedAt: uploadedAt,
      uploadedBy: uploadedBy,
    );
  }
}
