import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String title;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const SectionLabel({
    super.key,
    required this.title,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          if (onActionPressed != null && actionText != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(
                actionText!,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
