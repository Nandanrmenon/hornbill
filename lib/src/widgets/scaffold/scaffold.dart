import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Wraps any [PreferredSizeWidget] (e.g. [HAppBar]) so it can be used as a
/// sliver inside a [CustomScrollView]. Pinned by default, so it behaves
/// like a normal AppBar that stays fixed to the top while the body scrolls
/// underneath it.
class _SliverPreferredSizeHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget child;
  const _SliverPreferredSizeHeaderDelegate(this.child);
  @override
  double get minExtent => child.preferredSize.height;
  @override
  double get maxExtent => child.preferredSize.height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Material elevation/shadow only kicks in once content has actually
    // scrolled under the header.
    return Material(
      elevation: overlapsContent ? 2 : 0,
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _SliverPreferredSizeHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class HScaffold extends StatefulWidget {
  /// The top app bar. Must be a [PreferredSizeWidget] (e.g. [HAppBar]
  /// or a plain [AppBar]) — it's automatically wrapped as a pinned
  /// sliver header. Pass null for no app bar.
  final PreferredSizeWidget? appBar;
  final List<Widget> slivers; // body content as slivers
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final Widget? sidebar; // optional sidebar widget
  final bool pinned; // whether the app bar is pinned (default: true)
  final bool
  isFloatingAppBar; // whether the app bar is floating (default: false)

  /// When true (default) and [bottomNavigationBar] is set, the bar slides
  /// out of view when the user scrolls down and slides back in when they
  /// scroll up — meant for a floating bar like [HFloatingNavigationBar].
  /// Set to false to keep the bar always visible.
  final bool hideBottomBarOnScroll;

  const HScaffold({
    super.key,
    this.appBar,
    required this.slivers,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.sidebar,
    this.pinned = false,
    this.isFloatingAppBar = true,
    this.hideBottomBarOnScroll = true,
  });

  @override
  State<HScaffold> createState() => _HScaffoldState();
}

class _HScaffoldState extends State<HScaffold> {
  bool _bottomBarVisible = true;

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

  @override
  Widget build(BuildContext context) {
    final bottomBar = widget.bottomNavigationBar;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      drawer: widget.drawer,
      floatingActionButton: widget.floatingActionButton,
      extendBody: true,
      bottomNavigationBar: bottomBar == null
          ? null
          : AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              offset: _bottomBarVisible ? Offset.zero : const Offset(0, 1.2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _bottomBarVisible ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_bottomBarVisible,
                  child: bottomBar,
                ),
              ),
            ),
      body: Row(
        children: [
          if (isDesktop(context) && widget.sidebar != null) widget.sidebar!,
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: _handleScrollNotification,
              child: CustomScrollView(
                slivers: [
                  if (widget.appBar != null)
                    SliverPersistentHeader(
                      pinned: widget.pinned,
                      floating: widget.isFloatingAppBar,
                      delegate: _SliverPreferredSizeHeaderDelegate(
                        widget.appBar!,
                      ),
                    ),
                  ...widget.slivers,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
