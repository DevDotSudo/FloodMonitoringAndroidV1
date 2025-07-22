import 'package:flood_monitoring_android/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class MessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;
  final Color? buttonColor;
  final IconData? icon;

  const MessageDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    required this.onPressed,
    this.buttonColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                color: theme.primaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    icon ?? Icons.check_circle_rounded,
                    size: 48,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: buttonText,
                    onPressed: () {
                      Navigator.pop(context);
                      onPressed();
                    },
                    color: buttonColor ?? theme.primaryColor,
                    width: 120,
                    borderRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    Color? buttonColor,
    IconData? icon,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => MessageDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        buttonColor: buttonColor,
        icon: icon,
        onPressed: onPressed ?? () {},
      ),
    );
  }
}
