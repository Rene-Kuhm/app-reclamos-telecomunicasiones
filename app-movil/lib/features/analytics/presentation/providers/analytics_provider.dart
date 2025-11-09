import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../screens/analytics_screen.dart';

part 'analytics_provider.g.dart';

@riverpod
class Analytics extends _$Analytics {
  @override
  Future<AnalyticsData> build() async {
    return await _loadAnalytics('month');
  }

  Future<AnalyticsData> _loadAnalytics(String period) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return AnalyticsData();
  }

  Future<void> loadAnalytics(String period) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadAnalytics(period));
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    state = const AsyncValue.loading();
    // Apply filters and reload data
    state = await AsyncValue.guard(() => _loadAnalytics('month'));
  }
}
