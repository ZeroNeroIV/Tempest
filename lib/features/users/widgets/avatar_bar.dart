import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../controllers/user_controller.dart';
import 'create_user_dialog.dart';
import 'manage_users_dialog.dart';
import 'user_avatar.dart';

/// Top horizontal Avatar Bar enabling one-tap switching between cubists.
class AvatarBar extends StatelessWidget {
  final UserController userController;
  final CornerStyle cornerStyle;

  const AvatarBar({
    super.key,
    required this.userController,
    required this.cornerStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeUser = userController.activeUser;
    final users = userController.users;

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          // Clickable User icon to open Manage Users modal
          IconButton(
            tooltip: 'Manage Users',
            icon: Icon(
              Icons.people_alt_outlined,
              size: 20,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            onPressed: () => ManageUsersDialog.show(context, userController, cornerStyle),
          ),
          // Scrollable avatar list
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: users.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = activeUser?.id == user.id;

                return Center(
                  child: Tooltip(
                    message: user.name,
                    child: InkWell(
                      borderRadius: cornerStyle.isRounded
                          ? BorderRadius.circular(20)
                          : BorderRadius.zero,
                      onTap: () => userController.selectUser(user),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UserAvatar(
                              user: user,
                              isSelected: isSelected,
                              cornerStyle: cornerStyle,
                              size: 34,
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6),
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Add User Button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22),
            color: AppColors.pistachioBase,
            tooltip: 'Add New User',
            onPressed: () => CreateUserDialog.show(context, userController, cornerStyle),
          ),
        ],
      ),
    );
  }
}
