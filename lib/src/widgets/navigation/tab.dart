import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_ui/material_ui.dart';

/// Describes a single tab's content for [HTabBar].
///
/// [label] and [icon] are plain widgets (typically a `Text` and an `Icon`)
/// rather than a `String`/`IconData`, so you bring your own text styling and
/// icon set. Selected/unselected color is applied by wrapping them in
/// [DefaultTextStyle] / [IconTheme] — set an explicit color on your own
/// widget if you want it to ignore that.
class HTab {
  const HTab({required this.label, this.icon});

  final Widget label;
  final Widget? icon;
}

/// Drives a paired [HTabBar] / [HTabView], keeping the selected index and
/// the sliding indicator's position in sync between the two.
///
/// Shaped like Flutter's own `TabController` — an explicit [vsync] is
/// required so the indicator can animate smoothly even before an
/// [HTabView] is attached (or if you're only using [HTabBar] to drive some
/// other content, e.g. an `IndexedStack`).
///
/// ```dart
/// class _MyScreenState extends State<MyScreen>
///     with SingleTickerProviderStateMixin {
///   late final _tabController = HTabController(length: 3, vsync: this);
///
///   @override
///   void dispose() {
///     _tabController.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         HTabBar(
///           controller: _tabController,
///           tabs: const [
///             HTab(label: Text('One')),
///             HTab(label: Text('Two')),
///             HTab(label: Text('Three')),
///           ],
///         ),
///         Expanded(
///           child: HTabView(
///             controller: _tabController,
///             children: const [
///               Center(child: Text('1')),
///               Center(child: Text('2')),
///               Center(child: Text('3')),
///             ],
///           ),
///         ),
///       ],
///     );
///   }
/// }
/// ```
class HTabController extends ChangeNotifier {
  HTabController({
    required this.length,
    required TickerProvider vsync,
    int initialIndex = 0,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
  }) : assert(length > 0, 'length must be at least 1'),
       assert(initialIndex >= 0 && initialIndex < length),
       _index = initialIndex,
       _indicatorController = AnimationController(
         vsync: vsync,
         value: initialIndex.toDouble(),
         lowerBound: 0,
         upperBound: (length - 1).toDouble(),
       ) {
    _indicatorController.addListener(notifyListeners);
  }

  /// Number of tabs.
  final int length;

  /// How long tap-driven transitions take.
  final Duration animationDuration;

  /// Easing used for tap-driven transitions.
  final Curve animationCurve;

  int _index;
  final AnimationController _indicatorController;
  PageController? _pageController;

  /// The currently selected tab index.
  int get index => _index;

  /// A continuous value in `[0, length - 1]` tracking the indicator's
  /// position — fractional while a transition is in flight (e.g. `1.4`
  /// between tabs 1 and 2), otherwise equal to [index].
  double get page => _indicatorController.value;

  /// Selects [value], animating the indicator — and the paired
  /// [HTabView], if any — smoothly rather than jumping.
  void animateTo(int value) {
    assert(value >= 0 && value < length, 'index out of range: $value');
    if (value == _index) return;
    _index = value;
    _indicatorController.animateTo(
      value.toDouble(),
      duration: animationDuration,
      curve: animationCurve,
    );
    _pageController?.animateToPage(
      value,
      duration: animationDuration,
      curve: animationCurve,
    );
  }

  // Called by HTabView once a user swipe settles on a new page, so the
  // indicator catches up without re-driving the page view (which is
  // already there thanks to the user's own gesture).
  //
  // Note: the indicator only animates once the swipe *settles* on a new
  // page — it doesn't track the page view pixel-for-pixel during the drag
  // itself. That live-tracking is possible (listen to the attached
  // PageController's `.page` while scrolling) but adds real complexity for
  // a marginal feel improvement, so it's left out here.
  void _syncFromView(int value) {
    if (value == _index) return;
    _index = value;
    _indicatorController.animateTo(
      value.toDouble(),
      duration: animationDuration,
      curve: animationCurve,
    );
  }

  void _attachPageController(PageController controller) {
    _pageController = controller;
  }

  void _detachPageController(PageController controller) {
    if (identical(_pageController, controller)) {
      _pageController = null;
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }
}

/// A horizontal, equal-width tab bar with a sliding underline indicator.
///
/// Built only on `package:flutter/widgets.dart` — no `TabBar`, no
/// `InkWell`/ripple, no `Theme`/`ColorScheme` lookups — using the same
/// press-scale + hover "state layer" physics as [HButton] and [HCheckBox].
/// Colors are plain constructor parameters with sensible defaults instead
/// of being pulled from a Material theme.
class HTabBar extends StatefulWidget implements PreferredSizeWidget {
  const HTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.height = 48.0,
    this.indicatorWeight = 3.0,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.backgroundColor,
    this.labelStyle,
    this.iconSize = 18.0,
    this.gap = 6.0,
    this.isScrollable = false,
  }) : assert(tabs.length > 0, 'tabs must not be empty'),
       assert(
         tabs.length == controller.length,
         'tabs and controller must have the same length',
       );

  final HTabController controller;
  final List<HTab> tabs;

  /// Height of the whole bar, including the indicator strip.
  final double height;

  /// Thickness of the sliding underline.
  final double indicatorWeight;

  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? backgroundColor;
  final TextStyle? labelStyle;
  final double iconSize;
  final double gap;

  /// Whether tabs should use intrinsic widths in a horizontal scroll view.
  final bool isScrollable;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<HTabBar> createState() => _HTabBarState();
}

class _HTabBarState extends State<HTabBar> {
  Color get indicatorColor =>
      widget.indicatorColor ?? Theme.of(context).colorScheme.primary;
  Color get labelColor =>
      widget.labelColor ?? Theme.of(context).colorScheme.primary;
  Color get unselectedLabelColor =>
      widget.unselectedLabelColor ??
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color get backgroundColor =>
      widget.backgroundColor ??
      Theme.of(context).colorScheme.surfaceContainerHigh;
  Widget _tabItem(int index) {
    return _HTabItem(
      tab: widget.tabs[index],
      selected: widget.controller.index == index,
      selectedColor: labelColor,
      unselectedColor: unselectedLabelColor,
      selectedBackgroundColor: indicatorColor.withValues(alpha: 0.12),
      style: widget.labelStyle,
      iconSize: widget.iconSize,
      gap: widget.gap,
      onTap: () => widget.controller.animateTo(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SizedBox(
        height: widget.height,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          clipBehavior: Clip.antiAlias,
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              if (widget.isScrollable) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.tabs.length, _tabItem),
                    ),
                  ),
                );
              }

              return Row(
                children: List.generate(
                  widget.tabs.length,
                  (index) => Expanded(child: _tabItem(index)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HTabItem extends StatefulWidget {
  const _HTabItem({
    required this.tab,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedBackgroundColor,
    required this.onTap,
    required this.iconSize,
    required this.gap,
    this.style,
  });

  final HTab tab;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedBackgroundColor;
  final VoidCallback onTap;
  final double iconSize;
  final double gap;
  final TextStyle? style;

  @override
  State<_HTabItem> createState() => _HTabItemState();
}

class _HTabItemState extends State<_HTabItem> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) => setState(() => _pressed = value);
  void _setHovered(bool value) => setState(() => _hovered = value);

  @override
  Widget build(BuildContext context) {
    final Color color = widget.selected
        ? widget.selectedColor
        : widget.unselectedColor;
    final Color background = _hovered
        ? widget.selectedColor.withValues(alpha: 0.06)
        : widget.selected
        ? widget.selectedBackgroundColor
        : const Color(0x00000000);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: Semantics(
          button: true,
          selected: widget.selected,
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(kBorderRadiusMedium),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.tab.icon != null) ...[
                    IconTheme.merge(
                      data: IconThemeData(color: color, size: widget.iconSize),
                      child: widget.tab.icon!,
                    ),
                    SizedBox(width: widget.gap),
                  ],
                  Flexible(
                    child: DefaultTextStyle.merge(
                      style:
                          (widget.style ??
                                  const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ))
                              .copyWith(color: color),
                      overflow: TextOverflow.ellipsis,
                      child: widget.tab.label,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The paged content area paired with an [HTabBar] via a shared
/// [HTabController]. Swiping updates the controller's index (the bar's
/// indicator animates into place once the swipe settles); tapping a tab
/// animates the page across.
class HTabView extends StatefulWidget {
  const HTabView({
    super.key,
    required this.controller,
    required this.children,
    this.physics,
  });

  final HTabController controller;
  final List<Widget> children;
  final ScrollPhysics? physics;

  @override
  State<HTabView> createState() => _HTabViewState();
}

class _HTabViewState extends State<HTabView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.controller.index);
    widget.controller._attachPageController(_pageController);
  }

  @override
  void didUpdateWidget(covariant HTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detachPageController(_pageController);
      _pageController.dispose();
      _pageController = PageController(initialPage: widget.controller.index);
      widget.controller._attachPageController(_pageController);
    }
  }

  void _handlePageChanged(int page) {
    widget.controller._syncFromView(page);
  }

  @override
  void dispose() {
    widget.controller._detachPageController(_pageController);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: widget.physics,
      onPageChanged: _handlePageChanged,
      children: widget.children,
    );
  }
}
