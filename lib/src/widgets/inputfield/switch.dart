import 'package:hornbill/src/theme.dart';
import 'package:material_ui/material_ui.dart';

class HSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Overall size of the switch
  final double width;
  final double height;

  /// Animation
  final Duration duration;
  final Curve curve;

  final bool showCheckIcon;
  final IconData? checkIcon;

  const HSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 48,
    this.height = 24,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.showCheckIcon = false,
    this.checkIcon,
  });

  @override
  State<HSwitch> createState() => _HSwitchState();
}

class _HSwitchState extends State<HSwitch> {
  bool _dragging = false;
  double _dragExtent = 0;

  double get _thumbSize => widget.height + 2;

  void _handleTap() {
    widget.onChanged(!widget.value);
  }

  void _handleDragStart(DragStartDetails details) {
    _dragging = true;
    _dragExtent = widget.value ? 1.0 : 0.0;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final trackWidth = widget.width - _thumbSize - 6;
    setState(() {
      _dragExtent += details.primaryDelta! / trackWidth;
      _dragExtent = _dragExtent.clamp(0.0, 1.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragging = false;
    final shouldBeOn = _dragExtent >= 0.5;
    if (shouldBeOn != widget.value) {
      widget.onChanged(shouldBeOn);
    } else {
      // Snap back visually even if value didn't change
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final double alignmentX = _dragging
        ? (_dragExtent * 2) -
              1 // map 0..1 to -1..1
        : (widget.value ? 1.0 : -1.0);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.height),
      child: GestureDetector(
        onTap: _handleTap,
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        child: AnimatedContainer(
          duration: _dragging ? Duration.zero : widget.duration,
          curve: widget.curve,
          width: widget.width,
          // height: widget.height,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            // color: widget.value
            //     ? Theme.of(context).colorScheme.primary
            //     : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
            color: widget.value
                ? HColors.of(context).primary.base
                : HColors.of(context).neutral[200],
            // border: hIsOutlined(context)
            //     ? Border.all(
            //         color: Theme.of(context).colorScheme.outlineVariant,
            //       )
            //     : null,
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: AnimatedAlign(
            duration: _dragging ? Duration.zero : widget.duration,
            curve: widget.curve,
            alignment: Alignment(alignmentX, 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _thumbSize,
              height: _thumbSize,
              decoration: BoxDecoration(
                color: widget.value
                    ? HColors.of(context).primary.onBase
                    : HColors.of(context).neutral[50],
                borderRadius: BorderRadius.circular(kBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(_thumbSize * 0.6, _thumbSize * 0.6),
                  painter: _SwitchIconPainter(
                    isOn: widget.value,
                    color: widget.value
                        ? HColors.of(context).primary.base
                        : HColors.of(context).mutedForeground,
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

class _SwitchIconPainter extends CustomPainter {
  final bool isOn;
  final Color color;

  const _SwitchIconPainter({required this.isOn, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    if (isOn) {
      // iOS-style vertical "I"
      canvas.drawLine(
        Offset(center.dx, size.height * 0.18),
        Offset(center.dx, size.height * 0.82),
        paint,
      );
    } else {
      // iOS-style "O"
      canvas.drawCircle(center, size.width * 0.31, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwitchIconPainter oldDelegate) {
    return oldDelegate.isOn != isOn || oldDelegate.color != color;
  }
}
