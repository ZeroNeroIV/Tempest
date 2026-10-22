import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import 'create_user_dialog.dart';
import 'user_avatar.dart';

/// Modal dialog allowing the user to view, switch, rename, and delete cubist profiles.
class ManageUsersDialog extends StatelessWidget {
  final UserController userController;
  final CornerStyle cornerStyle;

  const ManageUsersDialog({
    super.key,
    required this.userController,
    required this.cornerStyle,
  });

  static Future<void> show(
    BuildContext context,
    UserController controller,
    CornerStyle cornerStyle,
  ) {
    return showDialog(
      context: context,
      builder: (context) => ManageUsersDialog(
        userController: controller,
        cornerStyle: cornerStyle,
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, UserModel user) {
    final textController = TextEditingController(text: user.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename User', style: TextStyle(fontFamily: 'monospace')),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(fontFamily: 'monospace'),
          decoration: InputDecoration(
            labelText: 'New Name',
            filled: true,
            fillColor: isDark ? AppColors.darkNavyElevated : AppColors.lightElevated,
            border: OutlineInputBorder(borderRadius: cornerStyle.cardRadius),
          ),
          onSubmitted: (val) {
            userController.updateUserName(user.id, val);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'monospace')),
          ),
          AppButton(
            onPressed: () {
              userController.updateUserName(user.id, textController.text);
              Navigator.of(ctx).pop();
            },
            cornerStyle: cornerStyle,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final users = userController.users;
    final activeUser = userController.activeUser;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.manage_accounts_outlined, color: AppColors.pistachioBase, size: 24),
          const SizedBox(width: 10),
          const Text('Manage Users', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isSelected = activeUser?.id == user.id;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.pistachioBase.withAlpha(isDark ? 35 : 50)
                          : (isDark ? AppColors.darkNavyElevated : AppColors.lightElevated),
                      borderRadius: cornerStyle.chipRadius,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.pistachioBase
                            : (isDark ? AppColors.darkNavyBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        UserAvatar(
                          user: user,
                          isSelected: isSelected,
                          cornerStyle: cornerStyle,
                          size: 36,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => userController.selectUser(user),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                if (isSelected)
                                  const Text(
                                    'Active User',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: AppColors.pistachioBase,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Edit Name Button
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: 'Rename',
                          onPressed: () => _showEditNameDialog(context, user),
                        ),
                        // Delete User Button
                        if (users.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.penaltyRed),
                            tooltip: 'Delete User',
                            onPressed: () => userController.deleteUser(user.id),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Add User Button
            AppButton(
              onPressed: () => CreateUserDialog.show(context, userController, cornerStyle),
              cornerStyle: cornerStyle,
              icon: Icons.person_add_alt_1,
              child: const Text('Add New User'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done', style: TextStyle(fontFamily: 'monospace')),
        ),
      ],
    );
  }
}
