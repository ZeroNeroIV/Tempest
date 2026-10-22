import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/corner_style.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/profile_controller.dart';

/// Modal dialog to create a new custom profile on the fly.
class CreateProfileDialog extends StatefulWidget {
  final ProfileController profileController;
  final CornerStyle cornerStyle;

  const CreateProfileDialog({
    super.key,
    required this.profileController,
    required this.cornerStyle,
  });

  static Future<void> show(
    BuildContext context,
    ProfileController controller,
    CornerStyle cornerStyle,
  ) {
    return showDialog(
      context: context,
      builder: (context) => CreateProfileDialog(
        profileController: controller,
        cornerStyle: cornerStyle,
      ),
    );
  }

  @override
  State<CreateProfileDialog> createState() => _CreateProfileDialogState();
}

class _CreateProfileDialogState extends State<CreateProfileDialog> {
  final _textController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _textController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a profile name');
      return;
    }

    widget.profileController.createCustomProfile(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.category_outlined, color: AppColors.pistachioBase, size: 22),
          const SizedBox(width: 8),
          const Text('New Profile', style: TextStyle(fontFamily: 'monospace')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _textController,
            autofocus: true,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: InputDecoration(
              labelText: 'Custom Profile Name',
              hintText: 'e.g. Megaminx, Skewb, OH 3x3',
              errorText: _error,
              filled: true,
              fillColor: isDark ? AppColors.darkNavyElevated : AppColors.lightElevated,
              border: OutlineInputBorder(
                borderRadius: widget.cornerStyle.cardRadius,
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkNavyBorder : AppColors.lightBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: widget.cornerStyle.cardRadius,
                borderSide: const BorderSide(color: AppColors.pistachioBase, width: 2),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        AppButton(
          onPressed: _submit,
          cornerStyle: widget.cornerStyle,
          child: const Text('Create Profile'),
        ),
      ],
    );
  }
}
