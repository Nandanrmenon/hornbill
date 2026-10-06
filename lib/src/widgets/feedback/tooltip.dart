import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';

enum HTooltipPosition { top, bottom, left, right }

class HTooltip extends StatefulWidget {
  const HTooltip({
    super.key,
    required this.message,
    required this.child,
    this.position = HTooltipPosition.top,
    this.offset = 8,
    this.waitDuration = const Duration(milliseconds: 400),
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.borderRadius = 7,
    this.maxWidth = 280,
    this.arrowSize = 6,
    this.textStyle,
  });

  final String message;
  final Widget child;

  final HTooltipPosition position;

  /// Distance between the trigger and the tooltip.
  final double offset;

  /// Delay before showing the tooltip.
  final Duration waitDuration;

  final Color? backgroundColor;
  final Color? textColor;

  final EdgeInsets padding;
  final double borderRadius;
  final double maxWidth;

  /// Size of the tooltip arrow.
  final double arrowSize;

  final TextStyle? textStyle;

  @override
  State<HTooltip> createState() => _HTooltipState();
}

class _HTooltipState extends State<HTooltip>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;

  Timer? _showTimer;

  late final AnimationController _animationController;

  bool _hovering = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 80),
    );
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _overlayEntry?.remove();

    _animationController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Show
  // ---------------------------------------------------------------------------

  void _scheduleShow() {
    _showTimer?.cancel();

    _showTimer = Timer(widget.waitDuration, () {
      if (_hovering) {
        _showTooltip();
      }
    });
  }

  void _showTooltip() {
    if (_overlayEntry != null || !mounted) {
      return;
    }

    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final targetOffset = renderObject.localToGlobal(Offset.zero);

    final targetRect = targetOffset & renderObject.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.sizeOf(context);

        return CustomSingleChildLayout(
          delegate: _HTooltipLayoutDelegate(
            targetRect: targetRect,
            screenSize: screenSize,
            position: widget.position,
            offset: widget.offset,
            margin: 8,
            arrowSize: widget.arrowSize,
          ),
          child: _HTooltipAnimation(
            controller: _animationController,
            position: widget.position,
            child: _buildTooltip(),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);

    _animationController.forward(from: 0);
  }

  // ---------------------------------------------------------------------------
  // Hide
  // ---------------------------------------------------------------------------

  void _hideTooltip() {
    _showTimer?.cancel();

    if (_overlayEntry == null) {
      return;
    }

    final entry = _overlayEntry;

    _animationController.reverse().then((_) {
      if (entry == _overlayEntry) {
        entry?.remove();
        _overlayEntry = null;
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Tooltip
  // ---------------------------------------------------------------------------

  Widget _buildTooltip() {
    return _HTooltipBubble(
      message: widget.message,
      position: widget.position,
      backgroundColor: widget.backgroundColor ?? HColors.of(context).background,
      textColor: widget.textColor ?? HColors.of(context).foreground,
      borderColor: HColors.of(context).border,
      padding: widget.padding,
      borderRadius: widget.borderRadius,
      maxWidth: widget.maxWidth,
      arrowSize: widget.arrowSize,
      textStyle: widget.textStyle,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final supportsHover =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;

    if (supportsHover) {
      return MouseRegion(
        cursor: SystemMouseCursors.basic,
        onEnter: (_) {
          _hovering = true;
          _scheduleShow();
        },
        onExit: (_) {
          _hovering = false;

          // Cancel a tooltip that hasn't appeared yet.
          _showTimer?.cancel();

          // Immediately dismiss a visible tooltip.
          _hideTooltip();
        },
        child: widget.child,
      );
    }

    return GestureDetector(
      onLongPress: () {
        _showTooltip();
      },
      onTap: () {
        if (_overlayEntry != null) {
          _hideTooltip();
        }
      },
      child: widget.child,
    );
  }
}

// =============================================================================
// Tooltip bubble
// =============================================================================

class _HTooltipBubble extends StatelessWidget {
  const _HTooltipBubble({
    required this.message,
    required this.position,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.padding,
    required this.borderRadius,
    required this.maxWidth,
    required this.arrowSize,
    required this.textStyle,
  });

  final String message;
  final HTooltipPosition position;

  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  final EdgeInsets padding;
  final double borderRadius;
  final double maxWidth;

  final double arrowSize;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _HTooltipArrowPainter(
        position: position,
        color: backgroundColor,
        borderColor: borderColor,
        arrowSize: arrowSize,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          message,
          softWrap: true,
          style:
              textStyle ??
              TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.25,
                decoration: TextDecoration.none,
              ),
        ),
      ),
    );
  }
}

// =============================================================================
// Arrow painter
// =============================================================================

class _HTooltipArrowPainter extends CustomPainter {
  const _HTooltipArrowPainter({
    required this.position,
    required this.color,
    required this.borderColor,
    required this.arrowSize,
  });

  final HTooltipPosition position;
  final Color color;
  final Color borderColor;
  final double arrowSize;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final path = Path();

    switch (position) {
      case HTooltipPosition.top:
        path.moveTo(size.width / 2 - arrowSize, size.height);
        path.lineTo(size.width / 2, size.height + arrowSize);
        path.lineTo(size.width / 2 + arrowSize, size.height);
        break;

      case HTooltipPosition.bottom:
        path.moveTo(size.width / 2 - arrowSize, 0);
        path.lineTo(size.width / 2, -arrowSize);
        path.lineTo(size.width / 2 + arrowSize, 0);
        break;

      case HTooltipPosition.left:
        path.moveTo(size.width, size.height / 2 - arrowSize);
        path.lineTo(size.width + arrowSize, size.height / 2);
        path.lineTo(size.width, size.height / 2 + arrowSize);
        break;

      case HTooltipPosition.right:
        path.moveTo(0, size.height / 2 - arrowSize);
        path.lineTo(-arrowSize, size.height / 2);
        path.lineTo(0, size.height / 2 + arrowSize);
        break;
    }

    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_HTooltipArrowPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.arrowSize != arrowSize;
  }
}

// =============================================================================
// Layout
// =============================================================================

class _HTooltipLayoutDelegate extends SingleChildLayoutDelegate {
  const _HTooltipLayoutDelegate({
    required this.targetRect,
    required this.screenSize,
    required this.position,
    required this.offset,
    required this.margin,
    required this.arrowSize,
  });

  final Rect targetRect;
  final Size screenSize;

  final HTooltipPosition position;

  final double offset;
  final double margin;
  final double arrowSize;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      maxWidth: screenSize.width - margin * 2,
      maxHeight: screenSize.height - margin * 2,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double left;
    double top;

    final totalOffset = offset + arrowSize;

    switch (position) {
      case HTooltipPosition.top:
        left = targetRect.center.dx - childSize.width / 2;
        top = targetRect.top - childSize.height - totalOffset;
        break;

      case HTooltipPosition.bottom:
        left = targetRect.center.dx - childSize.width / 2;
        top = targetRect.bottom + totalOffset;
        break;

      case HTooltipPosition.left:
        left = targetRect.left - childSize.width - totalOffset;
        top = targetRect.center.dy - childSize.height / 2;
        break;

      case HTooltipPosition.right:
        left = targetRect.right + totalOffset;
        top = targetRect.center.dy - childSize.height / 2;
        break;
    }

    // Keep tooltip inside viewport.
    left = left.clamp(margin, size.width - childSize.width - margin);
    top = top.clamp(margin, size.height - childSize.height - margin);

    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_HTooltipLayoutDelegate oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        screenSize != oldDelegate.screenSize ||
        position != oldDelegate.position ||
        offset != oldDelegate.offset ||
        arrowSize != oldDelegate.arrowSize;
  }
}

// =============================================================================
// Animation
// =============================================================================

class _HTooltipAnimation extends StatelessWidget {
  const _HTooltipAnimation({
    required this.controller,
    required this.position,
    required this.child,
  });

  final AnimationController controller;
  final HTooltipPosition position;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeIn,
    );

    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
        alignment: _scaleAlignment,
        child: child,
      ),
    );
  }

  Alignment get _scaleAlignment {
    switch (position) {
      case HTooltipPosition.top:
        return Alignment.bottomCenter;

      case HTooltipPosition.bottom:
        return Alignment.topCenter;

      case HTooltipPosition.left:
        return Alignment.centerRight;

      case HTooltipPosition.right:
        return Alignment.centerLeft;
    }
  }
}
