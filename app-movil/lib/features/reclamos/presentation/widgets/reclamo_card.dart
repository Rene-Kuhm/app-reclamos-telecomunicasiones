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
    final prioridadColor = _getPrioridadColor(reclamo.prioridad);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Colored left border indicator
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: prioridadColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),

          // Main content
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 16,
                  top: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with numero and estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reclamo.numero != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${reclamo.numero}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ),
                        EstadoChip(estado: reclamo.estado),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      reclamo.titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
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
                            height: 1.4,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),

                    // Footer with metadata
                    Row(
                      children: [
                        // Prioridad
                        PrioridadIndicator(prioridad: reclamo.prioridad),
                        const SizedBox(width: 12),

                        // Categoria with icon
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoriaIcon(reclamo.categoria),
                                size: 14,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reclamo.categoriaDisplayName,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Date with icon
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatRelative(reclamo.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad.toUpperCase()) {
      case 'URGENTE':
        return const Color(0xFFD32F2F);
      case 'ALTA':
        return const Color(0xFFEF6C00);
      case 'MEDIA':
        return const Color(0xFFFFA000);
      case 'BAJA':
        return const Color(0xFF388E3C);
      default:
        return const Color(0xFF757575);
    }
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
