import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// Type alias for backward compatibility
typedef ApiError = ApiException;

/// Custom API exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

/// Network failure types
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Error handler utility
class ErrorHandler {
  static ApiException handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is ApiException) {
      return error;
    } else {
      return ApiException(
        message: 'Error inesperado: ${error.toString()}',
      );
    }
  }

  static ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Tiempo de espera agotado. Por favor, intenta nuevamente.',
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Solicitud cancelada',
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Error de conexión. Verifica tu conexión a internet.',
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Certificado de seguridad inválido',
        );

      case DioExceptionType.unknown:
      default:
        if (error.message?.contains('SocketException') ?? false) {
          return ApiException(
            message: 'No hay conexión a internet',
          );
        }
        return ApiException(
          message: 'Error desconocido. Por favor, intenta nuevamente.',
        );
    }
  }

  static ApiException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message = 'Error en el servidor';

    // Try to extract error message from response
    if (data != null) {
      if (data is Map) {
        message = data['message'] ?? data['error'] ?? message;
        if (data['errors'] != null && data['errors'] is List) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty) {
            message = errors.map((e) => e['msg'] ?? e.toString()).join(', ');
          }
        }
      } else if (data is String) {
        message = data;
      }
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message: message.isEmpty ? 'Solicitud inválida' : message,
          statusCode: statusCode,
          data: data,
        );

      case 401:
        return ApiException(
          message: 'No autorizado. Por favor, inicia sesión nuevamente.',
          statusCode: statusCode,
          data: data,
        );

      case 403:
        return ApiException(
          message: 'No tienes permisos para realizar esta acción',
          statusCode: statusCode,
          data: data,
        );

      case 404:
        return ApiException(
          message: 'Recurso no encontrado',
          statusCode: statusCode,
          data: data,
        );

      case 409:
        return ApiException(
          message: message.isEmpty ? 'Conflicto con los datos existentes' : message,
          statusCode: statusCode,
          data: data,
        );

      case 422:
        return ApiException(
          message: message.isEmpty ? 'Datos de validación inválidos' : message,
          statusCode: statusCode,
          data: data,
        );

      case 429:
        return ApiException(
          message: 'Demasiadas solicitudes. Por favor, intenta más tarde.',
          statusCode: statusCode,
          data: data,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ApiException(
          message: 'Error en el servidor. Por favor, intenta más tarde.',
          statusCode: statusCode,
          data: data,
        );

      default:
        return ApiException(
          message: message.isEmpty ? 'Error desconocido ($statusCode)' : message,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// Convert ApiException to Failure
  static Failure exceptionToFailure(ApiException exception) {
    if (exception.statusCode == 401) {
      return UnauthorizedFailure(exception.message);
    } else if (exception.statusCode == 404) {
      return NotFoundFailure(exception.message);
    } else if (exception.statusCode != null && exception.statusCode! >= 500) {
      return ServerFailure(exception.message);
    } else if (exception.message.contains('conexión') ||
               exception.message.contains('internet')) {
      return NetworkFailure(exception.message);
    } else if (exception.statusCode == 400 || exception.statusCode == 422) {
      return ValidationFailure(exception.message);
    } else {
      return ServerFailure(exception.message);
    }
  }
}
