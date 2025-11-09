import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reclamo.dart';
import '../providers/reclamo_detail_provider.dart';

/// Estados disponibles en la aplicacion
enum EstadoReclamo {
  abierto,
  asignado,
  enCurso,
  enRevision,
  cerrado,
  rechazado;

  String get value {
    switch (this) {
      case EstadoReclamo.abierto:
        return 'ABIERTO';
      case EstadoReclamo.asignado:
        return 'ASIGNADO';
      case EstadoReclamo.enCurso:
        return 'EN_CURSO';
      case EstadoReclamo.enRevision:
        return 'EN_REVISION';
      case EstadoReclamo.cerrado:
        return 'CERRADO';
      case EstadoReclamo.rechazado:
        return 'RECHAZADO';
    }
  }

  String get displayName {
    switch (this) {
      case EstadoReclamo.abierto:
        return 'Abierto';
      case EstadoReclamo.asignado:
        return 'Asignado';
      case EstadoReclamo.enCurso:
        return 'En Curso';
      case EstadoReclamo.enRevision:
        return 'En Revisión';
      case EstadoReclamo.cerrado:
        return 'Cerrado';
      case EstadoReclamo.rechazado:
        return 'Rechazado';
    }
  }

  static EstadoReclamo? fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ABIERTO':
        return EstadoReclamo.abierto;
      case 'ASIGNADO':
        return EstadoReclamo.asignado;
      case 'EN_CURSO':
        return EstadoReclamo.enCurso;
      case 'EN_REVISION':
        return EstadoReclamo.enRevision;
      case 'CERRADO':
        return EstadoReclamo.cerrado;
      case 'RECHAZADO':
        return EstadoReclamo.rechazado;
      default:
        return null;
    }
  }
}

/// Change estado dialog widget
class ChangeEstadoDialog extends ConsumerStatefulWidget {
  final String reclamoId;
  final String currentEstado;

  const ChangeEstadoDialog({
    super.key,
    required this.reclamoId,
    required this.currentEstado,
  });

  @override
  ConsumerState<ChangeEstadoDialog> createState() => _ChangeEstadoDialogState();
}

class _ChangeEstadoDialogState extends ConsumerState<ChangeEstadoDialog> {
  EstadoReclamo? _selectedEstado;
  final _motivoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  List<EstadoReclamo> _getAvailableEstados() {
    final currentEstado = EstadoReclamo.fromString(widget.currentEstado);

    // Transiciones válidas según el estado actual
    switch (currentEstado) {
      case EstadoReclamo.abierto:
        return [EstadoReclamo.asignado, EstadoReclamo.rechazado];
      case EstadoReclamo.asignado:
        return [EstadoReclamo.enCurso, EstadoReclamo.rechazado];
      case EstadoReclamo.enCurso:
        return [EstadoReclamo.enRevision, EstadoReclamo.abierto];
      case EstadoReclamo.enRevision:
        return [EstadoReclamo.cerrado, EstadoReclamo.enCurso];
      case EstadoReclamo.cerrado:
        return []; // No se puede cambiar
      case EstadoReclamo.rechazado:
        return [EstadoReclamo.abierto];
      default:
        return [];
    }
  }

  Future<void> _cambiarEstado() async {
    if (_selectedEstado == null) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(reclamoDetailProvider(widget.reclamoId).notifier)
        .cambiarEstado(_selectedEstado!.value);

    if (mounted) {
      Navigator.pop(context, success);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Estado actualizado correctamente'
              : 'Error al cambiar estado'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableEstados = _getAvailableEstados();
    final currentEstadoEnum = EstadoReclamo.fromString(widget.currentEstado);

    if (availableEstados.isEmpty) {
      return AlertDialog(
        title: const Text('Cambiar Estado'),
        content: const Text('Este reclamo no puede cambiar de estado'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Cambiar Estado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado actual: ${currentEstadoEnum?.displayName ?? widget.currentEstado}'),
          const SizedBox(height: 16),
          DropdownButtonFormField<EstadoReclamo>(
            value: _selectedEstado,
            decoration: const InputDecoration(
              labelText: 'Nuevo estado',
              border: OutlineInputBorder(),
            ),
            items: availableEstados
                .map((estado) => DropdownMenuItem(
                      value: estado,
                      child: Text(estado.displayName),
                    ))
                .toList(),
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() => _selectedEstado = value);
                  },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _motivoController,
            decoration: const InputDecoration(
              labelText: 'Motivo (opcional)',
              hintText: 'Describe el motivo del cambio...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            enabled: !_isLoading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedEstado == null ? null : _cambiarEstado,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Cambiar'),
        ),
      ],
    );
  }
}
