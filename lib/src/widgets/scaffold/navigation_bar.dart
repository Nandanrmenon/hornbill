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

/// A minimal, flat bottom navigation bar with a thin animated underline
/// that slides beneath the selected item. No pill/background fill —
/// just icon + label color change and a sliding indicator line.
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
  final double iconSize;
  final double indicatorHeight;
  final double indicatorWidth;
  final TextStyle? labelStyle;
  final bool showLabels;
  final bool showTopBorder;

  final Duration duration;
  final Curve curve;

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
    this.iconSize = 24,
    this.indicatorHeight = 56,
    this.indicatorWidth = 72,
    this.labelStyle,
    this.showLabels = true,
    this.showTopBorder = true,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
  }) : assert(items.length >= 2, 'HNavigationBar needs at least 2 items');

  @override
  State<HNavigationBar> createState() => _HNavigationBarState();
}

class _HNavigationBarState extends State<HNavigationBar> {
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final bgColor = widget.backgroundColor ?? theme.surface;
    final selectedColor = widget.selectedColor ?? theme.primary;
    final unselectedColor = widget.unselectedColor ?? theme.onSurfaceVariant;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: bgColor,
        border: widget.showTopBorder
            ? Border(
                top: BorderSide(color: theme.surfaceContainerHigh, width: 1),
              )
            : null,
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final selected = index == widget.currentIndex;
                final color = selected ? selectedColor : unselectedColor;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => setState(() => _pressedIndex = index),
                    onTapUp: (_) => setState(() => _pressedIndex = null),
                    onTapCancel: () => setState(() => _pressedIndex = null),
                    onTap: () => widget.onTap(index),
                    child: AnimatedScale(
                      scale: _pressedIndex == index ? 0.90 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            AnimatedDefaultTextStyle(
                              duration: widget.duration,
                              style:
                                  (widget.labelStyle ??
                                          const TextStyle(fontSize: 12))
                                      .copyWith(
                                        color: color,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                              child: Text(
                                item.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

/// --- Example usage ---
///
/// class NavDemo extends StatefulWidget {
///   const NavDemo({super.key});
///   @override
///   State<NavDemo> createState() => _NavDemoState();
/// }
///
/// class _NavDemoState extends State<NavDemo> {
///   int _index = 0;
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Center(child: Text('Page $_index')),
///       bottomNavigationBar: HNavigationBar(
///         currentIndex: _index,
///         onTap: (i) => setState(() => _index = i),
///         items: const [
///           HNavigationBarItem(
///             icon: Icons.home_outlined,
///             selectedIcon: Icons.home,
///             label: 'Home',
///           ),
///           HNavigationBarItem(
///             icon: Icons.search,
///             label: 'Search',
///           ),
///           HNavigationBarItem(
///             icon: Icons.favorite_border,
///             selectedIcon: Icons.favorite,
///             label: 'Favorites',
///           ),
///           HNavigationBarItem(
///             icon: Icons.person_outline,
///             selectedIcon: Icons.person,
///             label: 'Profile',
///           ),
///         ],
///       ),
///     );
///   }
/// }
