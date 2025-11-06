import 'package:intl/intl.dart';

/// Date formatting utilities
class DateFormatter {
  /// Format date to readable string (e.g., "15 Ene 2024")
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es_ES').format(date);
  }

  /// Format date to readable string with time (e.g., "15 Ene 2024 10:30")
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy HH:mm', 'es_ES').format(date);
  }

  /// Format time only (e.g., "10:30")
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'es_ES').format(date);
  }

  /// Format date to ISO 8601 string
  static String formatISO(DateTime date) {
    return date.toIso8601String();
  }

  /// Parse ISO 8601 string to DateTime
  static DateTime? parseISO(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time (e.g., "hace 5 minutos", "hace 2 horas")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'hace ${difference.inSeconds} segundos';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} ${difference.inMinutes == 1 ? "minuto" : "minutos"}';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours} ${difference.inHours == 1 ? "hora" : "horas"}';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays} ${difference.inDays == 1 ? "día" : "días"}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'hace $weeks ${weeks == 1 ? "semana" : "semanas"}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'hace $months ${months == 1 ? "mes" : "meses"}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'hace $years ${years == 1 ? "año" : "años"}';
    }
  }

  /// Format date range
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return formatDate(start);
    } else if (start.year == end.year && start.month == end.month) {
      return '${start.day} - ${end.day} ${DateFormat('MMM yyyy', 'es_ES').format(end)}';
    } else if (start.year == end.year) {
      return '${DateFormat('dd MMM', 'es_ES').format(start)} - ${DateFormat('dd MMM yyyy', 'es_ES').format(end)}';
    } else {
      return '${formatDate(start)} - ${formatDate(end)}';
    }
  }

  /// Get month name
  static String getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  /// Get day name
  static String getDayName(DateTime date) {
    const days = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    return days[date.weekday - 1];
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Get smart date label (Today, Yesterday, or formatted date)
  static String getSmartDate(DateTime date) {
    if (isToday(date)) {
      return 'Hoy ${formatTime(date)}';
    } else if (isYesterday(date)) {
      return 'Ayer ${formatTime(date)}';
    } else if (isThisWeek(date)) {
      return '${getDayName(date)} ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  /// Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get time of day label
  static String getTimeOfDayLabel(DateTime date) {
    final hour = date.hour;

    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }
}
