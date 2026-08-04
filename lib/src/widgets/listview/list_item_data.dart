part of 'package:hornbill/src/widgets/list_widgets.dart';

/// The data for a single row rendered by [HListView].
///
/// Example:
/// ```dart
/// HListItemData(
///   title: 'Notifications',
///   subtitle: 'On',
///   leading: const Icon(Icons.notifications_outlined),
///   onTap: () => Navigator.pushNamed(context, '/notifications'),
/// )
/// ```
@immutable
class HListItemData {
  /// Creates the data for one [HListView] row.
  const HListItemData({
    required this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    this.suffix,
    this.selected = false,
    this.color,
  });

  /// The row's primary text, rendered as the `ListTile.title`.
  final String title;

  /// Optional secondary text, rendered as the `ListTile.subtitle`.
  ///
  /// A null or empty subtitle is treated the same way: no subtitle space
  /// is reserved and the row uses tighter vertical padding.
  final String? subtitle;

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
}
