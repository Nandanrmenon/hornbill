import 'package:flutter/rendering.dart';
import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_ui/material_ui.dart';

class HScaffold extends StatefulWidget {
  /// The top app bar, as a *sliver* widget — typically an [HAppBar]. It's
  /// placed directly into the [CustomScrollView]'s `slivers` list, so it
  /// must build down to a real sliver (e.g. [SliverAppBar]). Pinned/floating
  /// behavior now lives on the app bar widget itself (e.g. `HAppBar.pinned`)
  /// rather than here. Pass null for no app bar.
  final Widget? appBar;
  final List<Widget> slivers; // body content as slivers
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? scaffoldBackground;
  final Color? bodyBackground; // optional background for the body slivers
  final Widget? sidebar; // optional sidebar widget

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
    this.scaffoldBackground,
    this.bodyBackground,
    this.sidebar,
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

  Color get _scaffoldBackgroundColor =>
      widget.scaffoldBackground ??
      Theme.of(context).colorScheme.surfaceContainerLow;
  Color get bodyBackground =>
      widget.bodyBackground ??
      Theme.of(context).colorScheme.surfaceContainerLowest;

  @override
  Widget build(BuildContext context) {
    final bottomBar = widget.bottomNavigationBar;

    return Scaffold(
      backgroundColor: _scaffoldBackgroundColor,
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
                  if (widget.appBar != null) widget.appBar!,
                  DecoratedSliver(
                    decoration: BoxDecoration(
                      // color:
                      //     widget.bodyBackground ??
                      //     Theme.of(context).colorScheme.surfaceContainer,
                      color: bodyBackground,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(kBorderRadius),
                        topRight: Radius.circular(kBorderRadius),
                      ),
                    ),
                    sliver: SliverMainAxisGroup(slivers: widget.slivers),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
