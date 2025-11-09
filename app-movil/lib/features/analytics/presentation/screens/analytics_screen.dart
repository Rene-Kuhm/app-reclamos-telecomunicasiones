import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/design/app_shadows.dart';
import '../../../../core/widgets/premium/advanced_search_bar.dart';
import '../widgets/analytics_export_dialog.dart';
import '../widgets/period_selector.dart';
import '../widgets/kpi_comparison_card.dart';
import '../widgets/heatmap_calendar.dart';
import '../widgets/analytics_filter_panel.dart';
import '../providers/analytics_provider.dart';

/// Enterprise-grade Analytics Dashboard with advanced visualizations
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _animationController;
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  String _selectedPeriod = 'month';
  Map<String, dynamic> _filters = {};
  bool _isComparingPeriods = false;
  bool _showAdvancedMetrics = false;

  final List<String> _tabs = [
    'General',
    'Rendimiento',
    'Tendencias',
    'Comparación',
    'Predictivo',
    'Detallado',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _tooltipBehavior = TooltipBehavior(enable: true);
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      enableDoubleTapZooming: true,
    );

    // Load initial data
    Future.microtask(() {
      ref.read(analyticsProvider.notifier).loadAnalytics(_selectedPeriod);
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Professional Header
            _buildHeader(context, isDark),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                boxShadow: AppShadows.card,
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              ),
            ),

            // Content
            Expanded(
              child: analyticsState.when(
                data: (data) => TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralTab(data, isDark),
                    _buildPerformanceTab(data, isDark),
                    _buildTrendsTab(data, isDark),
                    _buildComparisonTab(data, isDark),
                    _buildPredictiveTab(data, isDark),
                    _buildDetailedTab(data, isDark),
                  ],
                ),
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error.toString()),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button for Export
      floatingActionButton: _buildExportFAB(),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Dashboard',
                    style: AppTextStyles.headlineMedium(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Análisis avanzado y métricas de rendimiento',
                    style: AppTextStyles.bodyMedium(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),

              // Action Buttons
              Row(
                children: [
                  // Period Selector
                  PeriodSelector(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: (period) {
                      setState(() => _selectedPeriod = period);
                      ref.read(analyticsProvider.notifier).loadAnalytics(period);
                    },
                  ),
                  SizedBox(width: AppSpacing.sm),

                  // Compare Toggle
                  _buildCompareToggle(isDark),
                  SizedBox(width: AppSpacing.sm),

                  // Filter Button
                  _buildFilterButton(isDark),
                  SizedBox(width: AppSpacing.sm),

                  // Refresh Button
                  IconButton(
                    icon: Icon(Icons.refresh, color: AppColors.primary),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(analyticsProvider.notifier).loadAnalytics(_selectedPeriod);
                    },
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Advanced Search Bar
          AdvancedSearchBar(
            hint: 'Buscar métricas, KPIs, reportes...',
            onSearch: (query) {
              // Handle search
            },
            onFiltersChanged: (filters) {
              setState(() => _filters = filters);
              ref.read(analyticsProvider.notifier).applyFilters(filters);
            },
            filters: [
              SearchFilter(
                key: 'category',
                label: 'Categoría',
                type: FilterType.dropdown,
                options: ['Internet', 'Telefonía', 'Cable', 'Todos'],
              ),
              SearchFilter(
                key: 'priority',
                label: 'Prioridad',
                type: FilterType.chips,
                options: ['Alta', 'Media', 'Baja'],
              ),
              SearchFilter(
                key: 'dateRange',
                label: 'Fecha',
                type: FilterType.dateRange,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildGeneralTab(AnalyticsData data, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Summary Cards
          _buildKPISummary(data, isDark),
          SizedBox(height: AppSpacing.lg),

          // Main Charts Grid
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1200) {
                // Desktop: 2x2 grid
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildAreaChart(data, isDark),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildPieChart(data, isDark),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBarChart(data, isDark),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildRadarChart(data, isDark),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Mobile/Tablet: Stacked
                return Column(
                  children: [
                    _buildAreaChart(data, isDark),
                    SizedBox(height: AppSpacing.lg),
                    _buildPieChart(data, isDark),
                    SizedBox(height: AppSpacing.lg),
                    _buildBarChart(data, isDark),
                    SizedBox(height: AppSpacing.lg),
                    _buildRadarChart(data, isDark),
                  ],
                );
              }
            },
          ),

          SizedBox(height: AppSpacing.lg),

          // Heatmap Calendar
          _buildHeatmapSection(data, isDark),

          SizedBox(height: AppSpacing.lg),

          // Top Performers Table
          _buildTopPerformersTable(data, isDark),
        ],
      ),
    );
  }

  Widget _buildKPISummary(AnalyticsData data, bool isDark) {
    final kpis = [
      KPIData(
        title: 'Total Reclamos',
        value: '1,234',
        change: 12.5,
        icon: Icons.analytics,
        color: AppColors.primary,
        previousValue: '1,098',
      ),
      KPIData(
        title: 'Tiempo Resolución',
        value: '2.4h',
        change: -15.3,
        icon: Icons.timer,
        color: AppColors.success,
        previousValue: '2.8h',
      ),
      KPIData(
        title: 'Satisfacción',
        value: '94.5%',
        change: 5.2,
        icon: Icons.sentiment_satisfied,
        color: AppColors.warning,
        previousValue: '89.8%',
      ),
      KPIData(
        title: 'SLA Cumplido',
        value: '87.3%',
        change: -2.1,
        icon: Icons.check_circle,
        color: AppColors.info,
        previousValue: '89.2%',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        return KPIComparisonCard(
          data: kpis[index],
          isComparing: _isComparingPeriods,
        ).animate(delay: (100 * index).ms).fadeIn().scale();
      },
    );
  }

  Widget _buildAreaChart(AnalyticsData data, bool isDark) {
    return Container(
      height: 350,
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
            'Evolución de Reclamos',
            style: AppTextStyles.titleLarge(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat.MMMd(),
                majorGridLines: MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.compact(),
              ),
              tooltipBehavior: _tooltipBehavior,
              zoomPanBehavior: _zoomPanBehavior,
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<ChartSampleData, DateTime>(
                  dataSource: _generateSampleData(),
                  xValueMapper: (ChartSampleData data, _) => data.x,
                  yValueMapper: (ChartSampleData data, _) => data.y,
                  name: 'Nuevos',
                  color: AppColors.primary.withOpacity(0.3),
                  borderColor: AppColors.primary,
                  borderWidth: 2,
                  animationDuration: 1500,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.6),
                      AppColors.primary.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                if (_isComparingPeriods)
                  SplineAreaSeries<ChartSampleData, DateTime>(
                    dataSource: _generateComparisonData(),
                    xValueMapper: (ChartSampleData data, _) => data.x,
                    yValueMapper: (ChartSampleData data, _) => data.y,
                    name: 'Período Anterior',
                    color: AppColors.secondary.withOpacity(0.3),
                    borderColor: AppColors.secondary,
                    borderWidth: 2,
                    dashArray: <double>[5, 5],
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildPieChart(AnalyticsData data, bool isDark) {
    return Container(
      height: 350,
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
            'Distribución por Categoría',
            style: AppTextStyles.titleLarge(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.right,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              tooltipBehavior: _tooltipBehavior,
              series: <CircularSeries>[
                DoughnutSeries<PieChartData, String>(
                  dataSource: [
                    PieChartData('Internet', 45, AppColors.primary),
                    PieChartData('Telefonía', 30, AppColors.secondary),
                    PieChartData('Cable', 15, AppColors.warning),
                    PieChartData('Otros', 10, AppColors.info),
                  ],
                  xValueMapper: (PieChartData data, _) => data.category,
                  yValueMapper: (PieChartData data, _) => data.value,
                  pointColorMapper: (PieChartData data, _) => data.color,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontSize: 12,
                    ),
                  ),
                  innerRadius: '60%',
                  explode: true,
                  explodeIndex: 0,
                  animationDuration: 1500,
                  enableTooltip: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildBarChart(AnalyticsData data, bool isDark) {
    return Container(
      height: 350,
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
            'Rendimiento por Técnico',
            style: AppTextStyles.titleLarge(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.compact(),
              ),
              tooltipBehavior: _tooltipBehavior,
              series: <CartesianSeries>[
                ColumnSeries<BarChartData, String>(
                  dataSource: [
                    BarChartData('Juan P.', 95, AppColors.success),
                    BarChartData('María G.', 87, AppColors.primary),
                    BarChartData('Carlos R.', 82, AppColors.warning),
                    BarChartData('Ana L.', 78, AppColors.info),
                    BarChartData('Luis M.', 73, AppColors.secondary),
                  ],
                  xValueMapper: (BarChartData data, _) => data.technician,
                  yValueMapper: (BarChartData data, _) => data.score,
                  pointColorMapper: (BarChartData data, _) => data.color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusSm),
                    topRight: Radius.circular(AppSpacing.radiusSm),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  animationDuration: 1500,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.top,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildRadarChart(AnalyticsData data, bool isDark) {
    return Container(
      height: 350,
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
            'Análisis Multidimensional',
            style: AppTextStyles.titleLarge(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
                interval: 20,
              ),
              series: <CartesianSeries>[
                RadarSeries<RadarChartData, String>(
                  dataSource: [
                    RadarChartData('Velocidad', 85),
                    RadarChartData('Calidad', 92),
                    RadarChartData('Satisfacción', 78),
                    RadarChartData('Eficiencia', 88),
                    RadarChartData('Disponibilidad', 95),
                    RadarChartData('Costo', 70),
                  ],
                  xValueMapper: (RadarChartData data, _) => data.category,
                  yValueMapper: (RadarChartData data, _) => data.value,
                  color: AppColors.primary.withOpacity(0.3),
                  borderColor: AppColors.primary,
                  borderWidth: 2,
                  animationDuration: 1500,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
                if (_isComparingPeriods)
                  RadarSeries<RadarChartData, String>(
                    dataSource: [
                      RadarChartData('Velocidad', 75),
                      RadarChartData('Calidad', 85),
                      RadarChartData('Satisfacción', 82),
                      RadarChartData('Eficiencia', 78),
                      RadarChartData('Disponibilidad', 88),
                      RadarChartData('Costo', 65),
                    ],
                    xValueMapper: (RadarChartData data, _) => data.category,
                    yValueMapper: (RadarChartData data, _) => data.value,
                    color: AppColors.secondary.withOpacity(0.3),
                    borderColor: AppColors.secondary,
                    borderWidth: 2,
                    dashArray: <double>[5, 5],
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildHeatmapSection(AnalyticsData data, bool isDark) {
    return Container(
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
            'Mapa de Calor - Actividad Mensual',
            style: AppTextStyles.titleLarge(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          HeatmapCalendar(
            data: _generateHeatmapData(),
            colorScheme: [
              AppColors.backgroundLight,
              AppColors.primary.withOpacity(0.2),
              AppColors.primary.withOpacity(0.4),
              AppColors.primary.withOpacity(0.6),
              AppColors.primary.withOpacity(0.8),
              AppColors.primary,
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildTopPerformersTable(AnalyticsData data, bool isDark) {
    return Container(
      height: 400,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Performers',
                style: AppTextStyles.titleLarge(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: Icon(Icons.download, size: AppSpacing.iconSm),
                label: Text('Exportar'),
                onPressed: () => _showExportDialog(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              columns: [
                DataColumn2(
                  label: Text('Técnico'),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('Reclamos'),
                  size: ColumnSize.S,
                  numeric: true,
                ),
                DataColumn2(
                  label: Text('Resueltos'),
                  size: ColumnSize.S,
                  numeric: true,
                ),
                DataColumn2(
                  label: Text('Tiempo Prom.'),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text('Satisfacción'),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text('Tendencia'),
                  size: ColumnSize.S,
                ),
              ],
              rows: _generateTableData().map((item) {
                return DataRow2(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              item['initials'],
                              style: AppTextStyles.caption(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(item['name']),
                        ],
                      ),
                    ),
                    DataCell(Text(item['total'].toString())),
                    DataCell(Text(item['resolved'].toString())),
                    DataCell(Text(item['avgTime'])),
                    DataCell(
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: AppSpacing.iconXs,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: 4),
                          Text(item['satisfaction']),
                        ],
                      ),
                    ),
                    DataCell(
                      Icon(
                        item['trend'] == 'up'
                            ? Icons.trending_up
                            : item['trend'] == 'down'
                                ? Icons.trending_down
                                : Icons.trending_flat,
                        color: item['trend'] == 'up'
                            ? AppColors.success
                            : item['trend'] == 'down'
                                ? AppColors.error
                                : AppColors.textSecondaryLight,
                        size: AppSpacing.iconSm,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildPerformanceTab(AnalyticsData data, bool isDark) {
    // Implementation for Performance Tab
    return Center(
      child: Text('Performance Analytics - Coming Soon'),
    );
  }

  Widget _buildTrendsTab(AnalyticsData data, bool isDark) {
    // Implementation for Trends Tab
    return Center(
      child: Text('Trends Analytics - Coming Soon'),
    );
  }

  Widget _buildComparisonTab(AnalyticsData data, bool isDark) {
    // Implementation for Comparison Tab
    return Center(
      child: Text('Comparison Analytics - Coming Soon'),
    );
  }

  Widget _buildPredictiveTab(AnalyticsData data, bool isDark) {
    // Implementation for Predictive Tab
    return Center(
      child: Text('Predictive Analytics - Coming Soon'),
    );
  }

  Widget _buildDetailedTab(AnalyticsData data, bool isDark) {
    // Implementation for Detailed Tab
    return Center(
      child: Text('Detailed Analytics - Coming Soon'),
    );
  }

  Widget _buildCompareToggle(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: _isComparingPeriods
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: _isComparingPeriods
              ? AppColors.primary
              : isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _isComparingPeriods = !_isComparingPeriods);
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.compare_arrows,
                size: AppSpacing.iconSm,
                color: _isComparingPeriods
                    ? AppColors.primary
                    : isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Comparar',
                style: AppTextStyles.bodyMedium(
                  color: _isComparingPeriods
                      ? AppColors.primary
                      : isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(bool isDark) {
    return IconButton(
      icon: Stack(
        children: [
          Icon(
            Icons.filter_alt_outlined,
            color: _filters.isNotEmpty
                ? AppColors.primary
                : isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
          ),
          if (_filters.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
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
      onPressed: () {
        HapticFeedback.lightImpact();
        _showFilterPanel();
      },
    );
  }

  Widget _buildExportFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _showExportDialog();
      },
      backgroundColor: AppColors.primary,
      icon: Icon(Icons.download, color: Colors.white),
      label: Text(
        'Exportar',
        style: AppTextStyles.bodyMedium(color: Colors.white),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).shimmer(
      duration: 3.seconds,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Cargando analytics...',
            style: AppTextStyles.bodyMedium(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Error al cargar analytics',
            style: AppTextStyles.titleLarge(
              color: AppColors.textPrimaryDark,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            error,
            style: AppTextStyles.bodyMedium(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(analyticsProvider),
            icon: Icon(Icons.refresh),
            label: Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AnalyticsExportDialog(
        onExport: (format, options) {
          // Handle export
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exportando en formato $format...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnalyticsFilterPanel(
        currentFilters: _filters,
        onApplyFilters: (filters) {
          setState(() => _filters = filters);
          ref.read(analyticsProvider.notifier).applyFilters(filters);
        },
      ),
    );
  }

  // Helper methods for generating sample data
  List<ChartSampleData> _generateSampleData() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      return ChartSampleData(
        now.subtract(Duration(days: 30 - index)),
        (20 + (index * 2) + (index % 3 * 5)).toDouble(),
      );
    });
  }

  List<ChartSampleData> _generateComparisonData() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      return ChartSampleData(
        now.subtract(Duration(days: 30 - index)),
        (15 + (index * 1.5) + (index % 4 * 3)).toDouble(),
      );
    });
  }

  Map<DateTime, int> _generateHeatmapData() {
    final now = DateTime.now();
    final Map<DateTime, int> data = {};
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      data[date] = (i % 5) + 1;
    }
    return data;
  }

  List<Map<String, dynamic>> _generateTableData() {
    return [
      {
        'name': 'Juan Pérez',
        'initials': 'JP',
        'total': 156,
        'resolved': 142,
        'avgTime': '2.3h',
        'satisfaction': '4.8',
        'trend': 'up',
      },
      {
        'name': 'María García',
        'initials': 'MG',
        'total': 143,
        'resolved': 138,
        'avgTime': '2.1h',
        'satisfaction': '4.9',
        'trend': 'up',
      },
      {
        'name': 'Carlos Rodríguez',
        'initials': 'CR',
        'total': 128,
        'resolved': 115,
        'avgTime': '2.8h',
        'satisfaction': '4.5',
        'trend': 'flat',
      },
      {
        'name': 'Ana López',
        'initials': 'AL',
        'total': 134,
        'resolved': 125,
        'avgTime': '2.5h',
        'satisfaction': '4.6',
        'trend': 'down',
      },
      {
        'name': 'Luis Martínez',
        'initials': 'LM',
        'total': 119,
        'resolved': 108,
        'avgTime': '3.1h',
        'satisfaction': '4.3',
        'trend': 'down',
      },
    ];
  }
}

// Supporting Classes
class ChartSampleData {
  final DateTime x;
  final double y;

  ChartSampleData(this.x, this.y);
}

class PieChartData {
  final String category;
  final double value;
  final Color color;

  PieChartData(this.category, this.value, this.color);
}

class BarChartData {
  final String technician;
  final double score;
  final Color color;

  BarChartData(this.technician, this.score, this.color);
}

class RadarChartData {
  final String category;
  final double value;

  RadarChartData(this.category, this.value);
}

class AnalyticsData {
  // Define your analytics data structure
  AnalyticsData();
}

class KPIData {
  final String title;
  final String value;
  final double change;
  final IconData icon;
  final Color color;
  final String previousValue;

  KPIData({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.previousValue,
  });
}