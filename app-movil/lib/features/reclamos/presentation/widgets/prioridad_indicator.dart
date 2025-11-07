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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: 14,
            color: config.color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 5),
            Text(
              config.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: config.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
            ),
          ],
        ],
      ),
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
