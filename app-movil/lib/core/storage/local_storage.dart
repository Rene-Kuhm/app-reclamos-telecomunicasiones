import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';

/// Local storage using Hive for caching data
class LocalStorage {
  static LocalStorage? _instance;
  bool _initialized = false;

  LocalStorage._();

  static LocalStorage get instance {
    _instance ??= LocalStorage._();
    return _instance!;
  }

  /// Initialize Hive
  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _initialized = true;
  }

  /// Open a box
  Future<Box<T>> openBox<T>(String boxName) async {
    if (!_initialized) {
      await init();
    }

    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }

    return await Hive.openBox<T>(boxName);
  }

  /// Close a box
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  /// Close all boxes
  Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  /// Delete a box
  Future<void> deleteBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).clear();
      await Hive.box(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName);
  }

  /// Clear all boxes
  Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }

  // Reclamos Cache
  Future<Box> get reclamosBox async {
    return await openBox(AppConfig.reclamosBoxName);
  }

  Future<void> cacheReclamo(String id, Map<String, dynamic> data) async {
    final box = await reclamosBox;
    await box.put(id, data);
  }

  Future<Map<String, dynamic>?> getCachedReclamo(String id) async {
    final box = await reclamosBox;
    final data = box.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> cacheReclamos(List<Map<String, dynamic>> reclamos) async {
    final box = await reclamosBox;
    await box.clear();
    for (final reclamo in reclamos) {
      await box.put(reclamo['id'], reclamo);
    }
  }

  Future<List<Map<String, dynamic>>> getCachedReclamos() async {
    final box = await reclamosBox;
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> deleteCachedReclamo(String id) async {
    final box = await reclamosBox;
    await box.delete(id);
  }

  Future<void> clearReclamosCache() async {
    final box = await reclamosBox;
    await box.clear();
  }

  // Notificaciones Cache
  Future<Box> get notificacionesBox async {
    return await openBox(AppConfig.notificacionesBoxName);
  }

  Future<void> cacheNotificacion(String id, Map<String, dynamic> data) async {
    final box = await notificacionesBox;
    await box.put(id, data);
  }

  Future<Map<String, dynamic>?> getCachedNotificacion(String id) async {
    final box = await notificacionesBox;
    final data = box.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> cacheNotificaciones(List<Map<String, dynamic>> notificaciones) async {
    final box = await notificacionesBox;
    await box.clear();
    for (final notificacion in notificaciones) {
      await box.put(notificacion['id'], notificacion);
    }
  }

  Future<List<Map<String, dynamic>>> getCachedNotificaciones() async {
    final box = await notificacionesBox;
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> deleteCachedNotificacion(String id) async {
    final box = await notificacionesBox;
    await box.delete(id);
  }

  Future<void> clearNotificacionesCache() async {
    final box = await notificacionesBox;
    await box.clear();
  }

  // Settings
  Future<Box> get settingsBox async {
    return await openBox(AppConfig.settingsBoxName);
  }

  Future<void> saveSetting(String key, dynamic value) async {
    final box = await settingsBox;
    await box.put(key, value);
  }

  Future<T?> getSetting<T>(String key) async {
    final box = await settingsBox;
    return box.get(key) as T?;
  }

  Future<void> deleteSetting(String key) async {
    final box = await settingsBox;
    await box.delete(key);
  }

  Future<void> clearSettings() async {
    final box = await settingsBox;
    await box.clear();
  }

  // Theme preference
  Future<void> saveThemeMode(String mode) async {
    await saveSetting('theme_mode', mode);
  }

  Future<String?> getThemeMode() async {
    return await getSetting<String>('theme_mode');
  }

  // Last sync timestamp
  Future<void> saveLastSync(String key, DateTime timestamp) async {
    await saveSetting('last_sync_$key', timestamp.toIso8601String());
  }

  Future<DateTime?> getLastSync(String key) async {
    final timestamp = await getSetting<String>('last_sync_$key');
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  // Check if cache is expired
  Future<bool> isCacheExpired(String key, Duration maxAge) async {
    final lastSync = await getLastSync(key);
    if (lastSync == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference > maxAge;
  }
}
