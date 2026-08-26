// dialog.dart
//
// A custom, Material-free-by-default dialog for Flutter. Works whether
// you're on the bundled `material.dart` or the standalone `material_ui`
// package.
//
// Usage:
//
//   onPressed: () => showHDialog(
//     context,
//     builder: (context) => HDialog(child: Text('Hello from HDialog')),
//   ),
//
// `builder` returns a fully-configured [HDialog] — that's where you set
// `position`, `backgroundColor`, `padding`, etc. `showHDialog` just hosts it
// in a route, adds the barrier, and animates it in to match wherever it's
// placed.
//
// By default the dialog is responsive: it docks to the bottom of the screen
// on narrow (mobile-ish) viewports and centers itself on wide (desktop/
// tablet) viewports. Pass `position:` on the [HDialog] to override that.

import 'package:hornbill/hornbill.dart';
import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_ui/material_ui.dart';

/// Where an [HDialog] should be placed on screen.
enum HDialogPosition {
  /// Bottom on narrow screens, center on wide screens. This is the default
  /// and is what makes HDialog "responsive" out of the box.
  auto,

  /// Always centered, regardless of screen size.
  center,

  /// Always docked to the bottom (like a bottom sheet).
  bottom,

  /// Always docked to the top.
  top,
}

/// Screen width (in logical pixels) below which [HDialogPosition.auto]
/// resolves to [HDialogPosition.bottom] instead of [HDialogPosition.center].
///
/// 600dp lines up with the common mobile/tablet breakpoint used across the
/// Flutter ecosystem (it's the same value Material's own breakpoints use).
const double kHDialogMobileBreakpoint = 600.0;

/// Resolves [HDialogPosition.auto] against the current [context]'s width.
HDialogPosition resolveHDialogPosition(
  BuildContext context,
  HDialogPosition position,
) {
  if (position != HDialogPosition.auto) return position;
  final width = MediaQuery.sizeOf(context).width;
  return width < kHDialogMobileBreakpoint
      ? HDialogPosition.bottom
      : HDialogPosition.center;
}

/// The visual dialog "card" itself.
///
/// Construct this directly inside `showHDialog`'s `builder` — that's where
/// you configure placement, sizing, and colors. There are two ways to lay
/// out the body:
///
/// 1. `title` / `content` — a standard dialog shape, laid out for you.
///    `content` sits in a scrollable region capped at [maxHeightFactor] of
///    the screen height, so long content scrolls instead of overflowing:
///
///   showHDialog(
///     context,
///     builder: (context) => HDialog(
///       title: Text('Delete item?'),
///       content: Text('This can\'t be undone.'),
///       actions: [
///         HButton.text(label: 'Cancel', onPressed: () => Navigator.pop(context)),
///         HButton.filled(label: 'Delete', onPressed: () => Navigator.pop(context, true)),
///       ],
///     ),
///   );
///
/// 2. `child` — full control over the body, e.g. a form:
///
///   showHDialog(
///     context,
///     builder: (context) => HDialog(
///       child: MyCustomForm(),
///       actions: [HButton.filled(label: 'Save', onPressed: () {})],
///     ),
///   );
///
/// `title`/`content` and `child` are mutually exclusive — pass one or the
/// other, not both. `actions`, if given, only accepts [HButton]s, and is
/// laid out by screen width regardless of where the dialog is docked:
/// stacked full-width in a column below [kHDialogMobileBreakpoint], and in
/// a right-aligned row at or above it.
class HDialog extends StatelessWidget {
  const HDialog({
    super.key,
    this.title,
    this.content,
    this.child,
    this.actions,
    this.position = HDialogPosition.auto,
    this.maxWidth = 480,
    this.maxHeightFactor = 0.85,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderRadius,
    this.shadowColor,
    this.actionsSpacing = 8.0,
  }) : assert(
         child == null || (title == null && content == null),
         'Pass either `child`, or `title`/`content` — not both. `child` '
         'gives full control over the body; `title`/`content` lays out a '
         'standard title + body for you.',
       ),
       assert(
         maxHeightFactor > 0 && maxHeightFactor <= 1,
         'maxHeightFactor must be between 0 (exclusive) and 1 (inclusive).',
       );

  /// Standard dialog title, shown above [content]. Ignored if [child] is set.
  final Widget? title;

  /// Standard dialog body, shown below [title]. Ignored if [child] is set.
  /// Laid out as a scrollable column: if it's taller than the space left
  /// over after [title] and [actions] (bounded by [maxHeightFactor]), it
  /// scrolls internally instead of overflowing the dialog.
  final List<Widget>? content;

  /// Full custom body. Mutually exclusive with [title]/[content].
  final Widget? child;

  /// Action buttons, shown below the body. Only [HButton]s are accepted so
  /// every dialog's actions stay visually consistent. Laid out by screen
  /// width (not by [position]): stacked full-width in a column on narrow
  /// (mobile) screens, right-aligned in a row on wide (desktop) screens.
  final List<HButton>? actions;

  /// Where to place the dialog. Defaults to [HDialogPosition.auto].
  final HDialogPosition position;

  /// Max width of the dialog card when centered/top/bottom-but-not-full-bleed
  /// (i.e. on desktop-sized screens). Ignored for full-width bottom/top
  /// sheets on mobile-sized screens.
  final double maxWidth;

  /// Caps the dialog's height at this fraction of the screen height (0–1).
  /// [title] and [actions] always stay fully visible; only [content] (or
  /// [child]) gives up space and scrolls once this cap is hit.
  final double maxHeightFactor;

  /// Inner padding around the body/actions.
  final EdgeInsets padding;

  /// Outer margin around the card. Only applied when centered — bottom/top
  /// sheets go edge-to-edge horizontally.
  final EdgeInsets margin;

  final Color? backgroundColor;

  /// Corner radius. If null, a sensible default is chosen based on
  /// [position] (rounded-top for bottom sheets, rounded-bottom for top
  /// sheets, all-round for centered dialogs).
  final BorderRadius? borderRadius;

  final Color? shadowColor;

  /// Spacing between [actions], and between the body and the actions block.
  final double actionsSpacing;

  bool _isEdgeToEdge(HDialogPosition resolved) =>
      resolved == HDialogPosition.bottom || resolved == HDialogPosition.top;

  Alignment _alignmentFor(HDialogPosition resolved) {
    switch (resolved) {
      case HDialogPosition.bottom:
        return Alignment.bottomCenter;
      case HDialogPosition.top:
        return Alignment.topCenter;
      case HDialogPosition.center:
      case HDialogPosition.auto:
        return Alignment.center;
    }
  }

  BorderRadius _radiusFor(HDialogPosition resolved) {
    if (borderRadius != null) return borderRadius!;
    const r = Radius.circular(kBorderRadius);
    switch (resolved) {
      case HDialogPosition.bottom:
        return const BorderRadius.only(topLeft: r, topRight: r);
      case HDialogPosition.top:
        return const BorderRadius.only(bottomLeft: r, bottomRight: r);
      case HDialogPosition.center:
      case HDialogPosition.auto:
        return BorderRadius.circular(16);
    }
  }

  /// Builds the body. When using `title`/`content`, `content` is placed in
  /// a [Flexible] + [SingleChildScrollView] so it scrolls internally rather
  /// than overflowing once the dialog hits [maxHeightFactor]; `title` stays
  /// pinned above it. `child` is used as-is (bring your own scrolling if
  /// your custom body needs it).
  Widget _buildBody(BuildContext context) {
    if (child != null) return child!;
    final titleStyle =
        Theme.of(context).textTheme.titleLarge ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) DefaultTextStyle(style: titleStyle, child: title!),
        if (title != null && content != null) const SizedBox(height: 8),
        if (content != null)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.0,
                  children: content!,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) return null;
    final isMobile =
        MediaQuery.sizeOf(context).width < kHDialogMobileBreakpoint;
    if (isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < actions!.length; i++) ...[
            if (i > 0) SizedBox(height: actionsSpacing),
            SizedBox(width: double.infinity, child: actions![i]),
          ],
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var i = 0; i < actions!.length; i++) ...[
          if (i > 0) SizedBox(width: actionsSpacing),
          actions![i],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveHDialogPosition(context, position);
    final edgeToEdge = _isEdgeToEdge(resolved);
    final screenSize = MediaQuery.sizeOf(context);
    final actionsWidget = _buildActions(context);

    final card = Material(
      type: MaterialType.transparency,
      child: Container(
        width: edgeToEdge ? screenSize.width : null,
        constraints: BoxConstraints(
          maxWidth: edgeToEdge ? screenSize.width : maxWidth,
          maxHeight: screenSize.height * maxHeightFactor,
        ),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: _radiusFor(resolved),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  shadowColor ??
                  Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: SafeArea(
          top: resolved != HDialogPosition.bottom,
          bottom: resolved != HDialogPosition.top,
          left: false,
          right: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: _buildBody(context)),
              if (actionsWidget != null) ...[
                SizedBox(height: actionsSpacing * 1.5),
                actionsWidget,
              ],
            ],
          ),
        ),
      ),
    );

    return Align(
      alignment: _alignmentFor(resolved),
      child: edgeToEdge ? card : Padding(padding: margin, child: card),
    );
  }
}

/// Shows an [HDialog] as a modal route.
///
/// Unlike a typical `showDialog`, this does **not** wrap your `builder`'s
/// return value in anything — `builder` is expected to return an [HDialog]
/// directly, fully configured (position, colors, sizing, etc. all live on
/// that widget):
///
///   showHDialog(
///     context,
///     builder: (context) => HDialog(
///       title: Text('Delete item?'),
///       content: Text('This can\'t be undone.'),
///       actions: [
///         HButton.text(label: 'Cancel', onPressed: () => Navigator.pop(context)),
///         HButton.filled(label: 'Delete', onPressed: () => Navigator.pop(context, true)),
///       ],
///     ),
///   );
///
/// `showHDialog` itself only owns route-level concerns: the barrier, its
/// dismissibility/color, and the transition duration. It reads the returned
/// [HDialog]'s `position` so the enter/exit animation matches wherever it's
/// placed (slide up for bottom, slide down for top, fade + scale for
/// center) — that's the only reason it inspects the returned widget.
Future<T?> showHDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = const Color(0x8A000000),
  Duration transitionDuration = const Duration(milliseconds: 220),
  String barrierLabel = 'Dismiss',
}) {
  HDialogPosition dialogPosition = HDialogPosition.auto;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      final dialog = builder(context);
      assert(
        dialog is HDialog,
        'showHDialog expects `builder` to return an HDialog, e.g. '
        "builder: (context) => HDialog(child: Text('Hi')).",
      );
      if (dialog is HDialog) dialogPosition = dialog.position;
      return dialog;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final resolved = resolveHDialogPosition(context, dialogPosition);
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      switch (resolved) {
        case HDialogPosition.bottom:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        case HDialogPosition.top:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        case HDialogPosition.center:
        case HDialogPosition.auto:
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
      }
    },
  );
}
