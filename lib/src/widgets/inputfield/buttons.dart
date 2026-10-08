import 'package:flutter/services.dart';
import 'package:hornbill/hornbill.dart' show HColors, HSpinner, hButtonRadius;
import 'package:hornbill/src/widgets/feedback/tooltip.dart';
import 'package:material_ui/material_ui.dart';

/// Position of the icon relative to the label.
enum HButtonIconPosition { left, right }

/// HeroUI variants.
enum HButtonVariant { solid, bordered, light, flat, faded, shadow, ghost }

/// HeroUI semantic colors.
enum HButtonColor { defaultColor, primary, secondary, success, warning, danger }

/// HeroUI sizes: sm = 32px, md = 40px, lg = 48px tall.
enum HButtonSize { sm, md, lg }

class HButton extends StatefulWidget {
  /// Null label + non-null [icon] => square icon-only button.
  final Widget? label;
  final String? tooltip;
  final IconData? icon;
  final HButtonIconPosition iconPosition;
  final VoidCallback? onPressed;

  final HButtonVariant variant;
  final HButtonColor color;
  final HButtonSize size;

  /// Overrides the radius derived from [size] (sm 8, md 12, lg 14).
  final double? radius;
  final bool isLoading;
  final bool fullWidth;
  final TextStyle? textStyle;

  const HButton({
    super.key,
    this.label,
    this.tooltip,
    this.icon,
    this.iconPosition = HButtonIconPosition.left,
    required this.onPressed,
    this.variant = HButtonVariant.solid,
    this.color = HButtonColor.defaultColor,
    this.size = HButtonSize.md,
    this.radius,
    this.isLoading = false,
    this.fullWidth = false,
    this.textStyle,
  }) : assert(label != null || icon != null, 'Provide a label or an icon');

  @override
  State<HButton> createState() => _HButtonState();
}

/// Resolved colors for one build.
class _Style {
  final Color bg, fg, hoverBg, hoverFg;
  final Color? border;
  final bool hoverUsesOpacity;
  const _Style({
    required this.bg,
    required this.fg,
    required this.hoverBg,
    required this.hoverFg,
    this.border,
    this.hoverUsesOpacity = true,
  });
}

class _HButtonState extends State<HButton> {
  /// Gap between the button edge and the focus ring's inner edge.
  static const double _ringGap = 2;

  /// Thickness of the focus ring border.
  static const double _ringWidth = 2;

  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  final FocusNode _focusNode = FocusNode(debugLabel: 'HButton');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onPressed != null && !widget.isLoading;
  bool get _iconOnly => widget.label == null;

  // ---- Size tokens ----
  double get _height => switch (widget.size) {
    HButtonSize.sm => 32,
    HButtonSize.md => 40,
    HButtonSize.lg => 48,
  };
  double get _hPad => switch (widget.size) {
    HButtonSize.sm => 12,
    HButtonSize.md => 16,
    HButtonSize.lg => 24,
  };
  double get _minWidth => switch (widget.size) {
    HButtonSize.sm => 64,
    HButtonSize.md => 80,
    HButtonSize.lg => 96,
  };
  double _resolveRadius(BuildContext context) =>
      widget.radius ??
      hButtonRadius(context)?.value ??
      switch (widget.size) {
        HButtonSize.sm => 8,
        HButtonSize.md => 12,
        HButtonSize.lg => 14,
      };
  double get _fontSize => widget.size == HButtonSize.lg ? 16 : 14;
  double get _iconSize => widget.size == HButtonSize.sm ? 16 : 20;
  double get _gap => widget.size == HButtonSize.sm ? 6 : 8;

  // ---- Color tokens ----
  /// (base color, color used on top of the base)
  (Color, Color) _palette(BuildContext context) {
    final c = HColors.of(context);
    return switch (widget.color) {
      HButtonColor.defaultColor => (c.neutral[200]!, c.foreground),
      HButtonColor.primary => (c.primary.base, c.primary.onBase),
      HButtonColor.secondary => (c.secondary.base, c.secondary.onBase),
      HButtonColor.success => (c.success.base, c.success.onBase),
      HButtonColor.warning => (c.warning.base, c.warning.onBase),
      HButtonColor.danger => (c.danger.base, c.danger.onBase),
    };
  }

  _Style _resolve(BuildContext context) {
    final (base, onBase) = _palette(context);
    final c = HColors.of(context);
    final isDefault = widget.color == HButtonColor.defaultColor;
    final foreground = c.foreground;

    // "default" color needs neutral borders/text on non-solid variants.
    final accent = isDefault ? foreground : base;
    final neutralBorder = c.neutral[300]!;
    final borderColor = isDefault ? neutralBorder : base;

    switch (widget.variant) {
      case HButtonVariant.solid:
      case HButtonVariant.shadow:
        return _Style(bg: base, fg: onBase, hoverBg: base, hoverFg: onBase);
      case HButtonVariant.bordered:
        return _Style(
          bg: Colors.transparent,
          fg: accent,
          hoverBg: Colors.transparent,
          hoverFg: accent,
          border: borderColor,
        );
      case HButtonVariant.light:
        return _Style(
          bg: Colors.transparent,
          fg: accent,
          hoverBg: (isDefault ? neutralBorder : base).withValues(alpha: 0.2),
          hoverFg: accent,
          hoverUsesOpacity: false,
        );
      case HButtonVariant.flat:
        final bg = (isDefault ? neutralBorder : base).withValues(
          alpha: isDefault ? 0.4 : 0.2,
        );
        return _Style(bg: bg, fg: accent, hoverBg: bg, hoverFg: accent);
      case HButtonVariant.faded:
        final bg = c.neutral[100]!;
        return _Style(
          bg: bg,
          fg: accent,
          hoverBg: bg,
          hoverFg: accent,
          border: c.neutral[200],
        );
      case HButtonVariant.ghost:
        return _Style(
          bg: Colors.transparent,
          fg: accent,
          hoverBg: base,
          hoverFg: onBase,
          border: borderColor,
          hoverUsesOpacity: false,
        );
    }
  }

  void _setPressed(bool v) {
    if (_enabled) setState(() => _pressed = v);
  }

  void _activate() {
    if (_enabled) widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final s = _resolve(context);
    final (base, _) = _palette(context);
    final hovered = _hovered && _enabled;

    final bg = hovered && !s.hoverUsesOpacity ? s.hoverBg : s.bg;
    final fg = hovered && !s.hoverUsesOpacity ? s.hoverFg : s.fg;

    // HeroUI: disabled = 50% opacity, hover (solid-ish variants) = 80% opacity.
    final opacity = !_enabled && !widget.isLoading
        ? 0.5
        : (hovered && s.hoverUsesOpacity ? 0.8 : 1.0);

    final shadows = <BoxShadow>[
      if (widget.variant == HButtonVariant.shadow)
        BoxShadow(
          color: base.withValues(alpha: 0.4),
          blurRadius: 16,
          spreadRadius: -3,
          offset: const Offset(0, 8),
        ),
    ];

    final textStyle = (widget.textStyle ?? const TextStyle()).copyWith(
      color: fg,
      fontSize: widget.textStyle?.fontSize ?? _fontSize,
      fontWeight: widget.textStyle?.fontWeight ?? FontWeight.w500,
      height: 1.2,
    );

    final iconWidget = widget.isLoading
        ? SizedBox(
            width: _iconSize - 4,
            height: _iconSize - 4,
            child: HSpinner(color: fg),
          )
        : (widget.icon != null
              ? Icon(widget.icon, size: _iconSize, color: fg)
              : null);

    final children = <Widget>[
      if (iconWidget != null &&
          (widget.iconPosition == HButtonIconPosition.left || _iconOnly)) ...[
        iconWidget,
        if (!_iconOnly) SizedBox(width: _gap),
      ],
      if (widget.label != null)
        Flexible(
          child: DefaultTextStyle(
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            child: widget.label!,
          ),
        ),
      if (iconWidget != null &&
          widget.iconPosition == HButtonIconPosition.right &&
          !_iconOnly) ...[
        SizedBox(width: _gap),
        iconWidget,
      ],
    ];

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      height: _height,
      constraints: BoxConstraints(minWidth: _iconOnly ? _height : _minWidth),
      padding: EdgeInsets.symmetric(horizontal: _iconOnly ? 0 : _hPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_resolveRadius(context)),
        border: s.border != null
            ? Border.all(color: s.border!, width: 2)
            : null,
        boxShadow: shadows,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );

    // Focus ring: a separate border layer drawn outside the button, with a
    // 2px gap between the button and the ring. It paints outside the
    // button's bounds, so toggling focus never shifts layout.
    const ringOutset = _ringGap + _ringWidth;
    content = Stack(
      // passthrough so the button still fills the width when fullWidth is set.
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        content,
        Positioned(
          left: -ringOutset,
          right: -ringOutset,
          top: -ringOutset,
          bottom: -ringOutset,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _focused ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    _resolveRadius(context) + ringOutset,
                  ),
                  border: Border.all(
                    color: _ringColor(context),
                    width: _ringWidth,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    content = widget.fullWidth
        ? SizedBox(width: double.infinity, child: content)
        : IntrinsicWidth(child: content);

    // Flutter doesn't clear focus when you click empty space, so the ring
    // would stay forever. Drop focus when a tap lands outside this button.
    return TapRegion(
      onTapOutside: (_) {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      child: FocusableActionDetector(
        focusNode: _focusNode,
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _enabled ? widget.onPressed : null,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0, // HeroUI: scale-[0.97] on press
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 150),
              child: widget.label != null
                  ? content
                  : widget.label == null && widget.tooltip != null
                  ? HTooltip(message: widget.tooltip!, child: content)
                  : content,
            ),
          ),
        ),
      ),
    );
  }

  Color _ringColor(BuildContext context) {
    return HColors.of(context).primary.base;
  }
}
