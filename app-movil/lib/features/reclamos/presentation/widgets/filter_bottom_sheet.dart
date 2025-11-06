import 'package:flutter/material.dart';

/// Filter bottom sheet widget
class FilterBottomSheet extends StatefulWidget {
  final String? estadoFilter;
  final String? categoriaFilter;
  final String? prioridadFilter;
  final Function(String? estado, String? categoria, String? prioridad) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    this.estadoFilter,
    this.categoriaFilter,
    this.prioridadFilter,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedEstado;
  String? _selectedCategoria;
  String? _selectedPrioridad;

  @override
  void initState() {
    super.initState();
    _selectedEstado = widget.estadoFilter;
    _selectedCategoria = widget.categoriaFilter;
    _selectedPrioridad = widget.prioridadFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Estado filter
          Text(
            'Estado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Todos', null, _selectedEstado, (value) {
                setState(() => _selectedEstado = value);
              }),
              _buildFilterChip('Abierto', 'ABIERTO', _selectedEstado, (value) {
                setState(() => _selectedEstado = value);
              }),
              _buildFilterChip('Asignado', 'ASIGNADO', _selectedEstado, (value) {
                setState(() => _selectedEstado = value);
              }),
              _buildFilterChip('En Curso', 'EN_CURSO', _selectedEstado, (value) {
                setState(() => _selectedEstado = value);
              }),
              _buildFilterChip('Cerrado', 'CERRADO', _selectedEstado, (value) {
                setState(() => _selectedEstado = value);
              }),
            ],
          ),
          const SizedBox(height: 24),

          // Categoria filter
          Text(
            'Categoría',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Todas', null, _selectedCategoria, (value) {
                setState(() => _selectedCategoria = value);
              }),
              _buildFilterChip('Internet ADSL', 'INTERNET_ADSL', _selectedCategoria, (value) {
                setState(() => _selectedCategoria = value);
              }),
              _buildFilterChip('Internet Fibra', 'INTERNET_FIBRA', _selectedCategoria, (value) {
                setState(() => _selectedCategoria = value);
              }),
              _buildFilterChip('Teléfono', 'TELEFONO_ADSL', _selectedCategoria, (value) {
                setState(() => _selectedCategoria = value);
              }),
              _buildFilterChip('TV', 'TV_SENSA', _selectedCategoria, (value) {
                setState(() => _selectedCategoria = value);
              }),
            ],
          ),
          const SizedBox(height: 24),

          // Prioridad filter
          Text(
            'Prioridad',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Todas', null, _selectedPrioridad, (value) {
                setState(() => _selectedPrioridad = value);
              }),
              _buildFilterChip('Baja', 'BAJA', _selectedPrioridad, (value) {
                setState(() => _selectedPrioridad = value);
              }),
              _buildFilterChip('Media', 'MEDIA', _selectedPrioridad, (value) {
                setState(() => _selectedPrioridad = value);
              }),
              _buildFilterChip('Alta', 'ALTA', _selectedPrioridad, (value) {
                setState(() => _selectedPrioridad = value);
              }),
              _buildFilterChip('Urgente', 'URGENTE', _selectedPrioridad, (value) {
                setState(() => _selectedPrioridad = value);
              }),
            ],
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedEstado = null;
                      _selectedCategoria = null;
                      _selectedPrioridad = null;
                    });
                    widget.onApplyFilters(null, null, null);
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onApplyFilters(
                      _selectedEstado,
                      _selectedCategoria,
                      _selectedPrioridad,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? value,
    String? currentValue,
    Function(String?) onSelected,
  ) {
    final isSelected = currentValue == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}
