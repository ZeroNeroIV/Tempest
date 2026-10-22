import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../controllers/profile_controller.dart';
import 'create_profile_dialog.dart';

/// Horizontal selector bar for puzzle profiles (built-in & custom).
class ProfileBar extends StatelessWidget {
  final ProfileController profileController;
  final CornerStyle cornerStyle;

  const ProfileBar({
    super.key,
    required this.profileController,
    required this.cornerStyle,
  });

  IconData _iconForProfile(String iconKey) {
    switch (iconKey) {
      case '2x2':
        return Icons.grid_view_sharp;
      case '3x3':
        return Icons.view_in_ar;
      case '4x4':
        return Icons.apps;
      case '5x5':
        return Icons.grid_4x4;
      case 'pyraminx':
        return Icons.change_history;
      default:
        return Icons.extension_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = profileController.activeProfile;
    final profiles = profileController.profiles;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: profiles.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == profiles.length) {
            // "+ New Profile" chip
            return ActionChip(
              avatar: const Icon(Icons.add, size: 16, color: AppColors.pistachioBase),
              label: const Text('Custom', style: TextStyle(fontFamily: 'monospace')),
              shape: RoundedRectangleBorder(borderRadius: cornerStyle.chipRadius),
              backgroundColor: isDark ? AppColors.darkNavyElevated : AppColors.lightElevated,
              side: BorderSide(
                color: isDark ? AppColors.darkNavyBorder : AppColors.lightBorder,
              ),
              onPressed: () => CreateProfileDialog.show(context, profileController, cornerStyle),
            );
          }

          final profile = profiles[index];
          final isSelected = active?.id == profile.id;

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(
              _iconForProfile(profile.iconKey),
              size: 16,
              color: isSelected
                  ? AppColors.darkNavyBase
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            label: Text(
              profile.name,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.darkNavyBase
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
            backgroundColor: isDark ? AppColors.darkNavySurface : AppColors.lightSurface,
            selectedColor: AppColors.pistachioBase,
            shape: RoundedRectangleBorder(borderRadius: cornerStyle.chipRadius),
            side: BorderSide(
              color: isSelected
                  ? AppColors.pistachioBase
                  : (isDark ? AppColors.darkNavyBorder : AppColors.lightBorder),
            ),
            onSelected: (_) => profileController.selectProfile(profile),
          );
        },
      ),
    );
  }
}
