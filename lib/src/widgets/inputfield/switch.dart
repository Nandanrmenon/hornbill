import 'package:material_ui/material_ui.dart';
import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class HornbillSwitch extends StatefulWidget {
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

  const HornbillSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 48,
    this.height = 32,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.showCheckIcon = false,
    this.checkIcon,
  });

  @override
  State<HornbillSwitch> createState() => _HornbillSwitchState();
}

class _HornbillSwitchState extends State<HornbillSwitch> {
  bool _dragging = false;
  double _dragExtent = 0;

  double get _thumbSize => widget.height - 6;

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
            color: Theme.of(context).colorScheme.surfaceContainer,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          child: AnimatedAlign(
            duration: _dragging ? Duration.zero : widget.duration,
            curve: widget.curve,
            alignment: Alignment(alignmentX, 0),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: _thumbSize,
              height: _thumbSize,
              decoration: BoxDecoration(
                // color: Theme.of(context).colorScheme.surface,
                color: widget.value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(kBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: widget.value
                  ? Visibility(
                      visible: widget.showCheckIcon,
                      child: Icon(
                        widget.checkIcon ?? Symbols.check_rounded,
                        size: _thumbSize * 0.6,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
