import 'package:flutter/material.dart';
import 'package:hornbill/src/helpers/constants.dart';

/// Internal visual style variant. Set via the named constructors below.
enum _HIconButtonVariant { filled, outlined, text, tonal }

/// A custom icon-only button with four style variants:
/// [HIconButton.filled], [HIconButton.outlined], [HIconButton.text],
/// [HIconButton.tonal].
///
/// Pressing the button scales it down slightly for tactile feedback,
/// without using Material's IconButton.
class HIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  final _HIconButtonVariant _variant;

  final Color? color;
  final Color? foregroundColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const HIconButton.filled({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.size = 44,
    this.iconSize = 20,
    this.tooltip,
  }) : _variant = _HIconButtonVariant.filled;

  const HIconButton.outlined({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.size = 44,
    this.iconSize = 20,
    this.tooltip,
  }) : _variant = _HIconButtonVariant.outlined;

  const HIconButton.text({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.size = 40,
    this.iconSize = 20,
    this.tooltip,
  }) : _variant = _HIconButtonVariant.text;

  const HIconButton.tonal({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.size = 44,
    this.iconSize = 20,
    this.tooltip,
  }) : _variant = _HIconButtonVariant.tonal;

  @override
  State<HIconButton> createState() => _HIconButtonState();
}

class _HIconButtonState extends State<HIconButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_enabled) return;
    setState(() => _pressed = value);
  }

  // ---- Style resolution per variant ----

  Color get _baseColor {
    final theme = Theme.of(context).colorScheme;
    return widget.color ?? theme.primary;
  }

  Color get _backgroundColor {
    if (!_enabled) {
      switch (widget._variant) {
        case _HIconButtonVariant.filled:
        case _HIconButtonVariant.tonal:
          return Colors.grey.shade300;
        case _HIconButtonVariant.outlined:
        case _HIconButtonVariant.text:
          return Colors.transparent;
      }
    }
    switch (widget._variant) {
      case _HIconButtonVariant.filled:
        return _baseColor;
      case _HIconButtonVariant.tonal:
        return _baseColor.withValues(alpha: 0.12);
      case _HIconButtonVariant.outlined:
      case _HIconButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color get _fgColor {
    if (widget.foregroundColor != null) return widget.foregroundColor!;
    if (!_enabled) return Colors.grey.shade500;
    switch (widget._variant) {
      case _HIconButtonVariant.filled:
        return Theme.of(context).colorScheme.onPrimary;
      case _HIconButtonVariant.tonal:
      case _HIconButtonVariant.outlined:
      case _HIconButtonVariant.text:
        return _baseColor;
    }
  }

  Border? get _border {
    if (widget._variant != _HIconButtonVariant.outlined) return null;
    return Border.all(
      color: _enabled ? _baseColor : Colors.grey.shade400,
      width: 1.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(kBorderRadiusRounded),
            border: _border,
          ),
          child: Center(
            child: Icon(widget.icon, size: widget.iconSize, color: _fgColor),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

/// --- Example usage ---
///
/// Row(
///   children: [
///     HIconButton.filled(
///       icon: Icons.add,
///       onPressed: () {},
///     ),
///     const SizedBox(width: 12),
///     HIconButton.outlined(
///       icon: Icons.edit,
///       onPressed: () {},
///     ),
///     const SizedBox(width: 12),
///     HIconButton.tonal(
///       icon: Icons.favorite,
///       onPressed: () {},
///     ),
///     const SizedBox(width: 12),
///     HIconButton.text(
///       icon: Icons.close,
///       tooltip: 'Close',
///       onPressed: () {},
///     ),
///   ],
/// )
