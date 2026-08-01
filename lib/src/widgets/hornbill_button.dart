import 'package:flutter/material.dart';

enum HornbillButtonVariant { primary, secondary, text }

class HornbillButton extends StatelessWidget {
  const HornbillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = HornbillButtonVariant.primary,
    this.leading,
    this.trailing,
  });

  final String label;
  final VoidCallback? onPressed;
  final HornbillButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Text(label),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );

    switch (variant) {
      case HornbillButtonVariant.primary:
        return ElevatedButton(onPressed: onPressed, child: content);
      case HornbillButtonVariant.secondary:
        return OutlinedButton(onPressed: onPressed, child: content);
      case HornbillButtonVariant.text:
        return TextButton(onPressed: onPressed, child: content);
    }
  }
}
