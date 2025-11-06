import 'package:flutter/material.dart';

/// Estado chip widget
class EstadoChip extends StatelessWidget {
  final String estado;

  const EstadoChip({
    super.key,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getEstadoConfig(estado);

    return Chip(
      label: Text(
        config.label,
        style: TextStyle(
          color: config.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: config.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  _EstadoConfig _getEstadoConfig(String estado) {
    switch (estado.toUpperCase()) {
      case 'ABIERTO':
        return _EstadoConfig(
          label: 'Abierto',
          backgroundColor: Colors.blue.shade100,
          textColor: Colors.blue.shade900,
        );
      case 'ASIGNADO':
        return _EstadoConfig(
          label: 'Asignado',
          backgroundColor: Colors.orange.shade100,
          textColor: Colors.orange.shade900,
        );
      case 'EN_CURSO':
        return _EstadoConfig(
          label: 'En Curso',
          backgroundColor: Colors.purple.shade100,
          textColor: Colors.purple.shade900,
        );
      case 'EN_REVISION':
        return _EstadoConfig(
          label: 'En Revisión',
          backgroundColor: Colors.amber.shade100,
          textColor: Colors.amber.shade900,
        );
      case 'CERRADO':
        return _EstadoConfig(
          label: 'Cerrado',
          backgroundColor: Colors.green.shade100,
          textColor: Colors.green.shade900,
        );
      case 'RECHAZADO':
        return _EstadoConfig(
          label: 'Rechazado',
          backgroundColor: Colors.red.shade100,
          textColor: Colors.red.shade900,
        );
      default:
        return _EstadoConfig(
          label: estado,
          backgroundColor: Colors.grey.shade100,
          textColor: Colors.grey.shade900,
        );
    }
  }
}

class _EstadoConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  _EstadoConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}
