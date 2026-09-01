import 'package:material_ui/material_ui.dart';

/// ---------------------------------------------------------------------
/// Shared interaction wrapper used by every card below.
/// If [onTap] / [onLongPress] are both null, returns [child] unchanged
/// (no InkWell, no hit-testing overhead, no focus/hover semantics).
/// Otherwise wraps it in an InkWell so it gets ripple + hover + focus.
/// [needsMaterial] is true for widgets (like HGradientCard) that aren't
/// already inside a Card/Material ancestor.
/// ---------------------------------------------------------------------
Widget _interactive({
  required Widget child,
  required BorderRadius borderRadius,
  required Color splashBase,
  VoidCallback? onTap,
  VoidCallback? onLongPress,
  bool needsMaterial = false,
}) {
  if (onTap == null && onLongPress == null) return child;

  final inkWell = InkWell(
    onTap: onTap,
    onLongPress: onLongPress,
    borderRadius: borderRadius,
    splashColor: splashBase.withValues(alpha: 0.08),
    highlightColor: splashBase.withValues(alpha: 0.04),
    child: child,
  );

  if (!needsMaterial) return inkWell;

  return Material(type: MaterialType.transparency, child: inkWell);
}

/// ---------------------------------------------------------------------
/// HCard — outlined card. Pass [onTap]/[onLongPress] to make it
/// interactive, and [selected] to give it a primary-tinted highlight
/// (handy for selectable list items / option pickers).
/// ---------------------------------------------------------------------
class HCard extends StatelessWidget {
  const HCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 18,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Clip clipBehavior;

  /// Provide either to make the card tappable (adds ripple/hover/focus).
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Highlights the card with a primary-tinted fill and border.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(borderRadius);

    return Card(
      clipBehavior: clipBehavior,
      margin: margin,
      elevation: 0,
      color: selected ? colorScheme.primaryContainer : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: _interactive(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: radius,
        splashBase: colorScheme.primary,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// HElevatedCard — no border, uses shadow/elevation for depth.
/// Good for cards that need to visually "float" above the background
/// (e.g. cards on a colored or image background).
/// ---------------------------------------------------------------------
class HElevatedCard extends StatelessWidget {
  const HElevatedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 18,
    this.clipBehavior = Clip.antiAlias,
    this.elevation = 1,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Clip clipBehavior;
  final double elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(borderRadius);

    return Card(
      clipBehavior: clipBehavior,
      margin: margin,
      elevation: elevation,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.25),
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: _interactive(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: radius,
        splashBase: colorScheme.primary,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// HFilledCard — solid tonal background, no border, no shadow.
/// Good for secondary content blocks that should feel "flat"
/// and sit quietly within a surface (M3 filled-card style).
/// ---------------------------------------------------------------------
class HFilledCard extends StatelessWidget {
  const HFilledCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 18,
    this.clipBehavior = Clip.antiAlias,
    this.color,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Clip clipBehavior;

  /// Override the fill color; defaults to [ColorScheme.surfaceContainerLow].
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(borderRadius);

    return Card(
      clipBehavior: clipBehavior,
      margin: margin,
      elevation: 0,
      color: color ?? colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: _interactive(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: radius,
        splashBase: colorScheme.primary,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// HGradientCard — decorative gradient background, optional border.
/// Good for hero/promo cards, feature highlights, upsell banners.
/// ---------------------------------------------------------------------
class HGradientCard extends StatelessWidget {
  const HGradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 18,
    this.clipBehavior = Clip.antiAlias,
    this.gradient,
    this.showBorder = false,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Clip clipBehavior;

  /// Defaults to a subtle primary → tertiary diagonal gradient.
  final Gradient? gradient;
  final bool showBorder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(borderRadius);

    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.tertiaryContainer,
          ],
        );

    return Container(
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: effectiveGradient,
        border: showBorder
            ? Border.all(color: colorScheme.outlineVariant)
            : null,
      ),
      // HGradientCard uses a Container, not a Card, so it has no Material
      // ancestor of its own — _interactive adds one (needsMaterial: true)
      // so the ripple actually renders when onTap/onLongPress is set.
      child: _interactive(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: radius,
        splashBase: colorScheme.onPrimaryContainer,
        needsMaterial: true,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// HStatusCard — outlined card with a colored accent bar + tint,
/// for success / warning / error / info messaging.
/// ---------------------------------------------------------------------
enum HStatus { success, warning, error, info }

class HStatusCard extends StatelessWidget {
  const HStatusCard({
    super.key,
    required this.child,
    required this.status,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 18,
    this.accentWidth = 4,
    this.fullWidth = false,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final HStatus status;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double accentWidth;

  /// If true, the card stretches to fill the width offered by its parent
  /// (good for full-bleed banners). If false (default), it shrink-wraps
  /// to its content, same as a plain [HCard].
  final bool fullWidth;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  Color _accentColor(ColorScheme colorScheme) {
    switch (status) {
      case HStatus.success:
        return Colors.green;
      case HStatus.warning:
        return Colors.orange;
      case HStatus.error:
        return colorScheme.error;
      case HStatus.info:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _accentColor(colorScheme);
    final radius = BorderRadius.circular(borderRadius);

    final content = Padding(padding: padding, child: child);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: margin,
      elevation: 0,
      color: accent.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: accent.withValues(alpha: 0.35)),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: accentWidth, color: accent),
            fullWidth
                ? Expanded(
                    child: _interactive(
                      onTap: onTap,
                      onLongPress: onLongPress,
                      borderRadius: radius,
                      splashBase: accent,
                      child: content,
                    ),
                  )
                : Flexible(
                    fit: FlexFit.loose,
                    child: _interactive(
                      onTap: onTap,
                      onLongPress: onLongPress,
                      borderRadius: radius,
                      splashBase: accent,
                      child: content,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}