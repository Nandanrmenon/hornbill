import 'package:hornbill/src/helpers/constants.dart';
import 'package:hornbill/src/theme.dart';
import 'package:material_ui/material_ui.dart';

/// A single destination in an [HNavigationBar].
class HNavigationBarItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const HNavigationBarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// A floating, pill-shaped bottom navigation bar with an animated
/// highlight that slides behind the selected item.
///
/// Meant to be used as [HScaffold.bottomNavigationBar]. `HScaffold` handles
/// hiding/showing it on scroll — this widget only owns its own look
/// (margin, rounded corners, elevation), the sliding selection highlight,
/// and per-item tap/selection animation.
///
/// Does not use Flutter's Material `BottomNavigationBar` / `NavigationBar`.
class HNavigationBar extends StatefulWidget {
  final List<HNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;

  final double height;

  /// Preferred width of each item. The bar's preferred total width is
  /// `itemWidth * items.length` (plus padding) instead of stretching to
  /// fill the screen. If that preferred width doesn't fit the space the
  /// bar is given (e.g. many items on a narrow phone), every item's width
  /// is scaled down proportionally so the whole bar fits without
  /// overflowing — use [margin]'s horizontal insets to control how much
  /// space is left free at the edges, or wrap the bar yourself for custom
  /// placement.
  final double itemWidth;
  final double iconSize;
  final double indicatorHeight;
  final double indicatorWidth;
  final TextStyle? labelStyle;
  final bool showLabels;

  /// Space between the bar and the screen edges. Only affects how far the
  /// (content-sized) bar sits from the edges/bottom, since the bar no
  /// longer stretches to fill the available width.
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;

  final Duration duration;
  final Curve curve;

  final double fullWidthBreakpoint;

  const HNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.height = 64,
    this.itemWidth = 72,
    this.iconSize = 24,
    this.indicatorHeight = 56,
    this.indicatorWidth = 72,
    this.labelStyle,
    this.showLabels = true,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 12),
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
    this.elevation = 2,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
    this.fullWidthBreakpoint = 600,
  }) : assert(
         items.length >= 2,
         'HFloatingNavigationBar needs at least 2 items',
       ),
       assert(
         items.length <= 5,
         'HFloatingNavigationBar supports at most 5 items',
       );

  @override
  State<HNavigationBar> createState() => _HNavigationBarState();
}

class _HNavigationBarState extends State<HNavigationBar> {
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final bgColor = widget.backgroundColor ?? theme.surfaceContainerLowest;
    final borderColor = theme.surfaceContainerHigh;
    final selectedColor = widget.selectedColor ?? theme.primary;
    final unselectedColor = widget.unselectedColor ?? theme.onSurfaceVariant;
    final radius = BorderRadius.circular(kBorderRadiusRounded);

    return SafeArea(
      top: false,
      minimum: widget.margin,
      // NOTE: intentionally a Row, not a Center/Align. Scaffold gives
      // bottomNavigationBar a bounded-but-generous height budget, and
      // Center/Align expand to fill that whole budget before centering
      // their child inside it — which pushed this bar toward the middle
      // of the screen instead of hugging the bottom. Row sizes to its
      // children's height, so it only takes the space the pill needs.
      child: LayoutBuilder(
        builder: (context, constraints) {
          // // The bar's *preferred* width, if every item got the full
          // // itemWidth. On a narrow screen with several items this can
          // // exceed the space actually available (constraints.maxWidth),
          // // which would overflow the outer Row (it centers its child but
          // // never constrains it). So: scale every item down proportionally
          // // when the preferred width doesn't fit, and leave it alone
          // // otherwise.
          // final preferredContentWidth = widget.itemWidth * widget.items.length;
          // final preferredTotalWidth =
          //     preferredContentWidth + widget.padding.horizontal;
          // final scale = preferredTotalWidth > constraints.maxWidth
          //     ? constraints.maxWidth / preferredTotalWidth
          //     : 1.0;
          // final itemWidth = widget.itemWidth * scale;
          // final indicatorWidth = widget.indicatorWidth * scale;
          // final contentWidth = itemWidth * widget.items.length;

          // final rawLeft =
          //     widget.currentIndex * itemWidth +
          //     (itemWidth - indicatorWidth) / 2;
          // final maxLeft = (contentWidth - indicatorWidth).clamp(
          //   0.0,
          //   double.infinity,
          // );
          // final indicatorLeft = rawLeft.clamp(0.0, maxLeft);

          final useFullWidth =
              constraints.maxWidth < widget.fullWidthBreakpoint;

          final double itemWidth;
          final double indicatorWidth;
          final double contentWidth;

          if (useFullWidth) {
            // Fill all the space we're given; split it evenly across items.
            contentWidth = constraints.maxWidth - widget.padding.horizontal;
            itemWidth = contentWidth / widget.items.length;
            final scale = itemWidth / widget.itemWidth;
            indicatorWidth = (widget.indicatorWidth * scale).clamp(
              0.0,
              itemWidth,
            );
          } else {
            // Compact floating pill, sized to content. Still guard against
            // overflow if items somehow don't fit even at this width.
            final preferredContentWidth =
                widget.itemWidth * widget.items.length;
            final preferredTotalWidth =
                preferredContentWidth + widget.padding.horizontal;
            final scale = preferredTotalWidth > constraints.maxWidth
                ? constraints.maxWidth / preferredTotalWidth
                : 1.0;
            itemWidth = widget.itemWidth * scale;
            indicatorWidth = widget.indicatorWidth * scale;
            contentWidth = itemWidth * widget.items.length;
          }

          final rawLeft =
              widget.currentIndex * itemWidth +
              (itemWidth - indicatorWidth) / 2;
          final maxLeft = (contentWidth - indicatorWidth).clamp(
            0.0,
            double.infinity,
          );
          final indicatorLeft = rawLeft.clamp(0.0, maxLeft);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: bgColor,
                shape: RoundedRectangleBorder(
                    side: hIsOutlined(context)
                      ? BorderSide(color: borderColor)
                      : BorderSide.none,
                  borderRadius: radius,
                ),
                elevation: widget.elevation,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: widget.padding,
                  child: SizedBox(
                    height: widget.height,
                    width: contentWidth,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // The moving highlight behind the selected item.
                        // Positioned in terms of itemWidth so it always
                        // lines up with whichever item is selected, then
                        // animates between them. Clamped so it can't poke
                        // past the row's edges (and get clipped) on the
                        // first/last item.
                        AnimatedPositioned(
                          duration: widget.duration,
                          curve: widget.curve,
                          left: indicatorLeft,
                          top: (widget.height - widget.indicatorHeight) / 2,
                          width: indicatorWidth,
                          height: widget.indicatorHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  widget.indicatorColor ??
                                  selectedColor.withValues(alpha: 0.12),
                              borderRadius: radius,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(widget.items.length, (index) {
                            final item = widget.items[index];
                            final selected = index == widget.currentIndex;
                            final color = selected
                                ? selectedColor
                                : unselectedColor;

                            return SizedBox(
                              width: itemWidth,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: (_) =>
                                    setState(() => _pressedIndex = index),
                                onTapUp: (_) =>
                                    setState(() => _pressedIndex = null),
                                onTapCancel: () =>
                                    setState(() => _pressedIndex = null),
                                onTap: () => widget.onTap(index),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                  ),
                                  child: AnimatedScale(
                                    scale: _pressedIndex == index ? 0.90 : 1.0,
                                    duration: const Duration(milliseconds: 100),
                                    curve: Curves.easeOut,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          selected && item.selectedIcon != null
                                              ? item.selectedIcon
                                              : item.icon,
                                          key: ValueKey('$index-$selected'),
                                          size: widget.iconSize,
                                          color: color,
                                          fill: selected ? 1.0 : 0.0,
                                        ),
                                        if (widget.showLabels) ...[
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: AnimatedDefaultTextStyle(
                                              duration: widget.duration,
                                              style:
                                                  (widget.labelStyle ??
                                                          const TextStyle(
                                                            fontSize: 12,
                                                          ))
                                                      .copyWith(
                                                        color: color,
                                                        fontWeight: selected
                                                            ? FontWeight.w600
                                                            : FontWeight.w400,
                                                      ),
                                              child: Text(
                                                item.label,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
