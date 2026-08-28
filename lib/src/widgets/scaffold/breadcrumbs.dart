import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// A single breadcrumb entry.
class HBreadcrumbItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const HBreadcrumbItem({required this.label, this.icon, this.onTap});
}

/// Breadcrumb navigation widget for Hornbill UI.
///
/// Usage:
/// ```dart
/// HBreadcrumb(
///   items: [
///     HBreadcrumbItem(label: 'Home', onTap: () => go('/')),
///     HBreadcrumbItem(label: 'Settings', onTap: () => go('/settings')),
///     HBreadcrumbItem(label: 'Profile'), // last = current page
///   ],
///   maxItems: 4,
/// )
/// ```
class HBreadcrumb extends StatelessWidget {
  final List<HBreadcrumbItem> items;
  final IconData separatorIcon;
  final int? maxItems;
  final String collapsedLabel;
  final Color? color;
  final Color? currentColor;
  final EdgeInsetsGeometry padding;

  const HBreadcrumb({
    super.key,
    required this.items,
    this.separatorIcon = Symbols.chevron_right,
    this.maxItems,
    this.collapsedLabel = '…',
    this.color,
    this.currentColor,
    this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  });

  List<HBreadcrumbItem> _visibleItems() {
    if (maxItems == null || items.length <= maxItems!) return items;
    final first = items.first;
    final tailCount = maxItems! - 2;
    final tail = items.sublist(items.length - tailCount);
    return [first, HBreadcrumbItem(label: collapsedLabel), ...tail];
  }

  static bool get _isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final linkColor = color ?? theme.primary;
    final currentTextColor = currentColor ?? theme.onSurface;
    final visible = _visibleItems();
    final fontSize = _isDesktop ? 13.0 : 14.0;

    return Padding(
      padding: padding,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (int i = 0; i < visible.length; i++) ...[
            _HBreadcrumbCrumb(
              item: visible[i],
              isLast: i == visible.length - 1,
              linkColor: linkColor,
              currentColor: currentTextColor,
              fontSize: fontSize,
            ),
            if (i != visible.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  separatorIcon,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// A single crumb. Stateful so each tappable crumb gets its own
/// independent press-scale feedback, matching [HButton]'s physics.
class _HBreadcrumbCrumb extends StatefulWidget {
  final HBreadcrumbItem item;
  final bool isLast;
  final Color linkColor;
  final Color currentColor;
  final double fontSize;

  const _HBreadcrumbCrumb({
    required this.item,
    required this.isLast,
    required this.linkColor,
    required this.currentColor,
    required this.fontSize,
  });

  @override
  State<_HBreadcrumbCrumb> createState() => _HBreadcrumbCrumbState();
}

class _HBreadcrumbCrumbState extends State<_HBreadcrumbCrumb> {
  bool _pressed = false;

  bool get _tappable => widget.item.onTap != null && !widget.isLast;

  void _setPressed(bool value) {
    if (!_tappable) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrent = widget.isLast || !_tappable;
    final Color fg = isCurrent ? widget.currentColor : widget.linkColor;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.item.icon != null) ...[
          Icon(widget.item.icon, size: 16, color: fg),
          const SizedBox(width: 4),
        ],
        Text(
          widget.item.label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            color: fg,
          ),
        ),
      ],
    );

    final crumb = Semantics(
      label: widget.item.label,
      header: widget.isLast,
      button: _tappable,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: content,
      ),
    );

    if (!_tappable) return crumb;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.item.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: crumb,
      ),
    );
  }
}
