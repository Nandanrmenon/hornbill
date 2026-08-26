part of 'package:hornbill/src/widgets/list_widgets.dart';

/// A small section header, typically placed above an [HListView],
/// [HRadioListView], or [HCheckboxListView] to label the group below it.
///
/// Example:
/// ```dart
/// const HListHeader(
///   title: 'Account',
///   subtitle: 'Manage your profile and security',
///   icon: Icons.person_outline,
/// )
/// ```
class HListHeader extends StatelessWidget {
  /// Creates a section header.
  const HListHeader({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.dense,
  });

  /// The header's title text.
  final String title;

  /// Optional single-line subtitle rendered beneath [title].
  final String? subtitle;

  /// Optional leading icon rendered before [title].
  final IconData? icon;

  /// Called when the header is tapped. If null, the header is not
  /// interactive (though it's still wrapped in an [InkWell] for consistent
  /// hit-testing/hover behavior).
  final VoidCallback? onTap;

  /// Optional widget rendered at the end of the header (e.g. an action
  /// button or a "See all" link).
  final Widget? trailing;

  /// Defaults to `false`. Also tightens the list's outer padding.
  final bool? dense;

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: dense == true
            ? const EdgeInsets.all(8)
            : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: onSurfaceVariant),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurfaceVariant,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
