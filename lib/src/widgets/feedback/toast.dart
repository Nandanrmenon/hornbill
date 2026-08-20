// h_toast.dart
//
// A stackable toast notification system for Flutter.
//
// Usage:
//   HToast.show(context, message: "Saved successfully", type: HToastType.success);
//   HToast.success(context, "Saved successfully");
//   HToast.error(context, "Something went wrong");
//
// Multiple toasts stack on top of each other (peeking cards). Hovering over
// the stack (desktop/web) expands it into a full vertical list showing every
// active toast. Moving the mouse away collapses it back into a stack.
//
// Drop this file into your project and import it wherever you need toasts.

import 'dart:async';

import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Visual style / severity of a toast.
enum HToastType { info, success, error, warning }

/// Where the toast stack is anchored on screen.
enum HToastPosition { topRight, topLeft, bottomRight, bottomLeft }

/// Internal model representing a single active toast.
class _HToastItem {
  final String id;
  final String message;
  final HToastType type;
  final Duration duration;
  Timer? timer;

  _HToastItem({
    required this.id,
    required this.message,
    required this.type,
    required this.duration,
  });
}

/// Static API for showing stackable toast notifications.
///
/// Call [HToast.show] (or the convenience helpers [HToast.info],
/// [HToast.success], [HToast.error], [HToast.warning]) from anywhere you
/// have a [BuildContext]. Each corner ([HToastPosition]) gets its own
/// independent stack, so you can show toasts in different corners at the
/// same time if you want to.
class HToast {
  HToast._();

  // ---- Default fallbacks (used when a param isn't passed to show()) ----
  static const HToastPosition defaultPosition = HToastPosition.topRight;
  static const EdgeInsets defaultMargin = EdgeInsets.all(16);
  static const double defaultWidth = 320;

  // ---- Internal state, keyed per-position so stacks are independent ----
  static final Map<HToastPosition, OverlayEntry> _overlayEntries = {};
  static final Map<HToastPosition, GlobalKey<_HToastStackState>> _stackKeys =
      {};
  static final Map<HToastPosition, List<_HToastItem>> _itemsByPosition = {};
  static int _counter = 0;

  /// Shows a new toast. Returns the toast's id, which can be passed to
  /// [dismiss] to remove it early.
  ///
  /// [position] controls which corner the toast (and its stack) appears in.
  /// [margin] and [width] are optional overrides for that stack.
  static String show(
    BuildContext context, {
    required String message,
    HToastType type = HToastType.info,
    Duration duration = const Duration(seconds: 3),
    HToastPosition position = defaultPosition,
    EdgeInsets margin = defaultMargin,
    double width = defaultWidth,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _ensureOverlay(overlay, position, margin, width);

    final id = 'htoast_${_counter++}';
    final item = _HToastItem(
      id: id,
      message: message,
      type: type,
      duration: duration,
    );
    item.timer = Timer(duration, () => _remove(position, id));
    _itemsByPosition[position]!.add(item);
    _stackKeys[position]?.currentState?.refresh();
    return id;
  }

  static String info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    HToastPosition position = defaultPosition,
  }) => show(
    context,
    message: message,
    type: HToastType.info,
    duration: duration,
    position: position,
  );

  static String success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    HToastPosition position = defaultPosition,
  }) => show(
    context,
    message: message,
    type: HToastType.success,
    duration: duration,
    position: position,
  );

  static String error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    HToastPosition position = defaultPosition,
  }) => show(
    context,
    message: message,
    type: HToastType.error,
    duration: duration,
    position: position,
  );

  static String warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    HToastPosition position = defaultPosition,
  }) => show(
    context,
    message: message,
    type: HToastType.warning,
    duration: duration,
    position: position,
  );

  /// Dismisses a single toast by id (returned from [show]).
  /// If you know which [position] it was shown in, pass it for an O(1)
  /// lookup; otherwise every stack is searched.
  static void dismiss(String id, [HToastPosition? position]) {
    if (position != null) {
      _remove(position, id);
      return;
    }
    for (final pos in _itemsByPosition.keys.toList()) {
      _remove(pos, id);
    }
  }

  /// Dismisses every currently visible toast in every stack.
  static void dismissAll() {
    for (final pos in _itemsByPosition.keys.toList()) {
      for (final item in _itemsByPosition[pos]!) {
        item.timer?.cancel();
      }
      _itemsByPosition[pos]!.clear();
      _overlayEntries[pos]?.remove();
      _overlayEntries.remove(pos);
    }
  }

  static void _ensureOverlay(
    OverlayState overlay,
    HToastPosition position,
    EdgeInsets margin,
    double width,
  ) {
    _itemsByPosition.putIfAbsent(position, () => []);
    if (_overlayEntries[position] != null) return;

    final stackKey = GlobalKey<_HToastStackState>();
    _stackKeys[position] = stackKey;

    final entry = OverlayEntry(
      builder: (context) => _HToastStack(
        key: stackKey,
        items: _itemsByPosition[position]!,
        position: position,
        margin: margin,
        width: width,
        onDismiss: (id) => _remove(position, id),
      ),
    );
    _overlayEntries[position] = entry;
    overlay.insert(entry);
  }

  static void _remove(HToastPosition position, String id) {
    final items = _itemsByPosition[position];
    if (items == null) return;
    final index = items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    items[index].timer?.cancel();
    items.removeAt(index);
    _stackKeys[position]?.currentState?.refresh();

    if (items.isEmpty) {
      _overlayEntries[position]?.remove();
      _overlayEntries.remove(position);
      _stackKeys.remove(position);
    }
  }
}

/// The overlay widget that lays out and animates the toast stack.
class _HToastStack extends StatefulWidget {
  final List<_HToastItem> items;
  final HToastPosition position;
  final EdgeInsets margin;
  final double width;
  final void Function(String id) onDismiss;

  const _HToastStack({
    super.key,
    required this.items,
    required this.position,
    required this.margin,
    required this.width,
    required this.onDismiss,
  });

  @override
  State<_HToastStack> createState() => _HToastStackState();
}

class _HToastStackState extends State<_HToastStack> {
  bool _expanded = false;

  static const double _cardHeight = 60;
  static const double _expandedGap = 8;
  static const double _collapsedOffset = 8;
  static const double _collapsedScaleStep = 0.06;
  static const int _maxCollapsedPeek = 3;

  void refresh() {
    if (mounted) setState(() {});
  }

  bool get _isTop =>
      widget.position == HToastPosition.topRight ||
      widget.position == HToastPosition.topLeft;

  bool get _isLeft =>
      widget.position == HToastPosition.topLeft ||
      widget.position == HToastPosition.bottomLeft;

  void _pauseTimers() {
    for (final item in widget.items) {
      item.timer?.cancel();
    }
  }

  void _resumeTimers() {
    for (final item in widget.items) {
      item.timer = Timer(item.duration, () => widget.onDismiss(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    // Newest toast first (drawn on top of the stack when collapsed).
    final newestFirst = List<_HToastItem>.from(widget.items.reversed);

    final double stackHeight = _expanded
        ? newestFirst.length * _cardHeight +
              (newestFirst.length - 1) * _expandedGap
        : _cardHeight +
              (newestFirst.length > 1
                  ? (newestFirst.length - 1).clamp(0, _maxCollapsedPeek) *
                        _collapsedOffset
                  : 0);

    return Positioned(
      top: _isTop ? widget.margin.top : null,
      bottom: !_isTop ? widget.margin.bottom : null,
      left: _isLeft ? widget.margin.left : null,
      right: !_isLeft ? widget.margin.right : null,
      child: MouseRegion(
        onEnter: (_) {
          _pauseTimers();
          setState(() => _expanded = true);
        },
        onExit: (_) {
          _resumeTimers();
          setState(() => _expanded = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: widget.width,
          height: stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            // Build oldest -> newest so the newest card paints on top.
            children: List.generate(newestFirst.length, (i) {
              final item = newestFirst[i]; // i = 0 is newest
              final reverseOrder = newestFirst.length - 1 - i;
              return _buildPositionedCard(
                item: item,
                index: i,
                zOrderKeyIndex: reverseOrder,
              );
            }).reversed.toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionedCard({
    required _HToastItem item,
    required int index, // 0 = newest
    required int zOrderKeyIndex,
  }) {
    late double top;
    late double scale;
    late double opacity;

    if (_expanded) {
      top = index * (_cardHeight + _expandedGap);
      scale = 1.0;
      opacity = 1.0;
    } else {
      final peekIndex = index.clamp(0, _maxCollapsedPeek);
      top = peekIndex * _collapsedOffset;
      scale = 1 - (peekIndex * _collapsedScaleStep);
      opacity = index > _maxCollapsedPeek ? 0.0 : 1.0;
    }

    return AnimatedPositioned(
      key: ValueKey(item.id),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      top: _isTop ? top : null,
      bottom: !_isTop ? top : null,
      left: 0,
      right: 0,
      height: _cardHeight,
      child: IgnorePointer(
        ignoring: !_expanded && index != 0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: opacity,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            scale: scale,
            alignment: _isTop ? Alignment.topCenter : Alignment.bottomCenter,
            child: _HToastCard(
              item: item,
              onClose: () => widget.onDismiss(item.id),
            ),
          ),
        ),
      ),
    );
  }
}

/// Visual representation of a single toast.
class _HToastCard extends StatelessWidget {
  final _HToastItem item;
  final VoidCallback onClose;

  const _HToastCard({required this.item, required this.onClose});

  _ToastStyle _styleFor(HToastType type, Brightness brightness) {
    switch (type) {
      case HToastType.success:
        return const _ToastStyle(
          color: Color(0xFF2E7D32),
          icon: Symbols.check_circle_rounded,
        );
      case HToastType.error:
        return const _ToastStyle(
          color: Color(0xFFC62828),
          icon: Symbols.error_rounded,
        );
      case HToastType.warning:
        return const _ToastStyle(
          color: Color(0xFFEF6C00),
          icon: Symbols.warning_rounded,
        );
      case HToastType.info:
        return const _ToastStyle(
          color: Color(0xFF1565C0),
          icon: Symbols.info_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final style = _styleFor(item.type, brightness);
    final bg = Theme.of(context).colorScheme.surfaceContainerLow;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(color: style.color),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(style.icon, color: style.color, size: 22, fill: 1),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Symbols.close_rounded,
                  size: 16,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToastStyle {
  final Color color;
  final IconData icon;
  const _ToastStyle({required this.color, required this.icon});
}
