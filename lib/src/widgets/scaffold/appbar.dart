import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Internal size variant. Set via constructors below.
enum _HAppBarVariant { large, medium, regular }

/// A custom [SliverAppBar]-based app bar with explicit size variants:
/// [HAppBar] (defaults to regular/single-line), [HAppBar.large], [HAppBar.medium],
/// and [HAppBar.regular].
class HAppBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? collapsedBackgroundColor;

  final bool pinned;
  final bool floating;
  final bool snap;
  final bool automaticallyImplyLeading;
  final bool centerTitleWhenCollapsed;

  final TextStyle? expandedTitleStyle;
  final TextStyle? collapsedTitleStyle;

  final double elevationOnCollapse;
  final EdgeInsetsGeometry titlePadding;

  final _HAppBarVariant _variant;

  /// Default regular single-line app bar style.
  const HAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.collapsedBackgroundColor,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.automaticallyImplyLeading = true,
    this.centerTitleWhenCollapsed = false,
    this.expandedTitleStyle,
    this.collapsedTitleStyle,
    this.elevationOnCollapse = 1,
    this.titlePadding = const EdgeInsets.fromLTRB(20, 0, 20, 14),
  }) : _variant = _HAppBarVariant.regular;

  const HAppBar.large({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.collapsedBackgroundColor,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.automaticallyImplyLeading = true,
    this.centerTitleWhenCollapsed = false,
    this.expandedTitleStyle,
    this.collapsedTitleStyle,
    this.elevationOnCollapse = 1,
    this.titlePadding = const EdgeInsets.fromLTRB(20, 0, 20, 16),
  }) : _variant = _HAppBarVariant.large;

  const HAppBar.medium({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.collapsedBackgroundColor,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.automaticallyImplyLeading = true,
    this.centerTitleWhenCollapsed = false,
    this.expandedTitleStyle,
    this.collapsedTitleStyle,
    this.elevationOnCollapse = 1,
    this.titlePadding = const EdgeInsets.fromLTRB(20, 0, 20, 14),
  }) : _variant = _HAppBarVariant.medium;

  const HAppBar.regular({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.collapsedBackgroundColor,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.automaticallyImplyLeading = true,
    this.centerTitleWhenCollapsed = false,
    this.expandedTitleStyle,
    this.collapsedTitleStyle,
    this.elevationOnCollapse = 1,
    this.titlePadding = const EdgeInsets.fromLTRB(20, 0, 20, 12),
  }) : _variant = _HAppBarVariant.regular;

  double get _expandedHeight {
    switch (_variant) {
      case _HAppBarVariant.large:
        return 152;
      case _HAppBarVariant.medium:
        return 112;
      case _HAppBarVariant.regular:
        return 64; // Regular matches toolbar standard height
    }
  }

  static const double _collapsedHeight = 64;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? theme.surface;
    final fg = foregroundColor ?? theme.onSurface;
    final collapsedBg = collapsedBackgroundColor ?? bg;

    final isRegular = _variant == _HAppBarVariant.regular;

    final defaultFontSize = switch (_variant) {
      _HAppBarVariant.large => 24.0,
      _HAppBarVariant.medium => 20.0,
      _HAppBarVariant.regular => 16.0,
    };

    final expandedStyle =
        expandedTitleStyle ??
        TextStyle(
          color: fg,
          fontSize: defaultFontSize,
          fontWeight: isRegular ? FontWeight.w500 : FontWeight.w600,
          // height: 1.15,
        );

    final collapsedStyle =
        collapsedTitleStyle ??
        TextStyle(color: fg, fontSize: 18, fontWeight: FontWeight.w500);

    final resolvedLeading =
        leading ??
        (automaticallyImplyLeading && Navigator.canPop(context)
            ? UnconstrainedBox(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: HIconButton.text(
                    icon: Symbols.arrow_back,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
              )
            : null);

    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      snap: snap,
      stretch: false,
      elevation: 0,
      scrolledUnderElevation: elevationOnCollapse,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      backgroundColor: collapsedBg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: fg,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: resolvedLeading,
      actions: actions,
      expandedHeight: _expandedHeight,
      collapsedHeight: _collapsedHeight,
      toolbarHeight: _collapsedHeight,
      // For Regular mode: render title directly on the single bar row
      title: isRegular
          ? Text(
              title,
              style: expandedStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : _CollapsedTitle(
              text: title,
              style: collapsedStyle,
              centered: centerTitleWhenCollapsed,
            ),
      centerTitle: isRegular
          ? centerTitleWhenCollapsed
          : centerTitleWhenCollapsed,
      // Flexible expanded space is only needed for medium & large collapsible headers
      flexibleSpace: isRegular
          ? FlexibleSpaceBar(background: Container(color: bg))
          : LayoutBuilder(
              builder: (context, constraints) {
                final settings = context
                    .dependOnInheritedWidgetOfExactType<
                      FlexibleSpaceBarSettings
                    >();
                final deltaExtent = _expandedHeight - _collapsedHeight;
                final t = settings == null || deltaExtent <= 0
                    ? 1.0
                    : (1.0 -
                              ((settings.currentExtent - settings.minExtent) /
                                      deltaExtent)
                                  .clamp(0.0, 1.0))
                          .clamp(0.0, 1.0);

                return Container(
                  color: bg,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: titlePadding,
                      child: Opacity(
                        opacity: (1.0 - t * 1.5).clamp(0.0, 1.0),
                        child: Text(
                          title,
                          style: expandedStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _CollapsedTitle extends StatelessWidget {
  final String text;
  final TextStyle style;
  final bool centered;

  const _CollapsedTitle({
    required this.text,
    required this.style,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    double opacity = 1.0;

    if (settings != null) {
      final deltaExtent = settings.maxExtent - settings.minExtent;
      final t = deltaExtent == 0
          ? 1.0
          : (1.0 -
                    ((settings.currentExtent - settings.minExtent) /
                            deltaExtent)
                        .clamp(0.0, 1.0))
                .clamp(0.0, 1.0);

      opacity = ((t - 0.80) / 0.20).clamp(0.0, 1.0);
    }

    return Opacity(
      opacity: opacity,
      child: Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
