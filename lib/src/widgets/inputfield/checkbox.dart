import 'package:flutter/services.dart';
import 'package:hornbill/src/theme.dart';
import 'package:material_ui/material_ui.dart';

/// HeroUI sizes: sm = 16px, md = 20px, lg = 24px box.
enum HCheckBoxSize { sm, md, lg }

/// A HeroUI-style checkbox.
///
///  * 2px rounded border that fills with the accent colour when checked
///  * an animated, hand-drawn check mark (draws itself in) or a dash for
///    [isIndeterminate]
///  * soft hover fill, 0.95 press scale, 50% opacity when disabled
///  * optional [label] (the whole row is the tap target), with an optional
///    [lineThrough] when checked
///  * keyboard focus ring; Space toggles
///
/// Built without Material's Checkbox or InkWell. The accent is always the
/// theme's primary colour ([HColors.primary]).
///
/// It hugs its content even when its parent forces a width (for example a
/// bare `SliverToBoxAdapter`): the box stays at the start edge instead of
/// stretching.
///
/// ```dart
/// HCheckBox(
///   value: accepted,
///   onChanged: (v) => setState(() => accepted = v),
///   label: Text('I accept the terms'),
/// )
/// ```
class HCheckBox extends StatefulWidget {
  const HCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.size = HCheckBoxSize.md,
    this.radius,
    this.isIndeterminate = false,
    this.lineThrough = false,
  });

  /// Whether the checkbox is checked.
  final bool value;

  /// Called with the new value on tap. `null` disables the checkbox.
  final ValueChanged<bool>? onChanged;

  /// Text (or any widget) shown to the right of the box. Tapping it toggles
  /// the checkbox too.
  final Widget? label;

  final HCheckBoxSize size;

  /// Overrides the corner radius (sm 4, md 6, lg 8 by default).
  final double? radius;

  /// Shows a dash instead of a check mark. Takes visual priority over
  /// [value]; tapping still calls [onChanged] with `!value`.
  final bool isIndeterminate;

  /// Strikes the label through (and mutes it) while checked.
  final bool lineThrough;

  @override
  State<HCheckBox> createState() => _HCheckBoxState();
}

class _HCheckBoxState extends State<HCheckBox>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 200);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
    value: _on ? 1.0 : 0.0,
  );

  // The fill grows first, then the mark draws itself in.
  late final Animation<double> _fill = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
  );
  late final Animation<double> _mark = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
  );

  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  bool get _enabled => widget.onChanged != null;
  bool get _on => widget.value || widget.isIndeterminate;

  // ---- Size tokens ----
  double get _box => switch (widget.size) {
    HCheckBoxSize.sm => 16,
    HCheckBoxSize.md => 20,
    HCheckBoxSize.lg => 24,
  };
  double get _radius =>
      widget.radius ??
      switch (widget.size) {
        HCheckBoxSize.sm => 4,
        HCheckBoxSize.md => 6,
        HCheckBoxSize.lg => 8,
      };
  double get _fontSize => switch (widget.size) {
    HCheckBoxSize.sm => 12,
    HCheckBoxSize.md => 14,
    HCheckBoxSize.lg => 16,
  };
  double get _gap => widget.size == HCheckBoxSize.sm ? 6 : 8;
  static const double _borderWidth = 2;

  @override
  void didUpdateWidget(covariant HCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasOn = oldWidget.value || oldWidget.isIndeterminate;
    if (wasOn != _on) {
      _on ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    final onChanged = widget.onChanged;
    if (onChanged != null) onChanged(!widget.value);
  }

  void _setPressed(bool v) {
    if (_enabled) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final c = HColors.of(context);
    final fill = c.primary.base;
    final onFill = c.primary.onBase;
    final radius = BorderRadius.circular(_radius);
    final innerRadius = BorderRadius.circular(
      (_radius - _borderWidth).clamp(0.0, double.infinity),
    );

    final box = AnimatedContainer(
      duration: _duration,
      curve: Curves.easeOut,
      width: _box,
      height: _box,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: _on ? fill : c.neutral[300]!,
          width: _borderWidth,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(color: c.background, spreadRadius: 2),
                BoxShadow(color: c.primary.base, spreadRadius: 4),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: innerRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Soft hover fill while unchecked.
            AnimatedOpacity(
              opacity: (_hovered && _enabled && !_on) ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: ColoredBox(color: c.neutral[100]!),
            ),
            // Accent fill that grows in from the centre.
            FadeTransition(
              opacity: _fill,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1).animate(_fill),
                child: ColoredBox(color: fill),
              ),
            ),
            // The mark.
            CustomPaint(
              painter: _MarkPainter(
                progress: _mark,
                color: onFill,
                strokeWidth: _box * 0.11,
                indeterminate: widget.isIndeterminate,
              ),
            ),
          ],
        ),
      ),
    );

    Widget content = box;
    if (widget.label != null) {
      final muted = widget.lineThrough && widget.value;
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          SizedBox(width: _gap),
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: _duration,
              style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: _fontSize,
                color: muted ? c.mutedForeground : c.foreground,
                decoration: muted ? TextDecoration.lineThrough : null,
                decorationColor: c.mutedForeground,
              ),
              child: widget.label!,
            ),
          ),
        ],
      );
    }

    final checkbox = Semantics(
      checked: widget.value,
      mixed: widget.isIndeterminate,
      enabled: _enabled,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _toggle();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _enabled ? _toggle : null,
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: Opacity(opacity: _enabled ? 1.0 : 0.5, child: content),
          ),
        ),
      ),
    );

    // Parents like SliverToBoxAdapter pass *tight* constraints, which would
    // stretch the box (and its tap target) to the full width. Align loosens
    // them, so the checkbox keeps its own size and sits at the start edge.
    // `widthFactor/heightFactor: 1` also makes it hug its content under loose
    // constraints (Row, Wrap, Column, ...).
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      heightFactor: 1,
      child: checkbox,
    );
  }
}

/// Draws a check mark (or a dash) that "writes itself" as [progress] goes
/// from 0 to 1.
class _MarkPainter extends CustomPainter {
  _MarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.indeterminate,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;
  final double strokeWidth;
  final bool indeterminate;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    if (indeterminate) {
      path
        ..moveTo(w * 0.26, h * 0.5)
        ..lineTo(w * 0.74, h * 0.5);
    } else {
      path
        ..moveTo(w * 0.24, h * 0.52)
        ..lineTo(w * 0.43, h * 0.70)
        ..lineTo(w * 0.77, h * 0.32);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress.value),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.indeterminate != indeterminate;
}