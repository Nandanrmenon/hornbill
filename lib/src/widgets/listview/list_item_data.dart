part of 'package:hornbill/src/widgets/list_widgets.dart';

/// A standalone list tile that can also be rendered by [HListView].
///
/// Example:
/// ```dart
/// HListTile(
///   title: 'Notifications',
///   subtitle: 'On',
///   leading: const Icon(Icons.notifications_outlined),
///   onTap: () => Navigator.pushNamed(context, '/notifications'),
/// )
/// ```
@immutable
class HListTile extends StatelessWidget {
  /// Creates a standalone list tile.
  const HListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    this.suffix,
    this.selected = false,
    this.color,
    this.dense,
  });

  /// The row's primary text, rendered as the `ListTile.title`.
  final Widget title;

  /// Optional secondary text, rendered as the `ListTile.subtitle`.
  ///
  /// A null or empty subtitle is treated the same way: no subtitle space
  /// is reserved and the row uses tighter vertical padding.
  final Widget? subtitle;

  /// Called when the row is tapped. If null, the row is not interactive.
  final VoidCallback? onTap;

  /// Widget shown at the start of the row (e.g. an [Icon] or [CircleAvatar]).
  final Widget? leading;

  /// Widget shown at the end of the row (e.g. a [Switch], chevron, or
  /// trailing [Icon]).
  final Widget? suffix;

  /// Whether this row is rendered in its selected state
  /// (`ListTile.selected`).
  final bool selected;

  /// Optional accent color for this row.
  ///
  /// Used at reduced opacity as the row's card background and, at full
  /// opacity, as `ListTile.selectedColor`. Falls back to the current
  /// theme's surface/primary colors when null.
  final Color? color;

  /// Whether this tile uses the compact [ListTile] layout.
  final bool? dense;

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      color: color?.withValues(alpha: 0.2),
      index: 0,
      itemCount: 1,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context, {bool? denseOverride}) {
    final hasSubtitle = subtitle != null;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      contentPadding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: hasSubtitle ? 4.0 : 8.0,
        top: hasSubtitle ? 0.0 : 8.0,
      ),
      dense: denseOverride ?? dense,
      title: title,
      leading: leading,
      selectedColor: color ?? Theme.of(context).colorScheme.primary,
      subtitle: hasSubtitle ? subtitle! : null,
      onTap: onTap,
      trailing: suffix,
      selected: selected,
    );
  }
}

/// Compatibility alias for [HListTile]. Prefer [HListTile] in new code.
typedef HListItemData = HListTile;
