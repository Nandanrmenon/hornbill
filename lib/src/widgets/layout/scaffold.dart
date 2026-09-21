import 'package:flutter/rendering.dart';
import 'package:hornbill/src/helpers/constants.dart';
// Only kept for `Theme` / `Theme.of(context).colorScheme` — no other
// material_ui or Material widgets (Scaffold, etc.) are used here anymore.
// `Material`/`MaterialType.transparency` here is just plumbing — it gives
// any Material-family descendant (InkWell, TextField, Card, buttons, etc.)
// the ambient `Material` ancestor they look up via `Material.of(context)`,
// without adding any color/elevation of its own. `Scaffold` used to supply
// this for free; we do it explicitly now that Scaffold is gone.
import 'package:material_ui/material_ui.dart';

class HScaffold extends StatefulWidget {
  /// The top app bar, as a *sliver* widget — typically an [HAppBar]. It's
  /// placed directly into the [CustomScrollView]'s `slivers` list, so it
  /// must build down to a real sliver (e.g. [SliverAppBar]). Pinned/floating
  /// behavior now lives on the app bar widget itself (e.g. `HAppBar.pinned`)
  /// rather than here. Pass null for no app bar.
  final Widget? appBar;

  /// Convenience for the common case: a single, non-sliver body widget.
  /// Rendered as a plain widget filling the remaining space — no
  /// [CustomScrollView] or sliver machinery involved. If you want it to
  /// scroll, wrap it yourself (e.g. in a [ListView] or
  /// [SingleChildScrollView]); HScaffold won't impose scrolling or query
  /// its intrinsic size. Note: because of this, if [appBar] is also set,
  /// it renders as a static header rather than collapsing/scrolling away —
  /// use [slivers] instead if you need that scroll-linked behavior.
  final Widget? body;

  /// Body content as slivers, for when you need more than one. Prefer
  /// [body] for the single-child case.
  final List<Widget>? slivers;

  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? scaffoldBackground;
  final Color? bodyBackground; // optional background for the body slivers
  final Widget? sidebar; // optional sidebar widget
  final bool extendBody; // whether the body should extend behind the bottom bar

  /// When true (default) and [bottomNavigationBar] is set, the bar slides
  /// out of view when the user scrolls down and slides back in when they
  /// scroll up — meant for a floating bar like [HFloatingNavigationBar].
  /// Set to false to keep the bar always visible.
  final bool hideBottomBarOnScroll;

  const HScaffold({
    super.key,
    this.appBar,
    this.body,
    this.slivers,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.scaffoldBackground,
    this.bodyBackground,
    this.sidebar,
    this.hideBottomBarOnScroll = true,
    this.extendBody = true,
  }) : assert(
         body != null || slivers != null,
         'HScaffold: provide either `body` or `slivers`.',
       ),
       assert(
         body == null || slivers == null,
         'HScaffold: provide only one of `body` or `slivers`, not both — '
         'they both populate the same body sliver list.',
       );

  @override
  State<HScaffold> createState() => HScaffoldState();
}

/// Public so callers can open/close the drawer via a
/// `GlobalKey<HScaffoldState>`, e.g.:
/// ```dart
/// final scaffoldKey = GlobalKey<HScaffoldState>();
/// HScaffold(key: scaffoldKey, drawer: ..., ...);
/// scaffoldKey.currentState?.openDrawer();
/// ```
class HScaffoldState extends State<HScaffold> {
  static const _drawerWidth = 304.0;

  bool _bottomBarVisible = true;
  bool _drawerOpen = false;
  double _bottomBarHeight = 0;

  void openDrawer() {
    if (widget.drawer == null) return;
    setState(() => _drawerOpen = true);
  }

  void closeDrawer() {
    if (_drawerOpen) setState(() => _drawerOpen = false);
  }

  void toggleDrawer() => _drawerOpen ? closeDrawer() : openDrawer();

  bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600; // Adjust the threshold as needed
  }

  bool _handleScrollNotification(UserScrollNotification notification) {
    if (!widget.hideBottomBarOnScroll || widget.bottomNavigationBar == null) {
      return false;
    }
    // Ignore horizontal scrolling (e.g. a nested horizontal list) so it
    // doesn't fight with the vertical body scroll.
    if (notification.metrics.axis != Axis.vertical) return false;

    switch (notification.direction) {
      case ScrollDirection.forward: // scrolling up -> reveal the bar
        if (!_bottomBarVisible) setState(() => _bottomBarVisible = true);
        break;
      case ScrollDirection.reverse: // scrolling down -> hide the bar
        if (_bottomBarVisible) setState(() => _bottomBarVisible = false);
        break;
      case ScrollDirection.idle:
        break;
    }
    return false;
  }

  Color get _scaffoldBackgroundColor =>
      widget.scaffoldBackground ??
      Theme.of(context).colorScheme.surfaceContainerLow;
  Color get _bodyBackgroundColor =>
      widget.bodyBackground ??
      Theme.of(context).colorScheme.surfaceContainerLowest;

  @override
  Widget build(BuildContext context) {
    final bottomBar = widget.bottomNavigationBar;

    final Widget bodyArea;
    if (widget.slivers != null) {
      // Full sliver path: appBar collapses/scrolls with body content.
      bodyArea = CustomScrollView(
        slivers: [
          if (widget.appBar != null) widget.appBar!,
          DecoratedSliver(
            decoration: BoxDecoration(
              color: _bodyBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(kBorderRadius),
                topRight: Radius.circular(kBorderRadius),
              ),
            ),
            sliver: SliverMainAxisGroup(slivers: widget.slivers!),
          ),
        ],
      );
    } else {
      // Plain body path: no sliver/CustomScrollView machinery at all.
      // `body` is a normal widget filling the remaining space via
      // Expanded — if the caller wants it to scroll, that's on them
      // (wrap it in a ListView/SingleChildScrollView themselves).
      // appBar, if present, gets its own tiny shrink-wrapped
      // CustomScrollView so it still renders (it's sliver-based), but it
      // can't collapse/scroll away since it's not sharing a viewport with
      // the body — it just sits as a static header.
      bodyArea = Column(
        children: [
          if (widget.appBar != null)
            CustomScrollView(shrinkWrap: true, slivers: [widget.appBar!]),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _bodyBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(kBorderRadius),
                  topRight: Radius.circular(kBorderRadius),
                ),
              ),
              child: widget.body!,
            ),
          ),
        ],
      );
    }

    Widget content = Row(
      children: [
        if (isDesktop(context) && widget.sidebar != null) widget.sidebar!,
        Expanded(
          child: NotificationListener<UserScrollNotification>(
            onNotification: _handleScrollNotification,
            child: bodyArea,
          ),
        ),
      ],
    );

    // Scaffold used to reserve space for the bottom bar automatically when
    // extendBody was false; we do it by hand using the measured height.
    if (!widget.extendBody && bottomBar != null) {
      content = Padding(
        padding: EdgeInsets.only(bottom: _bottomBarHeight),
        child: content,
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: _scaffoldBackgroundColor,
        child: Stack(
          children: [
            Positioned.fill(child: content),
            if (bottomBar != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _MeasureSize(
                  onChange: (height) {
                    if (height != _bottomBarHeight) {
                      setState(() => _bottomBarHeight = height);
                    }
                  },
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    offset: _bottomBarVisible
                        ? Offset.zero
                        : const Offset(0, 1.2),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _bottomBarVisible ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !_bottomBarVisible,
                        child: SafeArea(top: false, child: bottomBar),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.floatingActionButton != null)
              Positioned(
                right: 16,
                bottom: 16 + (bottomBar != null ? _bottomBarHeight : 0),
                child: SafeArea(
                  top: false,
                  left: false,
                  right: false,
                  child: widget.floatingActionButton!,
                ),
              ),
            if (widget.drawer != null) ...[
              // Scrim — tap to close.
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_drawerOpen,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _drawerOpen ? 1 : 0,
                    child: GestureDetector(
                      onTap: closeDrawer,
                      child: const ColoredBox(color: Color(0x66000000)),
                    ),
                  ),
                ),
              ),
              // Panel.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                top: 0,
                bottom: 0,
                left: _drawerOpen ? 0 : -_drawerWidth,
                width: _drawerWidth,
                child: ColoredBox(
                  color: _scaffoldBackgroundColor,
                  child: SafeArea(child: widget.drawer!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reports the rendered height of [child] via [onChange] after every layout,
/// used to replicate what `Scaffold` did automatically for `extendBody`.
class _MeasureSize extends StatefulWidget {
  const _MeasureSize({required this.onChange, required this.child});

  final ValueChanged<double> onChange;
  final Widget child;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant _MeasureSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final size = _key.currentContext?.size;
    if (size != null) widget.onChange(size.height);
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _key, child: widget.child);
}
