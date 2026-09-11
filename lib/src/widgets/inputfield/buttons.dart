import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_ui/material_ui.dart';

/// Position of the icon relative to the label.
enum HButtonIconPosition { left, right }

/// Internal visual style variant. Set via the named constructors below.
enum _HButtonVariant { filled, outlined, plain, tonal }

/// A custom button widget with four style variants:
/// [HButton.filled], [HButton.outlined], [HButton.plain], [HButton.tonal].
///
/// Pressing the button scales it down slightly for tactile feedback,
/// without using Material's ElevatedButton/OutlinedButton/TextButton.
class HButton extends StatefulWidget {
  final Widget label;
  final VoidCallback? onPressed;

  /// Whether to show the [icon]. If true, [icon] must be provided.
  final IconData? icon;
  final HButtonIconPosition iconPosition;

  final _HButtonVariant _variant;

  final Color? color;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final double iconSize;
  final double gap;
  final TextStyle? textStyle;

  const HButton.filled({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconPosition = HButtonIconPosition.left,
    this.color,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.width,
    this.height,
    this.iconSize = 16,
    this.gap = 6.0,
    this.textStyle,
  }) : _variant = _HButtonVariant.filled;

  const HButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconPosition = HButtonIconPosition.left,
    this.color,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.width,
    this.height,
    this.iconSize = 16,
    this.gap = 6.0,
    this.textStyle,
  }) : _variant = _HButtonVariant.outlined;

  const HButton.plain({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconPosition = HButtonIconPosition.left,
    this.color,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.width,
    this.height,
    this.iconSize = 16,
    this.gap = 6.0,
    this.textStyle,
  }) : _variant = _HButtonVariant.plain;

  const HButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconPosition = HButtonIconPosition.left,
    this.color,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.width,
    this.height,
    this.iconSize = 16,
    this.gap = 6.0,
    this.textStyle,
  }) : _variant = _HButtonVariant.tonal;

  @override
  State<HButton> createState() => _HButtonState();
}

class _HButtonState extends State<HButton> {
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

  // ---- Adaptive height calculation (32 for desktop, 44 for mobile) ----
  double get _resolvedHeight {
    if (widget.height != null) return widget.height!;

    final bool isDesktop =
        !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    return isDesktop ? 32.0 : 44.0;
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
        case _HButtonVariant.plain:
          return Colors.transparent;
      }
    }

    final theme = Theme.of(context).colorScheme;

    final Color resting;
    switch (widget._variant) {
      case _HButtonVariant.filled:
        resting = _baseColor;
      case _HButtonVariant.tonal:
        // If the caller passed a custom color, fall back to an alpha blend
        // since there's no "custom container" token to reach for.
        // Otherwise use the real M3 tonal pairing.
        // resting = widget.color != null
        //     ? _baseColor.withValues(alpha: 0.12)
        //     : theme.primaryContainer;
        resting = theme.primaryContainer;
      case _HButtonVariant.outlined:
      case _HButtonVariant.plain:
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
      case _HButtonVariant.filled:
        return theme.onPrimary;
      case _HButtonVariant.tonal:
        return theme.onPrimaryContainer;
      case _HButtonVariant.outlined:
      case _HButtonVariant.plain:
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

  EdgeInsetsGeometry get _resolvedPadding {
    if (widget.icon == null) return widget.padding;

    final resolved = widget.padding.resolve(Directionality.of(context));

    return switch (widget.iconPosition) {
      HButtonIconPosition.left => EdgeInsets.only(
        left: 12,
        right: 16,
        top: resolved.top,
        bottom: resolved.bottom,
      ),
      HButtonIconPosition.right => EdgeInsets.only(
        left: 16,
        right: 12,
        top: resolved.top,
        bottom: resolved.bottom,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = _resolvedHeight <= 36;

    final children = <Widget>[
      if (widget.icon != null &&
          widget.iconPosition == HButtonIconPosition.left) ...[
        Icon(widget.icon, size: widget.iconSize, color: _fgColor),
        SizedBox(width: widget.gap),
      ],
      DefaultTextStyle(
        style:
            (widget.textStyle ?? const TextStyle(fontWeight: FontWeight.w600))
                .copyWith(
                  color: _fgColor,
                  fontSize: widget.textStyle?.fontSize ?? (isDesktop ? 13 : 14),
                ),
        child: widget.label,
      ),
      if (widget.icon != null &&
          widget.iconPosition == HButtonIconPosition.right) ...[
        SizedBox(width: widget.gap),
        Icon(widget.icon, size: widget.iconSize, color: _fgColor),
      ],
    ];

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: _resolvedPadding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        border: _border,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: widget.width != null
            ? MainAxisSize.max
            : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );

    // Force shrink-to-content when no explicit width was requested,
    // regardless of what constraints the parent (Column/stretch, etc.) hands down.
    if (widget.width == null) {
      content = IntrinsicWidth(child: content);
    }

    return MouseRegion(
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
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: SizedBox(
            width: widget.width,
            height: _resolvedHeight,
            child: content,
          ),
        ),
      ),
    );
  }
}
