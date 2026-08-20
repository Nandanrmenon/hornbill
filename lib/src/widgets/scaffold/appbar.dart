import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_ui/material_ui.dart';

/// A single action item shown in [HAppBar].
///
/// On desktop these render as inline icon buttons (with optional tooltip).
/// On mobile they collapse into a single overflow (three-dot) popup menu,
/// rendered as icon + label rows.
class HAppBarAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  /// If false, this action is hidden entirely on mobile (neither shown
  /// inline nor in the popup menu). Defaults to true.
  final bool showOnMobile;

  const HAppBarAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.showOnMobile = true,
  });
}

/// A responsive AppBar.
///
/// Desktop / wide layout:
///   [back button?]  [title]      [search field (centered, if enabled)]      [actions...]
///
/// Mobile / narrow layout:
///   [drawer or back button?]  [title  -or-  search field (if search is active)]   [overflow menu]
///
/// Wrap this in a [Scaffold] as the `appBar`. If the Scaffold has a
/// `drawer`, the hamburger icon is shown automatically (standard Flutter
/// behavior) as long as you don't force [showBackButton] to true and don't
/// supply a custom [leading].
class HAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Title text. Ignored on mobile while the search field is active.
  final String title;

  /// Optional fully custom leading widget. If null, HAppBar decides
  /// automatically (back button / drawer icon / nothing).
  final Widget? leading;

  /// Force showing / hiding the back button. If null, HAppBar shows it
  /// automatically when `Navigator.canPop(context)` is true.
  final bool? showBackButton;

  /// Called when the back button is tapped. Defaults to
  /// `Navigator.of(context).pop()`.
  final VoidCallback? onBackPressed;

  /// Turns the search field on or off entirely.
  final bool searchEnabled;

  /// Whether the search field should be visible / active right now.
  /// Typically controlled by the parent via a state variable and a
  /// search icon inside [actions]. On mobile, when true, the search
  /// field replaces the title.
  final bool searchActive;

  /// Called whenever the search field toggles on/off (e.g. user taps the
  /// close icon inside the search field). Only fires if you don't manage
  /// [searchActive] some other way.
  final ValueChanged<bool>? onSearchActiveChanged;

  final String searchHint;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  /// Max width of the search field on desktop.
  final double desktopSearchWidth;

  /// Actions available on both layouts. On desktop they render inline.
  /// On mobile they collapse into a single overflow popup menu.
  final List<HAppBarAction> actions;

  /// Width breakpoint (in logical pixels) below which the mobile layout
  /// is used.
  final double mobileBreakpoint;

  final Color? backgroundColor;
  final double elevation;

  const HAppBar({
    super.key,
    required this.title,
    this.leading,
    this.showBackButton,
    this.onBackPressed,
    this.searchEnabled = false,
    this.searchActive = false,
    this.onSearchActiveChanged,
    this.searchHint = 'Search',
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.desktopSearchWidth = 350,
    this.actions = const [],
    this.mobileBreakpoint = 800,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<HAppBar> createState() => _HAppBarState();
}

class _HAppBarState extends State<HAppBar> {
  late TextEditingController _searchController;
  bool _ownsController = false;
  late bool _searchActive;

  @override
  void initState() {
    super.initState();
    _searchActive = widget.searchActive;
    if (widget.searchController != null) {
      _searchController = widget.searchController!;
    } else {
      _searchController = TextEditingController();
      _ownsController = true;
    }
  }

  @override
  void didUpdateWidget(covariant HAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchActive != oldWidget.searchActive) {
      _searchActive = widget.searchActive;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _searchController.dispose();
    }
    super.dispose();
  }

  void _setSearchActive(bool value) {
    setState(() => _searchActive = value);
    widget.onSearchActiveChanged?.call(value);
    if (!value) {
      _searchController.clear();
      widget.onSearchChanged?.call('');
    }
  }

  bool get _canPop {
    return ModalRoute.of(context)?.canPop ?? Navigator.of(context).canPop();
  }

  Widget? _buildLeading(BuildContext context, {required bool isMobile}) {
    if (widget.leading != null) return widget.leading;

    final wantsBack = widget.showBackButton ?? _canPop;

    // Mobile with active search: show a close/back icon that exits search.
    if (isMobile && widget.searchEnabled && _searchActive) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Close search',
        onPressed: () => _setSearchActive(false),
      );
    }

    if (wantsBack) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed:
            widget.onBackPressed ??
            () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
      );
    }

    // No explicit leading, no back button requested: return null so
    // AppBar can auto-imply the drawer (hamburger) icon if present.
    return null;
  }

  Widget _buildSearchField({required double? width}) {
    final field = TextField(
      controller: _searchController,
      autofocus: false,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.searchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearchChanged?.call('');
                  setState(() {});
                },
              ),
        isDense: true,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusRounded),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (v) {
        widget.onSearchChanged?.call(v);
        setState(() {}); // refresh suffix clear icon
      },
      onSubmitted: widget.onSearchSubmitted,
    );

    if (width == null) return field;
    return SizedBox(width: width, child: field);
  }

  Widget _buildDesktopTitleArea() {
    return Text(
      widget.title,
      style: const TextStyle(fontWeight: FontWeight.w500),
      overflow: TextOverflow.ellipsis,
    );
  }

  List<Widget> _buildDesktopActions() {
    return widget.actions
        .map(
          (a) => IconButton(
            icon: Icon(a.icon),
            tooltip: a.label,
            onPressed: a.onPressed,
          ),
        )
        .toList();
  }

  Widget? _buildMobileOverflowMenu() {
    final items = widget.actions.where((a) => a.showOnMobile).toList();
    if (items.isEmpty) return null;

    return PopupMenuButton<HAppBarAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More',
      onSelected: (action) => action.onPressed(),
      itemBuilder: (context) => items
          .map(
            (a) => PopupMenuItem<HAppBarAction>(
              value: a,
              child: Row(
                children: [
                  Icon(a.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(a.label),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < widget.mobileBreakpoint;
        return isMobile ? _buildMobile(context) : _buildDesktop(context);
      },
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final leading = _buildLeading(context, isMobile: false);

    return AppBar(
      backgroundColor:
          widget.backgroundColor ??
          Theme.of(context).colorScheme.surfaceContainerLow,
      shape: Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      elevation: widget.elevation,
      automaticallyImplyLeading: false,
      leading: leading,
      leadingWidth: leading == null ? 0 : null,
      titleSpacing: leading == null ? NavigationToolbar.kMiddleSpacing : 0,
      title: Row(
        children: [
          Flexible(child: _buildDesktopTitleArea()),
          if (widget.searchEnabled) ...[
            const Spacer(),
            _buildSearchField(width: widget.desktopSearchWidth),
            const Spacer(),
          ] else
            const Spacer(),
        ],
      ),
      actions: _buildDesktopActions(),
    );
  }

  Widget _buildMobile(BuildContext context) {
    final leading = _buildLeading(context, isMobile: true);
    final showingSearch = widget.searchEnabled && _searchActive;

    return AppBar(
      backgroundColor:
          widget.backgroundColor ??
          Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: widget.elevation,
      shape: Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      // Leave auto-imply on when we're not overriding leading, so the
      // Scaffold's drawer icon still appears when relevant.
      automaticallyImplyLeading: leading == null,
      leading: leading,
      title: showingSearch
          ? _buildSearchField(width: null)
          : Text(widget.title, overflow: TextOverflow.ellipsis),
      actions: [
        if (widget.searchEnabled && !showingSearch)
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => _setSearchActive(true),
          ),
        if (!showingSearch && _buildMobileOverflowMenu() != null)
          _buildMobileOverflowMenu()!,
      ],
    );
  }
}
