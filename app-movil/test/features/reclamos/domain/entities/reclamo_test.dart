import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil/features/reclamos/domain/entities/reclamo.dart';

void main() {
  group('Reclamo Entity', () {
    test('should create a reclamo with all properties', () {
      final now = DateTime.now();
      final reclamo = Reclamo(
        id: '1',
        titulo: 'Internet no funciona',
        descripcion: 'No hay conexión a internet desde ayer',
        categoria: 'INTERNET_FIBRA',
        prioridad: 'ALTA',
        estado: 'ABIERTO',
        usuarioId: 'user1',
        createdAt: now,
        updatedAt: now,
      );

      expect(reclamo.id, '1');
      expect(reclamo.titulo, 'Internet no funciona');
      expect(reclamo.descripcion, 'No hay conexión a internet desde ayer');
      expect(reclamo.categoria, 'INTERNET_FIBRA');
      expect(reclamo.prioridad, 'ALTA');
      expect(reclamo.estado, 'ABIERTO');
      expect(reclamo.usuarioId, 'user1');
      expect(reclamo.createdAt, now);
      expect(reclamo.updatedAt, now);
    });

    test('should create a reclamo with optional fields as null', () {
      final now = DateTime.now();
      final reclamo = Reclamo(
        id: '1',
        titulo: 'Test',
        descripcion: 'Test description',
        categoria: 'INTERNET_ADSL',
        prioridad: 'MEDIA',
        estado: 'ABIERTO',
        usuarioId: 'user1',
        createdAt: now,
        updatedAt: now,
      );

      expect(reclamo.tecnicoAsignadoId, null);
      expect(reclamo.fechaResolucion, null);
      expect(reclamo.numero, null);
    });

    group('Estado checks', () {
      test('should handle all estados correctly', () {
        final estados = [
          'ABIERTO',
          'ASIGNADO',
          'EN_CURSO',
          'EN_REVISION',
          'CERRADO',
          'RECHAZADO',
        ];

        for (final estado in estados) {
          final reclamo = Reclamo(
            id: '1',
            titulo: 'Test',
            descripcion: 'Test',
            categoria: 'INTERNET_FIBRA',
            prioridad: 'MEDIA',
            estado: estado,
            usuarioId: 'user1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(reclamo.estado, estado);
        }
      });
    });

    group('Prioridad checks', () {
      test('should handle all prioridades correctly', () {
        final prioridades = ['BAJA', 'MEDIA', 'ALTA', 'URGENTE'];

        for (final prioridad in prioridades) {
          final reclamo = Reclamo(
            id: '1',
            titulo: 'Test',
            descripcion: 'Test',
            categoria: 'INTERNET_FIBRA',
            prioridad: prioridad,
            estado: 'ABIERTO',
            usuarioId: 'user1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(reclamo.prioridad, prioridad);
        }
      });
    });

    group('Categoria checks', () {
      test('should handle all categorias correctly', () {
        final categorias = [
          'INTERNET_ADSL',
          'INTERNET_FIBRA',
          'TELEFONO_ADSL',
          'TELEFONO_FIBRA',
          'TV_SENSA',
        ];

        for (final categoria in categorias) {
          final reclamo = Reclamo(
            id: '1',
            titulo: 'Test',
            descripcion: 'Test',
            categoria: categoria,
            prioridad: 'MEDIA',
            estado: 'ABIERTO',
            usuarioId: 'user1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(reclamo.categoria, categoria);
        }
      });
    });

    test('should support equality comparison', () {
      final now = DateTime.now();
      final reclamo1 = Reclamo(
        id: '1',
        titulo: 'Test',
        descripcion: 'Description',
        categoria: 'INTERNET_FIBRA',
        prioridad: 'ALTA',
        estado: 'ABIERTO',
        usuarioId: 'user1',
        createdAt: now,
        updatedAt: now,
      );

      final reclamo2 = Reclamo(
        id: '1',
        titulo: 'Test',
        descripcion: 'Description',
        categoria: 'INTERNET_FIBRA',
        prioridad: 'ALTA',
        estado: 'ABIERTO',
        usuarioId: 'user1',
        createdAt: now,
        updatedAt: now,
      );

      final reclamo3 = Reclamo(
        id: '2',
        titulo: 'Different',
        descripcion: 'Different',
        categoria: 'TELEFONO_ADSL',
        prioridad: 'BAJA',
        estado: 'CERRADO',
        usuarioId: 'user2',
        createdAt: now,
        updatedAt: now,
      );

      expect(reclamo1, equals(reclamo2));
      expect(reclamo1, isNot(equals(reclamo3)));
    });

    test('should have same hashCode for equal reclamos', () {
      final now = DateTime.now();
      final reclamo1 = Reclamo(
        id: '1',
        titulo: 'Test',
        descripcion: 'Description',
        categoria: 'INTERNET_FIBRA',
        prioridad: 'ALTA',
        estado: 'ABIERTO',
        usuarioId: 'user1',
        createdAt: now,
        updatedAt: now,
      );

      final reclamo2 = Reclamo(
        id: '1',
        titulo: 'Test',
        descripcion: 'Description',
        categoria: 'INTERNET_FIBRA',
        prioridad: 'ALTA',
        estado: 'ABIERTO',
        usuarioId: 'user1',
        createdAt: now,
        updatedAt: now,
      );

      expect(reclamo1.hashCode, equals(reclamo2.hashCode));
    });
  });
}
