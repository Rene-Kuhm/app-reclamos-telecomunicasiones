import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/notificacion.dart';

/// Notificacion item widget
class NotificacionItem extends StatelessWidget {
  final Notificacion notificacion;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificacionItem({
    super.key,
    required this.notificacion,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notificacion.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: notificacion.leida
            ? null
            : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getTipoColor(context, notificacion.tipo),
            child: Icon(
              _getTipoIcon(notificacion.tipo),
              color: Colors.white,
            ),
          ),
          title: Row(
            children: [
              if (!notificacion.leida)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Text(
                  notificacion.titulo,
                  style: TextStyle(
                    fontWeight:
                        notificacion.leida ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notificacion.mensaje),
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatRelative(notificacion.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          isThreeLine: true,
          onTap: onTap,
        ),
      ),
    );
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RECLAMO':
        return Icons.report_problem;
      case 'MENSAJE':
        return Icons.message;
      case 'ESTADO':
        return Icons.update;
      default:
        return Icons.notifications;
    }
  }

  Color _getTipoColor(BuildContext context, String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RECLAMO':
        return Colors.orange;
      case 'MENSAJE':
        return Colors.blue;
      case 'ESTADO':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
