import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil/features/auth/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    test('should create a user with all properties', () {
      final user = User(
        id: '1',
        nombre: 'John',
        apellido: 'Doe',
        email: 'john@example.com',
        rol: 'PROFESIONAL',
        activo: true,
        telefono: '1234567890',
        direccion: '123 Main St',
        dni: '12345678',
      );

      expect(user.id, '1');
      expect(user.nombre, 'John');
      expect(user.apellido, 'Doe');
      expect(user.email, 'john@example.com');
      expect(user.rol, 'PROFESIONAL');
      expect(user.activo, true);
      expect(user.telefono, '1234567890');
      expect(user.direccion, '123 Main St');
      expect(user.dni, '12345678');
    });

    test('should create a user with optional fields as null', () {
      final user = User(
        id: '1',
        nombre: 'John',
        apellido: 'Doe',
        email: 'john@example.com',
        rol: 'PROFESIONAL',
        activo: true,
      );

      expect(user.telefono, null);
      expect(user.direccion, null);
      expect(user.dni, null);
    });

    group('Role checks', () {
      test('isAdmin should return true for ADMINISTRADOR', () {
        final user = User(
          id: '1',
          nombre: 'Admin',
          apellido: 'User',
          email: 'admin@example.com',
          rol: 'ADMINISTRADOR',
          activo: true,
        );

        expect(user.isAdmin, true);
        expect(user.isSupervisor, false);
        expect(user.isTecnico, false);
        expect(user.isProfesional, false);
      });

      test('isSupervisor should return true for SUPERVISOR', () {
        final user = User(
          id: '1',
          nombre: 'Supervisor',
          apellido: 'User',
          email: 'supervisor@example.com',
          rol: 'SUPERVISOR',
          activo: true,
        );

        expect(user.isAdmin, false);
        expect(user.isSupervisor, true);
        expect(user.isTecnico, false);
        expect(user.isProfesional, false);
      });

      test('isTecnico should return true for TECNICO', () {
        final user = User(
          id: '1',
          nombre: 'Tecnico',
          apellido: 'User',
          email: 'tecnico@example.com',
          rol: 'TECNICO',
          activo: true,
        );

        expect(user.isAdmin, false);
        expect(user.isSupervisor, false);
        expect(user.isTecnico, true);
        expect(user.isProfesional, false);
      });

      test('isProfesional should return true for PROFESIONAL', () {
        final user = User(
          id: '1',
          nombre: 'Professional',
          apellido: 'User',
          email: 'pro@example.com',
          rol: 'PROFESIONAL',
          activo: true,
        );

        expect(user.isAdmin, false);
        expect(user.isSupervisor, false);
        expect(user.isTecnico, false);
        expect(user.isProfesional, true);
      });
    });

    test('should support equality comparison', () {
      final user1 = User(
        id: '1',
        nombre: 'John',
        apellido: 'Doe',
        email: 'john@example.com',
        rol: 'PROFESIONAL',
        activo: true,
      );

      final user2 = User(
        id: '1',
        nombre: 'John',
        apellido: 'Doe',
        email: 'john@example.com',
        rol: 'PROFESIONAL',
        activo: true,
      );

      final user3 = User(
        id: '2',
        nombre: 'Jane',
        apellido: 'Smith',
        email: 'jane@example.com',
        rol: 'TECNICO',
        activo: true,
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('should have same hashCode for equal users', () {
      final user1 = User(
        id: '1',
        nombre: 'John',
        apellido: 'Doe',
        email: 'john@example.com',
        rol: 'PROFESIONAL',
        activo: true,
      );

      final user2 = User(
        id: '1',
        nombre: 'John',
        apellido: 'Doe',
        email: 'john@example.com',
        rol: 'PROFESIONAL',
        activo: true,
      );

      expect(user1.hashCode, equals(user2.hashCode));
    });
  });
}
