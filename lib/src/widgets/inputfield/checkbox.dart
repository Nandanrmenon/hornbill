import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// A lightweight checkbox widget built only on `package:flutter/widgets.dart`.
///
/// It intentionally avoids the Material library, so it works in apps that
/// don't use `MaterialApp` (e.g. pure Cupertino apps or custom design
/// systems) without pulling in Material dependencies or ripple effects.
///
/// Example:
/// ```dart
/// HCheckBox(
///   value: _checked,
///   onChanged: (v) => setState(() => _checked = v),
/// )
/// ```
class HCheckBox extends StatefulWidget {
  const HCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 22.0,
    this.activeColor,
    this.inactiveColor,
    this.checkColor,
    this.borderRadius = 5.0,
    this.borderWidth = 2.0,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  /// Whether the checkbox is checked.
  final bool value;

  /// Called with the new value when the user taps the checkbox.
  /// Pass `null` to disable the checkbox.
  final ValueChanged<bool>? onChanged;

  /// Width and height of the checkbox square.
  final double size;

  /// Fill/border color when checked.
  final Color? activeColor;

  /// Border color when unchecked.
  final Color? inactiveColor;

  /// Color of the checkmark stroke.
  final Color? checkColor;

  /// Corner radius of the box.
  final double borderRadius;

  /// Width of the box border and checkmark stroke.
  final double borderWidth;

  /// Duration of the check/uncheck animation.
  final Duration animationDuration;

  @override
  State<HCheckBox> createState() => _HCheckBoxState();
}

class _HCheckBoxState extends State<HCheckBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
    value: widget.value ? 1.0 : 0.0,
  );
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeIn,
  );

  // ---- Press/hover physics, mirrored from HButton ----
  bool _pressed = false;
  bool _hovered = false;

  bool get _enabled => widget.onChanged != null;

  Color get _activeColor =>
      widget.activeColor ?? Theme.of(context).colorScheme.primary;
  Color get _inactiveColor =>
      widget.inactiveColor ??
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);
  Color get _checkColor =>
      widget.checkColor ?? Theme.of(context).colorScheme.onPrimary;

  void _setPressed(bool value) {
    if (!_enabled) return;
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (!_enabled) return;
    setState(() => _hovered = value);
  }

  @override
  void didUpdateWidget(covariant HCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final onChanged = widget.onChanged;
    if (onChanged == null) return;
    onChanged(!widget.value);
  }

  // Same "state layer" idea as HButton's hover blend: a faint tint of the
  // active color over the resting border while hovered, so an unchecked box
  // isn't visually dead before the user actually presses it.
  Color get _borderColor {
    final Color resting = widget.value ? _activeColor : _inactiveColor;
    if (!_hovered) return resting;
    final overlay = _activeColor.withValues(alpha: 0.08);
    return Color.alphaBlend(overlay, resting);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: widget.value,
      enabled: _enabled,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _enabled ? _handleTap : null,
          child: AnimatedScale(
            scale: _pressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: Opacity(
              opacity: _enabled ? 1.0 : 0.5,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                curve: Curves.easeOut,
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.value ? _activeColor : null,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: _borderColor,
                    width: widget.borderWidth,
                  ),
                ),
                child: ScaleTransition(
                  scale: _scale,
                  child: Icon(
                    Symbols.check,
                    color: _checkColor,
                    weight: 700,
                    size: widget.size * 0.8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
