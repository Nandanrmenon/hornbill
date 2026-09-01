import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// A vertical navigation sidebar that can collapse into a narrow,
/// icon-only rail (similar to [NavigationRail]) via a toggle button
/// built into the header.
///
/// Wrap a list of [HSideBarItem]s (or any widgets) as [items].
/// Use [selectedIndex] + [onItemSelected] if you want HSideBar to manage
/// highlighting for you, or manage the `selected` flag on each
/// [HSideBarItem] yourself.
class HSideBar extends StatefulWidget {
  const HSideBar({
    super.key,
    required this.items,
    this.width = 240,
    this.collapsedWidth = 72,
    this.backgroundColor,
    this.header,
    this.footer,
    this.selectedIndex,
    this.onItemSelected,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.headerTextStyle,
    this.collapsible = true,
    this.initiallyCollapsed = false,
    this.onCollapsedChanged,
  });

  /// The items shown in the sidebar. Typically a list of [HSideBarItem].
  final List<Widget> items;

  /// Width of the sidebar when expanded.
  final double width;

  /// Width of the sidebar when collapsed into a rail.
  final double collapsedWidth;

  /// Background color of the sidebar. Defaults to the theme's surface color.
  final Color? backgroundColor;

  /// Optional widget shown above the items (e.g. a logo or title).
  /// Hidden while collapsed; only the toggle button remains visible.
  final Widget? header;

  /// Optional widget shown below the items (e.g. a user profile / logout).
  /// If this is an [HSideBarAccountTile], HSideBar automatically feeds it
  /// the current collapsed state so it renders consistently with the
  /// rest of the sidebar.
  final Widget? footer;

  /// Index of the currently selected item, if HSideBar should manage
  /// highlighting for you.
  final int? selectedIndex;

  /// Called with the tapped index when an [HSideBarItem] inside [items]
  /// is tapped, provided that item didn't already define its own [onTap].
  /// Not called for taps on nested [HSideBarItem.children] — give those
  /// their own [HSideBarItem.onTap] instead.
  final ValueChanged<int>? onItemSelected;

  /// Padding around the list of items.
  final EdgeInsetsGeometry padding;

  /// Text style applied to [header]. Any [Text] widgets inside header
  /// inherit this automatically, so callers don't need to style it
  /// themselves. Defaults to the theme's titleMedium, bolded.
  final TextStyle? headerTextStyle;

  /// Whether to show the collapse/expand toggle button in the header.
  /// Set to false if you want to drive collapsing externally instead.
  final bool collapsible;

  /// Whether the sidebar starts collapsed.
  final bool initiallyCollapsed;

  /// Called whenever the collapsed state changes (e.g. to persist the
  /// user's preference).
  final ValueChanged<bool>? onCollapsedChanged;

  @override
  State<HSideBar> createState() => _HSideBarState();
}

class _HSideBarState extends State<HSideBar> {
  late bool _collapsed = widget.initiallyCollapsed;

  void _toggleCollapsed() {
    setState(() => _collapsed = !_collapsed);
    widget.onCollapsedChanged?.call(_collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: widget.backgroundColor ?? theme.colorScheme.surfaceContainerLow,
      shape: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: _collapsed ? widget.collapsedWidth : widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(theme),
            Expanded(
              child: ListView.builder(
                padding: widget.padding,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];

                  // If it's an HSideBarItem, wire up selection/tap handling
                  // and collapsed state unless the item already customized
                  // those itself.
                  if (item is HSideBarItem) {
                    return HSideBarItem(
                      key: item.key,
                      icon: item.icon,
                      label: item.label,
                      trailing: _collapsed ? null : item.trailing,
                      selected: item.selected || widget.selectedIndex == index,
                      collapsed: _collapsed,
                      initiallyExpanded: item.initiallyExpanded,
                      onTap:
                          item.onTap ??
                          (item.children == null &&
                                  widget.onItemSelected != null
                              ? () => widget.onItemSelected!(index)
                              : null),
                      children: item.children,
                    );
                  }
                  return item;
                },
              ),
            ),
            if (widget.footer != null) const Divider(height: 1),
            ?_buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    if (widget.header == null && !widget.collapsible) {
      return const SizedBox.shrink();
    }

    final toggleButton = widget.collapsible
        ? IconButton(
            tooltip: _collapsed ? 'Expand' : 'Collapse',
            icon: Icon(
              _collapsed
                  ? Symbols.left_panel_close_rounded
                  : Symbols.left_panel_open_rounded,
            ),
            onPressed: _toggleCollapsed,
          )
        : null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: _collapsed
              ? Center(child: toggleButton)
              : Row(
                  children: [
                    if (widget.header != null)
                      Expanded(
                        child: DefaultTextStyle(
                          style:
                              widget.headerTextStyle ??
                              theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          child: widget.header!,
                        ),
                      ),
                    ?toggleButton,
                  ],
                ),
        ),
        if (widget.header != null || widget.collapsible)
          const Divider(height: 1),
      ],
    );
  }

  /// Returns [widget.footer], threading through the sidebar's collapsed
  /// state when the footer is an [HSideBarAccountTile] — mirrors how
  /// [HSideBarItem]s in [items] are re-wired above.
  Widget? _buildFooter() {
    final footer = widget.footer;
    if (footer == null) return null;

    if (footer is HSideBarAccountTile) {
      return HSideBarAccountTile(
        key: footer.key,
        title: footer.title,
        subtitle: footer.subtitle,
        avatar: footer.avatar,
        onLogout: footer.onLogout,
        accounts: footer.accounts,
        onAccountSelected: footer.onAccountSelected,
        onAddAccount: footer.onAddAccount,
        collapsed: _collapsed,
      );
    }

    return footer;
  }
}

/// A single navigation tile used inside an [HSideBar].
///
/// Give it [children] (a list of nested [HSideBarItem]s) to turn it into
/// an expandable group — tapping the row then toggles the nested list
/// open/closed instead of requiring [onTap]. [onTap] stays entirely
/// optional either way: a plain leaf item with no [onTap] and no
/// [children] simply renders as a non-interactive row (still useful for
/// e.g. read-only status rows), and a group item can define both
/// [onTap] *and* [children] if you want a tap to do something (like
/// navigate to an overview page) in addition to expanding.
///
/// When the parent [HSideBar] is collapsed into a rail, a group item has
/// nowhere to show its nested list inline, so instead it shows the
/// children in a floating popover on hover — same idea as VS Code's or
/// Chrome's collapsed-rail flyout menus.
class HSideBarItem extends StatefulWidget {
  const HSideBarItem({
    super.key,
    required this.label,
    this.icon,
    this.trailing,
    this.selected = false,
    this.onTap,
    this.selectedColor,
    this.selectedBackgroundColor,
    this.collapsed = false,
    this.children,
    this.initiallyExpanded = false,
  });

  /// The main label text for this item.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional trailing widget (e.g. a badge or chevron). Hidden while
  /// [collapsed], and ignored on group items — those get an expand/
  /// collapse chevron instead.
  final Widget? trailing;

  /// Whether this item is currently the active/selected route.
  final bool selected;

  /// Called when the item is tapped. Entirely optional: omit it for a
  /// non-interactive row, or for a group item where the tap should only
  /// expand/collapse [children].
  final VoidCallback? onTap;

  /// Color used for icon/text when [selected] is true.
  final Color? selectedColor;

  /// Background color when [selected] is true.
  final Color? selectedBackgroundColor;

  /// When true, renders as a centered icon-only tile (NavigationRail
  /// style) with the label available via a [Tooltip] instead of visible
  /// text. Normally set automatically by the parent [HSideBar]. Nested
  /// [children] are shown in a hover popover instead of inline while
  /// collapsed, since there's no room for them in the rail itself.
  final bool collapsed;

  /// Nested items shown beneath this one. Their presence turns this item
  /// into an expandable group: while the sidebar is expanded, tapping
  /// the row toggles them open/closed inline (in addition to calling
  /// [onTap], if given) and an animated chevron is shown automatically.
  /// While the sidebar is collapsed, they instead appear in a floating
  /// popover when the item is hovered.
  final List<HSideBarItem>? children;

  /// Whether a group item (one with [children]) starts expanded. Only
  /// relevant while the sidebar is not collapsed.
  final bool initiallyExpanded;

  @override
  State<HSideBarItem> createState() => _HSideBarItemState();
}

class _HSideBarItemState extends State<HSideBarItem> {
  late bool _expanded = widget.initiallyExpanded;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _flyoutEntry;
  bool _hoveringTrigger = false;
  bool _hoveringFlyout = false;

  bool _pressed = false;
  bool _hovered = false;

  bool get _isGroup => widget.children != null && widget.children!.isNotEmpty;

  void _handleTap() {
    if (_isGroup && !widget.collapsed) {
      setState(() => _expanded = !_expanded);
    }
    widget.onTap?.call();
  }

  void _handleTriggerEnter(PointerEnterEvent _) {
    _hoveringTrigger = true;
    _showFlyout();
  }

  void _handleTriggerExit(PointerExitEvent _) {
    _hoveringTrigger = false;
    _scheduleFlyoutHide();
  }

  void _handleFlyoutEnter(PointerEnterEvent _) {
    _hoveringFlyout = true;
  }

  void _handleFlyoutExit(PointerExitEvent _) {
    _hoveringFlyout = false;
    _scheduleFlyoutHide();
  }

  void _scheduleFlyoutHide() {
    // Small delay so the pointer has time to travel from the trigger icon
    // into the popover itself without it disappearing first.
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || _hoveringTrigger || _hoveringFlyout) return;
      _removeFlyout();
    });
  }

  void _showFlyout() {
    if (_flyoutEntry != null || !mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    final triggerWidth = renderBox?.size.width ?? 72;
    final theme = Theme.of(context);

    _flyoutEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 220,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(triggerWidth + 4, 0),
            child: MouseRegion(
              onEnter: _handleFlyoutEnter,
              onExit: _handleFlyoutExit,
              child: Material(
                borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                color: theme.colorScheme.surfaceContainerLow,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          widget.label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...widget.children!,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_flyoutEntry!);
  }

  void _removeFlyout() {
    _flyoutEntry?.remove();
    _flyoutEntry = null;
  }

  void _setPressed(bool value) {
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    setState(() => _hovered = value);
  }

  @override
  void didUpdateWidget(covariant HSideBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The sidebar expanded (or this item stopped being a group) while a
    // flyout was showing — it no longer applies, so drop it.
    if (_flyoutEntry != null && (!widget.collapsed || !_isGroup)) {
      _hoveringTrigger = false;
      _hoveringFlyout = false;
      _removeFlyout();
    }
  }

  @override
  void dispose() {
    _removeFlyout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.selectedColor ?? theme.colorScheme.primary;
    final activeBg =
        widget.selectedBackgroundColor ??
        theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
    final collapsed = widget.collapsed;
    final canTap = widget.onTap != null || (_isGroup && !collapsed);

    // Background: selected wins; otherwise a subtle surface tint on
    // hover so tappable rows visibly react before the press animation
    // kicks in — without this, nothing changes until the user is
    // already pressing down, which reads as "not clickable".
    final Color backgroundColor;
    if (widget.selected) {
      backgroundColor = activeBg;
    } else if (canTap && _hovered) {
      backgroundColor = theme.colorScheme.onSurface.withValues(alpha: 0.06);
    } else {
      backgroundColor = Colors.transparent;
    }

    final trailingWidget = collapsed
        ? null
        : _isGroup
        ? AnimatedRotation(
            turns: _expanded ? 0.25 : 0,
            duration: const Duration(milliseconds: 150),
            child: const Icon(Symbols.chevron_right_rounded, size: 16),
          )
        : widget.trailing;

    final tile = MouseRegion(
      cursor: canTap ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: canTap ? (_) => _setHovered(true) : null,
      onExit: canTap ? (_) => _setHovered(false) : null,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: canTap ? _handleTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: collapsed
                  ? const EdgeInsets.symmetric(vertical: 14)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: collapsed
                  ? Center(
                      child: widget.icon != null
                          ? Icon(
                              widget.icon,
                              size: 22,
                              fill: widget.selected ? 1 : 0,
                              color: widget.selected
                                  ? activeColor
                                  : theme.iconTheme.color?.withValues(
                                      alpha: 0.7,
                                    ),
                            )
                          : Text(
                              widget.label.isNotEmpty
                                  ? widget.label[0].toUpperCase()
                                  : '',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: widget.selected
                                    ? activeColor
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    )
                  : Row(
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 20,
                            fill: widget.selected ? 1 : 0,
                            color: widget.selected
                                ? activeColor
                                : theme.iconTheme.color?.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child:
                              Text(
                                widget.label,
                                maxLines: 1,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: widget.selected
                                      ? activeColor
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: widget.selected
                                      ? FontWeight.w500
                                      : FontWeight.w300,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ).animate().slide(
                                duration: const Duration(milliseconds: 200),
                                begin: const Offset(-0.1, 0),
                                end: const Offset(0, 0),
                              ),
                        ),
                        ?trailingWidget,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    final padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: tile,
    );

    // Collapsed group item: no room to show children inline, so wrap the
    // trigger in a CompositedTransformTarget + MouseRegion that shows a
    // floating popover with the children on hover, instead of a Tooltip
    // (the popover's own header already shows the label).
    if (collapsed && _isGroup) {
      return CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          onEnter: _handleTriggerEnter,
          onExit: _handleTriggerExit,
          child: padded,
        ),
      );
    }

    final row = collapsed
        ? Tooltip(message: widget.label, child: padded)
        : padded;

    if (!_isGroup || collapsed) {
      return row;
    }

    // Expanded group item: children appear inline, indented, toggled by
    // tapping the row.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: !_expanded
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.children!,
                  ),
                ),
        ),
      ],
    );
  }
}

/// One entry in the "switch account" section of an
/// [HSideBarAccountTile]'s menu.
class HSideBarAccount {
  const HSideBarAccount({required this.title, this.subtitle, this.avatar});

  /// Display name for this account.
  final String title;

  /// Optional email / subtitle shown under [title] in the menu.
  final String? subtitle;

  /// Optional avatar widget (e.g. a [CircleAvatar]). Falls back to the
  /// first letter of [title] on a plain circle when omitted.
  final Widget? avatar;
}

/// A footer tile for an [HSideBar] that shows the signed-in account and
/// opens a menu with "switch account" and "log out" actions.
///
/// Pass this directly as [HSideBar.footer] — [HSideBar] detects it and
/// automatically feeds it the sidebar's collapsed state, so it shows a
/// full name/email row while expanded and shrinks to a single centered
/// avatar (tap to open the same menu) while collapsed, matching how
/// [HSideBarItem] behaves inside [items].
///
/// ```dart
/// HSideBar(
///   items: [...],
///   footer: HSideBarAccountTile(
///     title: 'Ada Lovelace',
///     subtitle: 'ada@example.com',
///     onLogout: () => authService.logOut(),
///     accounts: const [
///       HSideBarAccount(title: 'Ada Lovelace', subtitle: 'ada@example.com'),
///       HSideBarAccount(title: 'Grace Hopper', subtitle: 'grace@example.com'),
///     ],
///     onAccountSelected: (account) => authService.switchTo(account),
///     onAddAccount: () => authService.addAccount(),
///   ),
/// )
/// ```
class HSideBarAccountTile extends StatefulWidget {
  const HSideBarAccountTile({
    super.key,
    required this.title,
    this.subtitle,
    this.avatar,
    this.onLogout,
    this.accounts,
    this.onAccountSelected,
    this.onAddAccount,
    this.collapsed = false,
  });

  /// Display name of the currently signed-in account.
  final String title;

  /// Email (or other subtitle) of the currently signed-in account.
  final String? subtitle;

  /// Optional avatar widget (e.g. a [CircleAvatar] with a network
  /// image). Falls back to the first letter of [title] on a colored
  /// circle when omitted.
  final Widget? avatar;

  /// Called when "Log out" is selected from the menu. The menu item is
  /// hidden entirely when this is null.
  final VoidCallback? onLogout;

  /// Other accounts the user can switch to. Any entry whose [title]
  /// matches [title] is treated as the current account and skipped, so
  /// you can pass the full account list without filtering it yourself.
  /// When empty or null, the "switch account" section is hidden.
  final List<HSideBarAccount>? accounts;

  /// Called with the tapped [HSideBarAccount] when the user picks one
  /// from [accounts] in the menu.
  final ValueChanged<HSideBarAccount>? onAccountSelected;

  /// Called when "Add account" is selected. The menu item is hidden
  /// entirely when this is null.
  final VoidCallback? onAddAccount;

  /// Whether to render as a centered, avatar-only row. Normally set
  /// automatically by the parent [HSideBar] when this widget is passed
  /// as its [HSideBar.footer].
  final bool collapsed;

  @override
  State<HSideBarAccountTile> createState() => _HSideBarAccountTileState();
}

class _HSideBarAccountTileState extends State<HSideBarAccountTile> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) => setState(() => _pressed = value);
  void _setHovered(bool value) => setState(() => _hovered = value);

  Widget _buildAvatar(ThemeData theme, {double size = 32}) {
    if (widget.avatar != null) return widget.avatar!;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        widget.title.isNotEmpty ? widget.title[0].toUpperCase() : '?',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    final theme = Theme.of(context);
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final renderBox = context.findRenderObject() as RenderBox;

    // Anchor the menu to the tile itself rather than the tap point, so
    // it opens consistently whether triggered by mouse or keyboard/touch.
    final topLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final bottomRight = renderBox.localToGlobal(
      renderBox.size.bottomRight(Offset.zero),
      ancestor: overlayBox,
    );
    final position = RelativeRect.fromLTRB(
      topLeft.dx,
      bottomRight.dy + 4,
      overlayBox.size.width - bottomRight.dx,
      0,
    );

    final accounts = widget.accounts ?? const <HSideBarAccount>[];
    final otherAccounts = accounts
        .where((account) => account.title != widget.title)
        .toList();

    showMenu<void>(
      context: context,
      position: position,
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 280),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      color: theme.colorScheme.surfaceContainerLowest,
      items: [
        PopupMenuItem<void>(
          enabled: false,
          child: Row(
            children: [
              _buildAvatar(theme, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (otherAccounts.isNotEmpty) ...[
          const PopupMenuDivider(),
          ...otherAccounts.map(
            (account) => PopupMenuItem<void>(
              onTap: () => widget.onAccountSelected?.call(account),
              child: Row(
                children: [
                  account.avatar ??
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        child: Text(
                          account.title.isNotEmpty
                              ? account.title[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      account.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (widget.onAddAccount != null) ...[
          const PopupMenuDivider(),
          PopupMenuItem<void>(
            onTap: widget.onAddAccount,
            child: const Row(
              children: [
                Icon(Symbols.add_rounded, size: 18),
                SizedBox(width: 10),
                Text('Add account'),
              ],
            ),
          ),
        ],
        if (widget.onLogout != null) ...[
          const PopupMenuDivider(),
          PopupMenuItem<void>(
            onTap: widget.onLogout,
            child: Row(
              children: [
                Icon(
                  Symbols.logout_rounded,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 10),
                Text(
                  'Log out',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collapsed = widget.collapsed;

    final backgroundColor = _hovered
        ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
        : Colors.transparent;

    final tile = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: () => _openMenu(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: Padding(
              padding: collapsed
                  ? const EdgeInsets.symmetric(vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: collapsed
                  ? Center(child: _buildAvatar(theme))
                  : Row(
                      children: [
                        _buildAvatar(theme),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (widget.subtitle != null)
                                Text(
                                  widget.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Symbols.unfold_more_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    final padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: tile,
    );

    return collapsed ? Tooltip(message: widget.title, child: padded) : padded;
  }
}
