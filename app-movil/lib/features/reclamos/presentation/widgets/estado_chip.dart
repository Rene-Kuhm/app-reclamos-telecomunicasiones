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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: config.textColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
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
