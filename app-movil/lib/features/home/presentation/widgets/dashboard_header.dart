import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Professional dashboard header component
/// Based on reference admin panel design
class DashboardHeader extends ConsumerWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DashboardHeader({
    super.key,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Menu button for mobile
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey?.currentState?.openDrawer();
              },
            ),

          // Title - only show on tablet and desktop
          if (!Responsive.isMobile(context))
            Text(
              'Dashboard',
              style: AppTextStyles.titleLarge(),
            ),

          // Spacer
          if (!Responsive.isMobile(context)) SizedBox(width: AppSpacing.md),

          // Search Field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Buscar...',
                  hintStyle: AppTextStyles.bodyMedium(
                    color: AppColors.textSecondaryDark,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondaryDark,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                style: AppTextStyles.bodyMedium(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
          ),

          SizedBox(width: AppSpacing.md),

          // Profile Card
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // Profile Image
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      user?.nombre.substring(0, 1).toUpperCase() ?? 'U',
                      style: AppTextStyles.titleMedium(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Name - only show on desktop
                if (Responsive.isDesktop(context)) ...[
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    user?.nombre.split(' ')[0] ?? 'Usuario',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondaryDark,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
