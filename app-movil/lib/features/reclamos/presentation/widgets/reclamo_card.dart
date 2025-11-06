import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/reclamo.dart';
import 'estado_chip.dart';
import 'prioridad_indicator.dart';

/// Reclamo card widget
class ReclamoCard extends StatelessWidget {
  final Reclamo reclamo;
  final VoidCallback? onTap;

  const ReclamoCard({
    super.key,
    required this.reclamo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with numero and estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (reclamo.numero != null)
                    Text(
                      '#${reclamo.numero}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  EstadoChip(estado: reclamo.estado),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                reclamo.titulo,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                reclamo.descripcion,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer with metadata
              Row(
                children: [
                  // Prioridad
                  PrioridadIndicator(prioridad: reclamo.prioridad),
                  const SizedBox(width: 12),

                  // Categoria
                  Icon(
                    _getCategoriaIcon(reclamo.categoria),
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      reclamo.categoriaDisplayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Date
                  Text(
                    DateFormatter.formatRelative(reclamo.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoriaIcon(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'INTERNET_ADSL':
      case 'INTERNET_FIBRA':
        return Icons.wifi;
      case 'TELEFONO_ADSL':
      case 'TELEFONO_FIBRA':
        return Icons.phone;
      case 'TV_SENSA':
        return Icons.tv;
      default:
        return Icons.help_outline;
    }
  }
}
