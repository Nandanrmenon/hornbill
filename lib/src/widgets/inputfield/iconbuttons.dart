import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_ui/material_ui.dart';

/// Internal visual style variant. Set via the named constructors below.
enum _HIconButtonVariant { filled, outlined, plain, tonal }

/// A custom icon-only button widget with four style variants:
/// [HIconButton.filled], [HIconButton.outlined], [HIconButton.plain], [HIconButton.tonal].
///
/// Pressing the button scales it down slightly for tactile feedback,
/// without using Material's IconButton.
class HIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  final _HIconButtonVariant _variant;

  final Color? color;
  final Color? foregroundColor;
  final double? size;
  final double iconSize;
  final double borderRadius;
  final String? tooltip;

  const HIconButton.filled({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.size,
    this.iconSize = 18,
    this.borderRadius = kBorderRadiusRounded,
    this.tooltip,
  }) : _variant = _HIconButtonVariant.filled;

  const HIconButton.outlined({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.size,
    this.iconSize = 18,
    this.borderRadius = kBorderRadiusRounded,
    this.tooltip,
  }) : _variant = _HIconButtonVariant.outlined;

  const HIconButton.plain({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.size,
    this.iconSize = 18,
    this.borderRadius = kBorderRadiusRounded,
    this.tooltip,
  }) : _variant = _HIconButtonVariant.plain;

  const HIconButton.tonal({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.size,
    this.iconSize = 18,
    this.borderRadius = kBorderRadiusRounded,
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

  // ---- Adaptive size calculation ----
  // Native desktop -> 32. Native mobile -> 44.
  // Web is ambiguous (could be a desktop browser or a mobile browser), so
  // fall back to the viewport width to decide which one it behaves like.
  static const double _webDesktopBreakpoint = 600.0;

  double get _resolvedSize {
    if (widget.size != null) return widget.size!;

    final bool isNativeDesktop =
        !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    final bool isWideWeb =
        kIsWeb && MediaQuery.sizeOf(context).width >= _webDesktopBreakpoint;

    return (isNativeDesktop || isWideWeb) ? 32.0 : 44.0;
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
        case _HIconButtonVariant.plain:
          return Colors.transparent;
      }
    }

    final theme = Theme.of(context).colorScheme;

    final Color resting;
    switch (widget._variant) {
      case _HIconButtonVariant.filled:
        resting = _baseColor;
      case _HIconButtonVariant.tonal:
        resting = theme.primaryContainer;
      case _HIconButtonVariant.outlined:
      case _HIconButtonVariant.plain:
        resting = Colors.transparent;
    }

    if (!_hovered) return resting;

    final overlay = _fgColor.withValues(alpha: 0.08);
    return resting == Colors.transparent
        ? overlay
        : Color.alphaBlend(overlay, resting);
  }

  Color get _fgColor {
    if (widget.foregroundColor != null) return widget.foregroundColor!;
    if (!_enabled) return Colors.grey.shade500;

    final theme = Theme.of(context).colorScheme;

    switch (widget._variant) {
      case _HIconButtonVariant.filled:
        return theme.onPrimary;
      case _HIconButtonVariant.tonal:
        return theme.onPrimaryContainer;
      case _HIconButtonVariant.outlined:
      case _HIconButtonVariant.plain:
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
    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: _border,
      ),
      alignment: Alignment.center,
      child: Icon(widget.icon, size: widget.iconSize, color: _fgColor),
    );

    Widget button = MouseRegion(
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
          scale: _pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: SizedBox(
            width: _resolvedSize,
            height: _resolvedSize,
            child: content,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
