import 'package:material_ui/material_ui.dart';
import 'package:hornbill/src/helpers/constants.dart';

/// Position of the icon relative to the label.
enum HButtonIconPosition { left, right }

/// Internal visual style variant. Set via the named constructors below.
enum _HButtonVariant { filled, outlined, text, tonal }

/// A custom button widget with four style variants:
/// [HButton.filled], [HButton.outlined], [HButton.text], [HButton.tonal].
///
/// Pressing the button scales it down slightly for tactile feedback,
/// without using Material's ElevatedButton/OutlinedButton/TextButton.
class HButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  /// Whether to show the [icon]. If true, [icon] must be provided.
  final bool showIcon;
  final IconData? icon;
  final HButtonIconPosition iconPosition;

  final _HButtonVariant _variant;

  final Color? color;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double height;
  final double iconSize;
  final double gap;
  final TextStyle? textStyle;

  const HButton.filled({
    super.key,
    required this.label,
    required this.onPressed,
    this.showIcon = false,
    this.icon,
    this.iconPosition = HButtonIconPosition.left,
    this.color,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.width,
    this.height = 48,
    this.iconSize = 18,
    this.gap = 8,
    this.textStyle,
  }) : _variant = _HButtonVariant.filled;

  const HButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.showIcon = false,
    this.icon,
    this.iconPosition = HButtonIconPosition.left,
    this.color,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.width,
    this.height = 48,
    this.iconSize = 18,
    this.gap = 8,
    this.textStyle,
  }) : _variant = _HButtonVariant.outlined;

  const HButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.showIcon = false,
    this.icon,
    this.iconPosition = HButtonIconPosition.left,
    this.color,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.width,
    this.height = 44,
    this.iconSize = 18,
    this.gap = 8,
    this.textStyle,
  }) : _variant = _HButtonVariant.text;

  const HButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.showIcon = false,
    this.icon,
    this.iconPosition = HButtonIconPosition.left,
    this.color,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.width,
    this.height = 48,
    this.iconSize = 18,
    this.gap = 8,
    this.textStyle,
  }) : _variant = _HButtonVariant.tonal;

  @override
  State<HButton> createState() => _HButtonState();
}

class _HButtonState extends State<HButton> {
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
        case _HButtonVariant.filled:
        case _HButtonVariant.tonal:
          return Colors.grey.shade300;
        case _HButtonVariant.outlined:
        case _HButtonVariant.text:
          return Colors.transparent;
      }
    }
    switch (widget._variant) {
      case _HButtonVariant.filled:
        return _baseColor;
      case _HButtonVariant.tonal:
        return _baseColor.withValues(alpha: 0.12);
      case _HButtonVariant.outlined:
      case _HButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color get _fgColor {
    if (widget.foregroundColor != null) return widget.foregroundColor!;
    if (!_enabled) return Colors.grey.shade500;
    switch (widget._variant) {
      case _HButtonVariant.filled:
        return Theme.of(context).colorScheme.onPrimary;
      case _HButtonVariant.tonal:
      case _HButtonVariant.outlined:
      case _HButtonVariant.text:
        return _baseColor;
    }
  }

  Border? get _border {
    if (widget._variant != _HButtonVariant.outlined) return null;
    return Border.all(
      color: _enabled ? _baseColor : Colors.grey.shade400,
      width: 1.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (widget.showIcon &&
          widget.icon != null &&
          widget.iconPosition == HButtonIconPosition.left) ...[
        Icon(widget.icon, size: widget.iconSize, color: _fgColor),
        SizedBox(width: widget.gap),
      ],
      Flexible(
        child: Text(
          widget.label,
          overflow: TextOverflow.ellipsis,
          style:
              (widget.textStyle ?? const TextStyle(fontWeight: FontWeight.w600))
                  .copyWith(
                    color: _fgColor,
                    fontSize: widget.textStyle?.fontSize ?? 15,
                  ),
        ),
      ),
      if (widget.showIcon &&
          widget.icon != null &&
          widget.iconPosition == HButtonIconPosition.right) ...[
        SizedBox(width: widget.gap),
        Icon(widget.icon, size: widget.iconSize, color: _fgColor),
      ],
    ];

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
            border: _border,
          ),
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
      ),
    );
  }
}

/// --- Example usage ---
///
/// Column(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   children: [
///     HButton.filled(
///       label: 'Continue',
///       showIcon: true,
///       icon: Icons.arrow_forward,
///       iconPosition: HButtonIconPosition.right,
///       onPressed: () {},
///     ),
///     const SizedBox(height: 12),
///     HButton.outlined(
///       label: 'Cancel',
///       onPressed: () {},
///     ),
///     const SizedBox(height: 12),
///     HButton.tonal(
///       label: 'Save draft',
///       showIcon: true,
///       icon: Icons.save,
///       onPressed: () {},
///     ),
///     const SizedBox(height: 12),
///     HButton.text(
///       label: 'Skip',
///       onPressed: () {},
///     ),
///   ],
/// )
