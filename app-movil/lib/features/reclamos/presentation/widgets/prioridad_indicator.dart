import 'package:flutter/material.dart';

/// Prioridad indicator widget
class PrioridadIndicator extends StatelessWidget {
  final String prioridad;
  final bool showLabel;

  const PrioridadIndicator({
    super.key,
    required this.prioridad,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getPrioridadConfig(prioridad);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          config.icon,
          size: 16,
          color: config.color,
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            config.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: config.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }

  _PrioridadConfig _getPrioridadConfig(String prioridad) {
    switch (prioridad.toUpperCase()) {
      case 'BAJA':
        return _PrioridadConfig(
          label: 'Baja',
          icon: Icons.arrow_downward,
          color: Colors.green,
        );
      case 'MEDIA':
        return _PrioridadConfig(
          label: 'Media',
          icon: Icons.remove,
          color: Colors.orange,
        );
      case 'ALTA':
        return _PrioridadConfig(
          label: 'Alta',
          icon: Icons.arrow_upward,
          color: Colors.red,
        );
      case 'URGENTE':
        return _PrioridadConfig(
          label: 'Urgente',
          icon: Icons.priority_high,
          color: Colors.red.shade900,
        );
      default:
        return _PrioridadConfig(
          label: prioridad,
          icon: Icons.help_outline,
          color: Colors.grey,
        );
    }
  }
}

class _PrioridadConfig {
  final String label;
  final IconData icon;
  final Color color;

  _PrioridadConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}
