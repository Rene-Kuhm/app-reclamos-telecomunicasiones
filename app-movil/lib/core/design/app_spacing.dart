/// Sistema de espaciado consistente basado en escala de 4px
/// Inspirado en Material Design y Fluent Design System
class AppSpacing {
  AppSpacing._();

  // Base unit (4px)
  static const double _unit = 4.0;

  // Spacing scale
  static const double none = 0;
  static const double xxxs = _unit; // 4px
  static const double xxs = _unit * 2; // 8px
  static const double xs = _unit * 3; // 12px
  static const double sm = _unit * 4; // 16px
  static const double md = _unit * 5; // 20px
  static const double lg = _unit * 6; // 24px
  static const double xl = _unit * 8; // 32px
  static const double xxl = _unit * 10; // 40px
  static const double xxxl = _unit * 12; // 48px

  // Common paddings
  static const double cardPadding = sm; // 16px
  static const double screenPadding = sm; // 16px
  static const double sectionPadding = lg; // 24px
  static const double buttonPadding = sm; // 16px

  // Common margins
  static const double cardMargin = xxs; // 8px
  static const double sectionMargin = lg; // 24px

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;
  static const double avatarXxl = 120.0;

  // Border radius
  static const double radiusXs = _unit; // 4px
  static const double radiusSm = _unit * 2; // 8px
  static const double radiusMd = _unit * 3; // 12px
  static const double radiusLg = _unit * 4; // 16px
  static const double radiusXl = _unit * 5; // 20px
  static const double radiusXxl = _unit * 6; // 24px
  static const double radiusFull = 9999.0; // Circle

  // Elevation (visual depth)
  static const double elevationNone = 0;
  static const double elevationXs = 1;
  static const double elevationSm = 2;
  static const double elevationMd = 4;
  static const double elevationLg = 8;
  static const double elevationXl = 16;

  // Common heights
  static const double buttonHeight = 48.0;
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightLg = 56.0;
  static const double inputHeight = 48.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;
  static const double listTileHeight = 64.0;
  static const double cardMinHeight = 120.0;
}
