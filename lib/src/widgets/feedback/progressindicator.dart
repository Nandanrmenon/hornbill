import 'package:flutter/material.dart';
import 'package:hornbill/src/helpers/constants.dart';

/// A customizable horizontal (linear) progress indicator.
///
/// Supports both determinate progress (0.0 - 1.0) and an indeterminate
/// "loading" animation when [value] is null.
class HProgressIndicator extends StatefulWidget {
  /// Progress value between 0.0 and 1.0. Pass `null` for an indeterminate
  /// (looping) animation.
  final double? value;

  /// Height of the progress bar.
  final double height;

  /// Corner radius of the bar.
  final double? borderRadius;

  /// Background (track) color.
  final Color? backgroundColor;

  /// Color of the progress fill. Ignored if [gradient] is provided.
  final Color? progressColor;

  /// Optional gradient for the progress fill, overrides [progressColor].
  final Gradient? gradient;

  /// Duration used for animating value changes and the indeterminate loop.
  final Duration animationDuration;

  /// Whether to show the percentage label above the bar.
  final bool showLabel;

  /// Text style for the percentage label.
  final TextStyle? labelStyle;

  const HProgressIndicator({
    super.key,
    this.value,
    this.height = 16,
    this.borderRadius,
    this.backgroundColor,
    this.progressColor,
    this.gradient,
    this.animationDuration = const Duration(milliseconds: 400),
    this.showLabel = false,
    this.labelStyle,
  }) : assert(
         value == null || (value >= 0.0 && value <= 1.0),
         'value must be between 0.0 and 1.0',
       );

  @override
  State<HProgressIndicator> createState() => _HProgressIndicatorState();
}

class _HProgressIndicatorState extends State<HProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _indeterminateController;

  @override
  void initState() {
    super.initState();
    _indeterminateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.value == null) {
      _indeterminateController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_indeterminateController.isAnimating) {
      _indeterminateController.repeat();
    } else if (widget.value != null && _indeterminateController.isAnimating) {
      _indeterminateController.stop();
    }
  }

  @override
  void dispose() {
    _indeterminateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(kBorderRadiusMedium);

    final bar = ClipRRect(
      borderRadius: radius,
      child: Container(
        height: widget.height,
        color:
            widget.backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHigh,
        child: widget.value == null
            ? AnimatedBuilder(
                animation: _indeterminateController,
                builder: (context, _) {
                  return _IndeterminateBar(
                    progress: _indeterminateController.value,
                    color:
                        widget.progressColor ??
                        Theme.of(context).colorScheme.primary,
                    gradient: widget.gradient,
                  );
                },
              )
            : Align(
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: widget.value),
                  duration: widget.animationDuration,
                  curve: Curves.easeInOut,
                  builder: (context, animatedValue, _) {
                    return FractionallySizedBox(
                      widthFactor: animatedValue.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: widget.borderRadius != null
                              ? BorderRadius.circular(widget.borderRadius!)
                              : radius,
                          color: widget.gradient == null
                              ? (widget.progressColor ??
                                    Theme.of(context).colorScheme.primary)
                              : null,
                          gradient: widget.gradient,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );

    if (!widget.showLabel) return bar;

    final labelText = widget.value == null
        ? ''
        : '${(widget.value! * 100).toStringAsFixed(0)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              labelText,
              style: widget.labelStyle ?? Theme.of(context).textTheme.bodySmall,
            ),
          ),
        bar,
      ],
    );
  }
}

/// Paints the sliding segment used for the indeterminate animation.
class _IndeterminateBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0 loop position
  final Color color;
  final Gradient? gradient;

  const _IndeterminateBar({
    required this.progress,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final segmentWidth = width * 0.35;
        // Slide the segment from -segmentWidth to width.
        final left = (width + segmentWidth) * progress - segmentWidth;

        return Stack(
          children: [
            Positioned(
              left: left,
              width: segmentWidth,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                  color: gradient == null ? color : null,
                  gradient: gradient,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// --- Example usage ---
///
/// // Determinate:
/// HProgressIndicator(
///   value: 0.65,
///   height: 10,
///   progressColor: Colors.green,
///   showLabel: true,
/// )
///
/// // Indeterminate (loading):
/// HProgressIndicator(
///   height: 6,
///   gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
/// )
