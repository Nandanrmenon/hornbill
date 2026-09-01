import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_ui/material_ui.dart';

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
    this.size = 44,
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
  bool _hovered = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_enabled) return;
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (!_enabled) return;
    setState(() => _hovered = value);
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

    final Color resting;
    switch (widget._variant) {
      case _HIconButtonVariant.filled:
        resting = _baseColor;
      case _HIconButtonVariant.tonal:
        resting = _baseColor.withValues(alpha: 0.12);
      case _HIconButtonVariant.outlined:
      case _HIconButtonVariant.text:
        resting = Colors.transparent;
    }

    if (!_hovered) return resting;

    // Hover state layer, same approach as HButton: blend a low-alpha
    // wash of the foreground color over the resting background so
    // filled/tonal darken slightly and outlined/text (which rest fully
    // transparent) pick up a faint tint instead of no feedback at all.
    final overlay = _fgColor.withValues(alpha: 0.08);
    return resting == Colors.transparent
        ? overlay
        : Color.alphaBlend(overlay, resting);
  }

  Color get _fgColor {
    if (widget.foregroundColor != null) return widget.foregroundColor!;
    if (!_enabled) return Colors.grey.shade500;
    switch (widget._variant) {
      case _HIconButtonVariant.filled:
        return Theme.of(context).colorScheme.onPrimary;
      case _HIconButtonVariant.tonal:
        return _baseColor;
      case _HIconButtonVariant.outlined:
        return _baseColor;
      case _HIconButtonVariant.text:
        return Theme.of(context).colorScheme.onSurface;
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
    final button = MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(kBorderRadiusRounded),
                border: _border,
              ),
              alignment: Alignment.center,
              child: Icon(widget.icon, size: widget.iconSize, color: _fgColor),
            ),
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
