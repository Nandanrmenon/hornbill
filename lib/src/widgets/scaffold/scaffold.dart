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

class HornbillScaffold extends StatefulWidget {
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
  final bool floating; // whether the app bar is floating (default: false)

  const HornbillScaffold({
    super.key,
    this.appBar,
    required this.slivers,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.sidebar,
    this.pinned = false,
    this.floating = true,
  });

  @override
  State<HornbillScaffold> createState() => _HornbillScaffoldState();
}

class _HornbillScaffoldState extends State<HornbillScaffold> {
  bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600; // Adjust the threshold as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      drawer: widget.drawer,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Row(
        children: [
          if (isDesktop(context) && widget.sidebar != null) widget.sidebar!,
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (widget.appBar != null)
                  SliverPersistentHeader(
                    pinned: widget.pinned,
                    floating: widget.floating,
                    delegate: _SliverPreferredSizeHeaderDelegate(
                      widget.appBar!,
                    ),
                  ),
                ...widget.slivers,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
