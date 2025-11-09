# Sistema de Diseño Enterprise - Reclamos Telco

Este documento describe el sistema de diseño moderno y de nivel enterprise implementado para la aplicación de gestión de reclamos de telecomunicaciones.

## 📋 Tabla de Contenidos

- [Arquitectura de Diseño](#arquitectura-de-diseño)
- [Sistema de Colores](#sistema-de-colores)
- [Tipografía](#tipografía)
- [Componentes UI](#componentes-ui)
- [Efectos Visuales](#efectos-visuales)
- [Animaciones](#animaciones)
- [Responsive Design](#responsive-design)
- [Guía de Uso](#guía-de-uso)

---

## 🎨 Arquitectura de Diseño

### Principios Fundamentales

1. **Material Design 3 (M3)** - Última versión con componentes modernos
2. **Glassmorphism** - Efectos de cristal esmerilado para elementos destacados
3. **Gradientes Suaves** - Transiciones de color profesionales
4. **Microinteracciones** - Animaciones fluidas en cada interacción
5. **Dark Mode First** - Diseño optimizado para tema oscuro

### Estructura de Archivos

```
lib/
├── core/
│   └── design/
│       ├── app_colors.dart         # Sistema de colores completo
│       ├── app_text_styles.dart    # Tipografía con Google Fonts
│       ├── app_spacing.dart        # Sistema de espaciado 4px
│       ├── app_animations.dart     # Animaciones y transiciones
│       └── app_shadows.dart        # Sombras y elevaciones
│
└── shared/
    └── widgets/
        ├── modern_button.dart              # Botones avanzados
        ├── modern_card.dart                # Cards con glassmorphism
        ├── modern_text_field.dart          # Inputs modernos
        ├── modern_loading.dart             # Estados de carga
        ├── modern_empty_state.dart         # Estados vacíos
        ├── glassmorphic_container.dart     # Contenedores glass
        ├── gradient_container.dart         # Contenedores gradient
        ├── premium_stat_card.dart          # Tarjetas de estadísticas
        └── index.dart                      # Exportaciones centralizadas
```

---

## 🎨 Sistema de Colores

### Paleta Principal

#### Primary (Azul Moderno)
- **Primary**: `#2697FF` - Azul brillante profesional
- **Primary Light**: `#5FB3FF` - Azul claro
- **Primary Dark**: `#1565C0` - Azul oscuro

#### Secondary (Grises Oscuros)
- **Secondary**: `#2A2D3E` - Gris oscuro para cards/sidebar
- **Secondary Light**: `#3E4153` - Variante clara
- **Secondary Dark**: `#1F2128` - Variante oscura

#### Accent (Naranja Profesional)
- **Accent**: `#E65100` - Naranja energético
- **Accent Light**: `#FF8A50`
- **Accent Dark**: `#AC1900`

### Colores Semánticos

```dart
// Success (Verde)
success: #2E7D32
successLight: #4CAF50
successDark: #1B5E20

// Error (Rojo)
error: #C62828
errorLight: #EF5350
errorDark: #B71C1C

// Warning (Naranja)
warning: #F57C00
warningLight: #FF9800
warningDark: #E65100

// Info (Azul)
info: #1976D2
infoLight: #2196F3
infoDark: #0D47A1
```

### Colores de Estados (Reclamos)

```dart
estadoAbierto: #2196F3      // Azul
estadoAsignado: #FF9800     // Naranja
estadoEnCurso: #9C27B0      // Púrpura
estadoEnRevision: #FFEB3B   // Amarillo
estadoCerrado: #4CAF50      // Verde
estadoRechazado: #F44336    // Rojo
```

### Gradientes Predefinidos

```dart
// Primary Gradient
primaryGradient: [#2697FF → #1565C0]

// Success Gradient
successGradient: [#2E7D32 → #388E3C]

// Error Gradient
errorGradient: [#C62828 → #D32F2F]

// Accent Gradient
accentGradient: [#E65100 → #FF6F00]
```

---

## 📝 Tipografía

### Font Family

**Poppins** - Fuente moderna y profesional de Google Fonts

### Escala Tipográfica (Material Design 3)

#### Display (Extra Large)
```dart
displayLarge:   57px / Bold / -0.25 letter spacing
displayMedium:  45px / Bold / 0 letter spacing
displaySmall:   36px / Bold / 0 letter spacing
```

#### Headline (Large)
```dart
headlineLarge:  32px / SemiBold / 0 letter spacing
headlineMedium: 28px / SemiBold / 0 letter spacing
headlineSmall:  24px / SemiBold / 0 letter spacing
```

#### Title (Medium)
```dart
titleLarge:     22px / Medium / 0 letter spacing
titleMedium:    16px / Medium / 0.15 letter spacing
titleSmall:     14px / Medium / 0.1 letter spacing
```

#### Body (Regular)
```dart
bodyLarge:      16px / Regular / 0.5 letter spacing
bodyMedium:     14px / Regular / 0.25 letter spacing
bodySmall:      12px / Regular / 0.4 letter spacing
```

#### Label (Buttons)
```dart
labelLarge:     14px / Medium / 0.1 letter spacing
labelMedium:    12px / Medium / 0.5 letter spacing
labelSmall:     11px / Medium / 0.5 letter spacing
```

### Uso Recomendado

```dart
// Títulos principales de pantalla
Text('Dashboard', style: AppTextStyles.headlineLarge())

// Subtítulos de secciones
Text('Estadísticas', style: AppTextStyles.titleLarge())

// Contenido general
Text('Descripción...', style: AppTextStyles.bodyMedium())

// Etiquetas y metadatos
Text('Hace 2 horas', style: AppTextStyles.bodySmall())

// Números grandes (estadísticas)
Text('142', style: AppTextStyles.numberLarge())
```

---

## 🧩 Componentes UI

### 1. ModernButton

Botón avanzado con múltiples variantes y animaciones.

**Variantes disponibles:**
- `filled` - Botón sólido (default)
- `outlined` - Botón con borde
- `text` - Botón minimalista
- `gradient` - Botón con gradiente
- `glassmorphism` - Botón con efecto glass

**Factory Constructors:**

```dart
// Primary filled button
ModernButton.primary(
  label: 'Crear Reclamo',
  onPressed: () {},
  icon: Icons.add,
  isLoading: false,
)

// Secondary outlined button
ModernButton.secondary(
  label: 'Cancelar',
  onPressed: () {},
)

// Gradient button
ModernButton.gradient(
  label: 'Guardar',
  gradient: LinearGradient(colors: AppColors.primaryGradient),
  onPressed: () {},
)

// Text button
ModernButton.text(
  label: 'Ver más',
  onPressed: () {},
)
```

**Tamaños:**
- `ModernButtonSize.small` - 40px altura
- `ModernButtonSize.medium` - 48px altura (default)
- `ModernButtonSize.large` - 56px altura

**Características:**
- ✅ Estados de carga automáticos
- ✅ Animaciones de escala al presionar
- ✅ Soporte para iconos (leading y trailing)
- ✅ Full width opcional
- ✅ Disabled states con opacidad automática

---

### 2. ModernCard

Card versátil con efectos avanzados.

**Factory Constructors:**

```dart
// Glass card (glassmorphism)
ModernCard.glass(
  child: Text('Contenido'),
  padding: EdgeInsets.all(16),
)

// Gradient card
ModernCard.gradient(
  gradient: LinearGradient(colors: AppColors.primaryGradient),
  child: Text('Contenido'),
)

// Elevated card con sombra
ModernCard.elevated(
  child: Text('Contenido'),
  color: Colors.white,
)

// Outlined card
ModernCard.outlined(
  child: Text('Contenido'),
)
```

**Características:**
- ✅ Glassmorphism con blur automático
- ✅ Gradientes suaves
- ✅ Bordes personalizables
- ✅ Sombras elevation-based
- ✅ onTap y onLongPress integrados

---

### 3. ModernTextField

Input field moderno con animaciones.

**Uso básico:**

```dart
ModernTextField(
  controller: _controller,
  label: 'Email',
  hint: 'tucorreo@ejemplo.com',
  prefixIcon: Icons.email_outlined,
  validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
  onChanged: (value) => print(value),
)
```

**Widgets especializados:**

```dart
// Search field con botón clear
ModernSearchField(
  hint: 'Buscar reclamos...',
  onChanged: (query) => _search(query),
  onClear: () => _clearSearch(),
)

// Password field con toggle show/hide
ModernPasswordField(
  label: 'Contraseña',
  hint: 'Ingresa tu contraseña',
  validator: Validators.validatePassword,
)
```

**Características:**
- ✅ Animación de borde al enfocar
- ✅ Floating label automático
- ✅ Validación integrada
- ✅ Iconos prefix/suffix
- ✅ Estados disabled/readonly
- ✅ Max length con contador

---

### 4. ModernLoading

Indicadores de carga profesionales.

```dart
// Full screen loading
ModernLoading.fullscreen(
  message: 'Cargando datos...',
)

// Inline loading
ModernLoading.inline(size: 24)

// Shimmer loading para cards
ShimmerLoading.card(height: 120)

// Shimmer para list tiles
ShimmerLoading.listTile()

// Shimmer para avatars
ShimmerLoading.circle(size: 48)

// Loading con retry
LoadingState(
  title: 'Cargando',
  message: 'Obteniendo reclamos...',
  icon: Icons.cloud_download,
  onRetry: () => _retry(),
)
```

**Características:**
- ✅ Animaciones pulsantes
- ✅ Shimmer effect para skeletons
- ✅ Mensajes personalizables
- ✅ Botón retry integrado

---

### 5. ModernEmptyState

Estados vacíos atractivos y accionables.

**Factory Constructors:**

```dart
// Sin datos genérico
ModernEmptyState.noData(
  title: 'No hay reclamos',
  description: 'Aún no has creado ningún reclamo',
  actionLabel: 'Crear Reclamo',
  onAction: () => _createClaim(),
)

// Sin resultados de búsqueda
ModernEmptyState.noResults(
  title: 'Sin resultados',
  actionLabel: 'Limpiar filtros',
  onAction: () => _clearFilters(),
)

// Sin notificaciones
ModernEmptyState.noNotifications()

// Error genérico
ModernEmptyState.error(
  title: 'Error al cargar',
  description: 'Ocurrió un problema',
  actionLabel: 'Reintentar',
  onAction: () => _retry(),
)

// Error de red
ModernEmptyState.networkError(
  onAction: () => _retry(),
)
```

**Características:**
- ✅ Iconos animados
- ✅ Botones de acción integrados
- ✅ Animaciones de entrada
- ✅ Badges personalizables

---

### 6. GlassmorphicContainer

Contenedor con efecto glass (frosted glass).

```dart
GlassmorphicContainer(
  padding: EdgeInsets.all(20),
  borderRadius: 16,
  blur: 10,
  opacity: 0.15,
  child: Text('Contenido con efecto glass'),
)
```

**Widgets especializados:**

```dart
// AppBar glassmórfico
GlassmorphicAppBar(
  title: Text('Título'),
  actions: [...],
)

// Bottom nav glassmórfico
GlassmorphicBottomNav(
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
  items: [
    GlassmorphicNavItem(
      icon: Icons.home,
      label: 'Inicio',
    ),
  ],
)
```

---

### 7. GradientContainer

Contenedor con gradientes predefinidos.

**Factory Constructors:**

```dart
// Primary gradient (azul)
GradientContainer.primary(
  child: Text('Contenido'),
  padding: EdgeInsets.all(20),
)

// Success gradient (verde)
GradientContainer.success(...)

// Error gradient (rojo)
GradientContainer.error(...)

// Accent gradient (naranja)
GradientContainer.accent(...)

// Dark gradient
GradientContainer.dark(...)

// Gradientes decorativos
GradientContainer.sunset(...)
GradientContainer.ocean(...)
GradientContainer.aurora(...)
```

**Animated Gradient:**

```dart
AnimatedGradientBackground(
  colors: [Colors.blue, Colors.purple],
  duration: Duration(seconds: 3),
  child: YourContent(),
)
```

---

### 8. PremiumStatCard

Tarjetas de estadísticas avanzadas.

```dart
PremiumStatCard(
  title: 'Total Reclamos',
  value: '142',
  subtitle: 'Último mes',
  icon: Icons.analytics,
  color: AppColors.primary,
  percentChange: 12.5,
  isPositiveTrend: true,
  progress: 0.85,
  badge: 'HOT',
  showSparkline: true,
  sparklineData: [12, 18, 15, 25, 22, 30, 28],
  onTap: () => _viewDetails(),
)
```

**Linear Stat Card:**

```dart
LinearStatCard(
  title: 'Progreso',
  value: '75%',
  label: 'Meta: 100 reclamos',
  icon: Icons.trending_up,
  color: AppColors.success,
  progress: 0.75,
)
```

---

## ✨ Efectos Visuales

### Glassmorphism

Efecto de cristal esmerilado para elementos destacados.

**Características:**
- Blur backdrop (sigma 10-15)
- Opacidad baja (0.05-0.2)
- Borde semi-transparente blanco
- Gradiente sutil interno

**Cuándo usar:**
- Navigation bars
- Floating panels
- Overlays
- Cards destacados

### Gradientes

Transiciones de color suaves para jerarquía visual.

**Tipos disponibles:**
1. **Linear** - Transición directa entre colores
2. **Radial** - Transición circular (no implementado aún)
3. **Sweep** - Transición angular (no implementado aún)

**Best Practices:**
- Máximo 3 colores por gradiente
- Usar colores de la misma familia cromática
- Evitar gradientes muy contrastantes
- Preferir ángulos diagonales (topLeft → bottomRight)

### Shadows

Sistema de sombras basado en elevación.

```dart
// Elevación Material Design
AppShadows.elevation1  // 2px blur
AppShadows.elevation2  // 4px blur
AppShadows.elevation4  // 8px blur
AppShadows.elevation8  // 16px blur
AppShadows.elevation16 // 24px blur

// Sombras especializadas
AppShadows.soft    // Elementos flotantes
AppShadows.medium  // Modales, bottom sheets
AppShadows.strong  // Elementos importantes
AppShadows.card    // Cards sutiles
AppShadows.button  // Botones elevados
AppShadows.fab     // FAB

// Glow effect
AppShadows.glow(AppColors.primary, blur: 12)
```

---

## 🎬 Animaciones

### Durations

```dart
AppAnimations.instant  // 0ms
AppAnimations.fastest  // 100ms - Microinteracciones
AppAnimations.fast     // 200ms - Hover effects
AppAnimations.normal   // 300ms - Transiciones standard (default)
AppAnimations.slow     // 400ms - Animaciones complejas
AppAnimations.slower   // 500ms - Animaciones dramáticas
AppAnimations.slowest  // 700ms - Hero animations
```

### Curves (Easing)

```dart
AppAnimations.emphasized           // easeInOutCubicEmphasized
AppAnimations.emphasizedDecelerate // easeOutCubic
AppAnimations.emphasizedAccelerate // easeInCubic
AppAnimations.standard             // easeInOut (default)
AppAnimations.standardDecelerate   // easeOut
AppAnimations.standardAccelerate   // easeIn
AppAnimations.bounce               // elasticOut
AppAnimations.spring               // easeOutBack
```

### Page Transitions

```dart
// Fade transition
AppAnimations.fadeTransition(
  page: DetailsScreen(),
  duration: AppAnimations.normal,
)

// Slide transition
AppAnimations.slideTransition(
  page: DetailsScreen(),
  begin: Offset(1.0, 0.0), // Desde derecha
)

// Scale transition
AppAnimations.scaleTransition(
  page: DetailsScreen(),
)
```

### Widget Extensions

```dart
// Fade in
widget.fadeIn(duration: AppAnimations.normal)

// Slide in
widget.slideIn(begin: Offset(0, 0.3))

// Scale in
widget.scaleIn(begin: 0.8)
```

### Custom Animations

```dart
// Shake (errores)
AppAnimations.createShakeAnimation(controller)

// Success pulse
AppAnimations.createSuccessPulseAnimation(controller)
```

### flutter_animate

Animaciones declarativas modernas:

```dart
Text('Hello')
  .animate()
  .fadeIn(duration: 300.ms)
  .scale(begin: Offset(0.8, 0.8))
  .then(delay: 200.ms)
  .shake(hz: 2)
```

---

## 📱 Responsive Design

### Breakpoints

```dart
Responsive.mobile     // < 850px
Responsive.tablet     // 850px - 1100px
Responsive.desktop    // >= 1100px
Responsive.ultrawide  // >= 1920px
```

### Helpers

```dart
// Check device type
if (Responsive.isMobile(context)) { ... }
if (Responsive.isTablet(context)) { ... }
if (Responsive.isDesktop(context)) { ... }

// Get responsive value
final padding = Responsive.value<double>(
  context,
  mobile: 16,
  tablet: 24,
  desktop: 32,
);

// Build responsive widgets
Responsive.builder(
  context: context,
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

### Layout Strategies

#### 1. LayoutBuilder (Recomendado)

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else if (constraints.maxWidth < 1100) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  },
)
```

#### 2. MediaQuery.sizeOf

```dart
final size = MediaQuery.sizeOf(context);
final isCompact = size.width < 600;
```

#### 3. Evitar

```dart
// ❌ NO usar
MediaQuery.of(context).orientation
Platform.isPhone
```

---

## 📖 Guía de Uso

### Importaciones

```dart
// Importar sistema de diseño
import 'package:app_movil/core/design/app_colors.dart';
import 'package:app_movil/core/design/app_text_styles.dart';
import 'package:app_movil/core/design/app_spacing.dart';
import 'package:app_movil/core/design/app_animations.dart';
import 'package:app_movil/core/design/app_shadows.dart';

// Importar widgets (opción 1: todos)
import 'package:app_movil/shared/widgets/index.dart';

// Importar widgets (opción 2: selectivos)
import 'package:app_movil/shared/widgets/modern_button.dart';
import 'package:app_movil/shared/widgets/modern_card.dart';
```

### Best Practices

#### 1. Spacing Consistente

```dart
// ✅ BIEN - Usar AppSpacing
padding: EdgeInsets.all(AppSpacing.md)
SizedBox(height: AppSpacing.lg)

// ❌ MAL - Hardcoded values
padding: EdgeInsets.all(20)
SizedBox(height: 24)
```

#### 2. Colores Semánticos

```dart
// ✅ BIEN - Usar colores semánticos
color: AppColors.success
color: AppColors.error

// ❌ MAL - Hardcoded colors
color: Colors.green
color: Color(0xFF00FF00)
```

#### 3. Tipografía Consistente

```dart
// ✅ BIEN - Usar AppTextStyles
Text('Título', style: AppTextStyles.headlineLarge())

// ❌ MAL - Hardcoded text styles
Text('Título', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
```

#### 4. Animaciones Suaves

```dart
// ✅ BIEN - Usar durations y curves predefinidos
AnimatedContainer(
  duration: AppAnimations.normal,
  curve: AppAnimations.emphasized,
)

// ❌ MAL - Hardcoded durations
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
)
```

#### 5. Responsive Consciente

```dart
// ✅ BIEN - Usar LayoutBuilder o Responsive helper
LayoutBuilder(
  builder: (context, constraints) {
    final isCompact = constraints.maxWidth < 600;
    return isCompact ? MobileView() : DesktopView();
  },
)

// ❌ MAL - Ignorar responsive
Container(width: 800) // Se sale en móvil
```

---

## 🎯 Checklist de Implementación

Al crear una nueva screen:

- [ ] Usar `AppColors` para todos los colores
- [ ] Usar `AppTextStyles` para toda la tipografía
- [ ] Usar `AppSpacing` para padding/margin/sizes
- [ ] Implementar dark mode support
- [ ] Añadir animaciones con `flutter_animate` o `AppAnimations`
- [ ] Hacer responsive con `LayoutBuilder` o `Responsive`
- [ ] Usar componentes de `shared/widgets` donde sea posible
- [ ] Implementar loading states con `ModernLoading`
- [ ] Implementar empty states con `ModernEmptyState`
- [ ] Añadir microinteracciones en botones y cards
- [ ] Test en múltiples tamaños de pantalla
- [ ] Verificar contraste de colores (WCAG AA)

---

## 🚀 Próximas Mejoras

- [ ] Sistema de theming dinámico
- [ ] Generador de color schemes automático
- [ ] Más variantes de botones (icon-only, split, etc)
- [ ] Data tables modernos
- [ ] Calendar/Date pickers premium
- [ ] Charts avanzados (área, scatter, heat map)
- [ ] Onboarding screens
- [ ] Splash screens animados
- [ ] Pull to refresh customizado
- [ ] Infinite scroll con shimmer
- [ ] Image gallery con zoom
- [ ] Video player integrado
- [ ] Audio player UI
- [ ] QR Scanner UI
- [ ] Biometric auth UI
- [ ] Multi-step forms
- [ ] Wizard flows
- [ ] Confetti animations
- [ ] Lottie animations integration

---

**Última actualización:** 2025-01-09
**Versión:** 1.0.0
**Autor:** Sistema de Diseño Enterprise
