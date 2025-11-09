import 'package:flutter/material.dart';

/// Sistema de colores extendido para la aplicación
/// Basado en Material Design 3 y mejores prácticas enterprise
class AppColors {
  AppColors._();

  // Primary colors - Modern Admin Panel Style
  static const Color primary = Color(0xFF2697FF); // Bright Blue (from reference design)
  static const Color primaryLight = Color(0xFF5FB3FF);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary colors - Dark UI Elements
  static const Color secondary = Color(0xFF2A2D3E); // Dark slate (sidebar, cards)
  static const Color secondaryLight = Color(0xFF3E4153);
  static const Color secondaryDark = Color(0xFF1F2128);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Accent colors
  static const Color accent = Color(0xFFE65100); // Professional Orange
  static const Color accentLight = Color(0xFFFF8A50);
  static const Color accentDark = Color(0xFFAC1900);

  // Neutral colors (Light theme)
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);
  static const Color outlineLight = Color(0xFFE0E0E0);
  static const Color outlineVariantLight = Color(0xFFF5F5F5);

  // Neutral colors (Dark theme) - Admin Panel Dark Theme
  static const Color backgroundDark = Color(0xFF212332); // Very dark navy/charcoal (main bg)
  static const Color surfaceDark = Color(0xFF2A2D3E); // Dark slate (cards, sidebar)
  static const Color surfaceVariantDark = Color(0xFF1F2128); // Darker variant
  static const Color outlineDark = Color(0xFF3E4153); // Subtle borders
  static const Color outlineVariantDark = Color(0xFF2A2D3E);

  // Text colors (Light theme)
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textTertiaryLight = Color(0xFF9E9E9E);
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  // Text colors (Dark theme)
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF808080);
  static const Color textDisabledDark = Color(0xFF606060);

  // Semantic colors
  static const Color success = Color(0xFF2E7D32); // Green
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF1B5E20);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFC62828); // Red
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFB71C1C);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFF57C00); // Orange
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFE65100);
  static const Color onWarning = Color(0xFFFFFFFF);

  static const Color info = Color(0xFF1976D2); // Blue
  static const Color infoLight = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF0D47A1);
  static const Color onInfo = Color(0xFFFFFFFF);

  // Estado colors
  static const Color estadoAbierto = Color(0xFF2196F3); // Blue
  static const Color estadoAsignado = Color(0xFFFF9800); // Orange
  static const Color estadoEnCurso = Color(0xFF9C27B0); // Purple
  static const Color estadoEnRevision = Color(0xFFFFEB3B); // Yellow
  static const Color estadoCerrado = Color(0xFF4CAF50); // Green
  static const Color estadoRechazado = Color(0xFFF44336); // Red

  // Prioridad colors
  static const Color prioridadBaja = Color(0xFF4CAF50); // Green
  static const Color prioridadMedia = Color(0xFFFF9800); // Orange
  static const Color prioridadAlta = Color(0xFFFF5722); // Deep Orange
  static const Color prioridadUrgente = Color(0xFFF44336); // Red

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF2697FF),
    Color(0xFF1565C0),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF2A2D3E),
    Color(0xFF1F2128),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFE65100),
    Color(0xFFFF6F00),
  ];

  static const List<Color> successGradient = [
    Color(0xFF2E7D32),
    Color(0xFF388E3C),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFC62828),
    Color(0xFFD32F2F),
  ];

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000); // 10% opacity
  static const Color shadowMedium = Color(0x33000000); // 20% opacity
  static const Color shadowDark = Color(0x4D000000); // 30% opacity

  // Overlay colors
  static const Color overlayLight = Color(0x0A000000); // 4% opacity
  static const Color overlayMedium = Color(0x14000000); // 8% opacity
  static const Color overlayDark = Color(0x1F000000); // 12% opacity

  // Shimmer colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Divider colors
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // Border colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF3E3E3E);

  // Helper methods
  static Color getEstadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'ABIERTO':
        return estadoAbierto;
      case 'ASIGNADO':
        return estadoAsignado;
      case 'EN_CURSO':
        return estadoEnCurso;
      case 'EN_REVISION':
        return estadoEnRevision;
      case 'CERRADO':
        return estadoCerrado;
      case 'RECHAZADO':
        return estadoRechazado;
      default:
        return info;
    }
  }

  static Color getPrioridadColor(String prioridad) {
    switch (prioridad.toUpperCase()) {
      case 'BAJA':
        return prioridadBaja;
      case 'MEDIA':
        return prioridadMedia;
      case 'ALTA':
        return prioridadAlta;
      case 'URGENTE':
        return prioridadUrgente;
      default:
        return info;
    }
  }

  // Create LinearGradient helper
  static LinearGradient createGradient(
    List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }
}
