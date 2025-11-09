import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../design/app_shadows.dart';

/// Advanced search bar with AI-powered suggestions and filters
class AdvancedSearchBar extends ConsumerStatefulWidget {
  final String hint;
  final Function(String) onSearch;
  final Function(Map<String, dynamic>) onFiltersChanged;
  final List<SearchFilter> filters;
  final bool showVoiceSearch;
  final bool showQRScanner;
  final List<String> recentSearches;
  final List<SearchSuggestion> suggestions;

  const AdvancedSearchBar({
    super.key,
    this.hint = 'Buscar reclamos, clientes, técnicos...',
    required this.onSearch,
    required this.onFiltersChanged,
    this.filters = const [],
    this.showVoiceSearch = true,
    this.showQRScanner = true,
    this.recentSearches = const [],
    this.suggestions = const [],
  });

  @override
  ConsumerState<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends ConsumerState<AdvancedSearchBar>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  late final AnimationController _animationController;

  bool _isExpanded = false;
  bool _showSuggestions = false;
  bool _showFilters = false;
  Map<String, dynamic> _activeFilters = {};
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && _searchController.text.isEmpty;
      });
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    // Debounce search
    if (query != _lastQuery) {
      _lastQuery = query;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (query == _searchController.text) {
          widget.onSearch(query);
          setState(() {
            _showSuggestions = query.isNotEmpty;
          });
        }
      });
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _applyFilter(String key, dynamic value) {
    setState(() {
      if (value == null) {
        _activeFilters.remove(key);
      } else {
        _activeFilters[key] = value;
      }
    });
    widget.onFiltersChanged(_activeFilters);
  }

  void _clearSearch() {
    _searchController.clear();
    _activeFilters.clear();
    widget.onSearch('');
    widget.onFiltersChanged({});
    setState(() {
      _showSuggestions = false;
      _showFilters = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Main Search Bar
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              // Search Input Row
              Row(
                children: [
                  // Search Icon
                  Padding(
                    padding: EdgeInsets.only(left: AppSpacing.md),
                    child: Icon(
                      Icons.search,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      size: AppSpacing.iconMd,
                    ),
                  ),

                  // Search TextField
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: AppTextStyles.bodyLarge(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: AppTextStyles.bodyLarge(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onSubmitted: (value) => widget.onSearch(value),
                    ),
                  ),

                  // Action Buttons
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        size: AppSpacing.iconSm,
                      ),
                      onPressed: _clearSearch,
                    ),

                  // Filter Button with Badge
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: _activeFilters.isNotEmpty
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                          size: AppSpacing.iconMd,
                        ),
                        onPressed: _toggleFilters,
                      ),
                      if (_activeFilters.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (widget.showVoiceSearch)
                    IconButton(
                      icon: Icon(
                        Icons.mic,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        size: AppSpacing.iconMd,
                      ),
                      onPressed: _startVoiceSearch,
                    ),

                  if (widget.showQRScanner)
                    IconButton(
                      icon: Icon(
                        Icons.qr_code_scanner,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        size: AppSpacing.iconMd,
                      ),
                      onPressed: _startQRScanner,
                    ),

                  SizedBox(width: AppSpacing.xs),
                ],
              ),

              // Active Filters Display
              if (_activeFilters.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: _activeFilters.entries.map((entry) {
                      return Chip(
                        label: Text(
                          '${entry.key}: ${entry.value}',
                          style: AppTextStyles.caption(
                            color: AppColors.primary,
                          ),
                        ),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        deleteIcon: Icon(
                          Icons.close,
                          size: AppSpacing.iconXs,
                          color: AppColors.primary,
                        ),
                        onDeleted: () => _applyFilter(entry.key, null),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.2, end: 0),

        // Filters Panel
        if (_showFilters)
          Container(
            margin: EdgeInsets.only(top: AppSpacing.sm),
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros Avanzados',
                  style: AppTextStyles.titleMedium(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.md),
                ...widget.filters.map((filter) => _buildFilterWidget(filter)),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),

        // Suggestions Dropdown
        if (_showSuggestions && widget.suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: AppSpacing.xs),
            constraints: BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppShadows.medium,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.all(AppSpacing.sm),
              itemCount: widget.suggestions.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final suggestion = widget.suggestions[index];
                return ListTile(
                  leading: Icon(
                    suggestion.icon,
                    color: AppColors.primary,
                    size: AppSpacing.iconSm,
                  ),
                  title: Text(
                    suggestion.title,
                    style: AppTextStyles.bodyMedium(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  subtitle: suggestion.subtitle != null
                      ? Text(
                          suggestion.subtitle!,
                          style: AppTextStyles.caption(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        )
                      : null,
                  trailing: Icon(
                    Icons.north_west,
                    size: AppSpacing.iconXs,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  onTap: () {
                    _searchController.text = suggestion.title;
                    widget.onSearch(suggestion.title);
                    setState(() => _showSuggestions = false);
                  },
                );
              },
            ),
          ).animate().fadeIn().scale(begin: Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildFilterWidget(SearchFilter filter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (filter.type) {
      case FilterType.dropdown:
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: DropdownButtonFormField<String>(
            value: _activeFilters[filter.key],
            decoration: InputDecoration(
              labelText: filter.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            items: filter.options!.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) => _applyFilter(filter.key, value),
          ),
        );

      case FilterType.dateRange:
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: '${filter.label} - Desde',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(filter.key, 'from'),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Hasta',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(filter.key, 'to'),
                ),
              ),
            ],
          ),
        );

      case FilterType.chips:
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                filter.label,
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: filter.options!.map((option) {
                  final selected = (_activeFilters[filter.key] as List?)
                      ?.contains(option) ?? false;
                  return FilterChip(
                    label: Text(option),
                    selected: selected,
                    onSelected: (selected) {
                      final currentList = (_activeFilters[filter.key] as List?) ?? [];
                      if (selected) {
                        _applyFilter(filter.key, [...currentList, option]);
                      } else {
                        currentList.remove(option);
                        _applyFilter(filter.key,
                            currentList.isEmpty ? null : currentList);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );

      case FilterType.range:
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                filter.label,
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              RangeSlider(
                values: _activeFilters[filter.key] ?? RangeValues(0, 100),
                min: 0,
                max: 100,
                divisions: 20,
                labels: RangeLabels(
                  '${(_activeFilters[filter.key]?.start ?? 0).round()}',
                  '${(_activeFilters[filter.key]?.end ?? 100).round()}',
                ),
                onChanged: (values) => _applyFilter(filter.key, values),
              ),
            ],
          ),
        );
    }
  }

  void _startVoiceSearch() {
    // TODO: Implement voice search
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Búsqueda por voz próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startQRScanner() {
    // TODO: Implement QR scanner
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Escáner QR próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectDate(String filterKey, String type) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      final currentRange = _activeFilters[filterKey] as Map<String, DateTime>?;
      _applyFilter(filterKey, {
        ...currentRange ?? {},
        type: date,
      });
    }
  }
}

// Supporting Classes
class SearchFilter {
  final String key;
  final String label;
  final FilterType type;
  final List<String>? options;
  final dynamic defaultValue;

  const SearchFilter({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.defaultValue,
  });
}

enum FilterType {
  dropdown,
  dateRange,
  chips,
  range,
}

class SearchSuggestion {
  final String title;
  final String? subtitle;
  final IconData icon;
  final dynamic data;

  const SearchSuggestion({
    required this.title,
    this.subtitle,
    this.icon = Icons.search,
    this.data,
  });
}