import 'dart:async';

import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_ui/material_ui.dart';

/// Width at which toasts switch from the mobile layout to the desktop layout.
const double kHToastWideBreakpoint = 600;

/// Semantic type. `info` follows the theme's primary colour.
enum HToastType { info, success, warning, error }

enum HToastPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight;

  bool get isTop => name.startsWith('top');
  bool get isLeft => name.endsWith('Left');
  bool get isRight => name.endsWith('Right');

  Alignment get alignment => switch (this) {
    topLeft => Alignment.topLeft,
    topCenter => Alignment.topCenter,
    topRight => Alignment.topRight,
    bottomLeft => Alignment.bottomLeft,
    bottomCenter => Alignment.bottomCenter,
    bottomRight => Alignment.bottomRight,
  };
}

/// Returned by [HToast.show] so a toast can be dismissed early.
class HToastHandle {
  final VoidCallback dismiss;
  const HToastHandle._(this.dismiss);
}

/// Adaptive toast notifications.
///
/// * Wide screens (>= [kHToastWideBreakpoint]): fixed 400px card,
///   default position **top center**.
/// * Narrow screens: full-width card (16px margin), default position
///   **bottom center**, lifts above the keyboard, swipe sideways to dismiss.
///
/// Pass [position] to force a position on every screen size.
class HToast {
  HToast._();

  /// Max toasts visible at once; the oldest is dismissed first.
  static int maxVisible = 3;

  static HToastHandle show(
    BuildContext context, {
    required String title,
    String? description,
    HToastType type = HToastType.info,
    IconData? icon,
    bool showIcon = true,
    Duration? duration = const Duration(seconds: 4),
    HToastPosition? position,
    String? actionLabel,
    VoidCallback? onAction,
    bool dismissible = true,
  }) {
    final data = _ToastData(
      title: title,
      description: description,
      type: type,
      icon: showIcon ? (icon ?? _defaultIcon(type)) : null,
      duration: duration,
      position: position,
      actionLabel: actionLabel,
      onAction: onAction,
      dismissible: dismissible,
    );
    _ToastManager.instance.add(context, data);
    return HToastHandle._(() => data.key.currentState?.dismiss());
  }

  static void dismissAll() => _ToastManager.instance.dismissAll();

  static IconData _defaultIcon(HToastType t) => switch (t) {
    HToastType.success => Icons.check_circle_rounded,
    HToastType.warning => Icons.warning_rounded,
    HToastType.error => Icons.error_rounded,
    HToastType.info => Icons.info_rounded,
  };
}

// ---------------------------------------------------------------------------
// Internals
// ---------------------------------------------------------------------------

class _ToastData {
  _ToastData({
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.duration,
    required this.position,
    required this.actionLabel,
    required this.onAction,
    required this.dismissible,
  }) : id = _nextId++;

  static int _nextId = 0;

  final int id;
  final String title;
  final String? description;
  final HToastType type;
  final IconData? icon;
  final Duration? duration;
  final HToastPosition? position;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool dismissible;

  bool closing = false;

  /// Last measured height, used to lay the expanded stack out.
  double height = 64;
  final GlobalKey<_ToastItemState> key = GlobalKey<_ToastItemState>();
}

class _ToastManager {
  _ToastManager._();
  static final instance = _ToastManager._();

  final ValueNotifier<List<_ToastData>> toasts = ValueNotifier([]);
  OverlayEntry? _entry;

  /// True while the pointer is over the toast stack (pauses auto-dismiss).
  final ValueNotifier<bool> hovering = ValueNotifier(false);

  void add(BuildContext context, _ToastData data) {
    if (_entry == null || !_entry!.mounted) {
      _entry = OverlayEntry(builder: (_) => const _ToastHost());
      Overlay.of(context, rootOverlay: true).insert(_entry!);
    }
    toasts.value = [...toasts.value, data];

    // Evict the oldest toasts beyond the limit.
    var active = toasts.value.where((t) => !t.closing).toList();
    while (active.length > HToast.maxVisible) {
      active.first.key.currentState?.dismiss();
      active.first.closing = true;
      active = active.sublist(1);
    }
  }

  void remove(int id) {
    toasts.value = toasts.value.where((t) => t.id != id).toList();
    if (toasts.value.isEmpty) {
      hovering.value = false;
      _entry?.remove();
      _entry?.dispose();
      _entry = null;
    }
  }

  void dismissAll() {
    for (final t in [...toasts.value]) {
      t.key.currentState?.dismiss();
    }
  }
}

class _ToastHost extends StatelessWidget {
  const _ToastHost();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final wide = media.size.width >= kHToastWideBreakpoint;

    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: ValueListenableBuilder<List<_ToastData>>(
          valueListenable: _ToastManager.instance.toasts,
          builder: (context, list, _) {
            final groups = <HToastPosition, List<_ToastData>>{};
            for (final t in list) {
              final pos =
                  t.position ??
                  (wide
                      ? HToastPosition.topCenter
                      : HToastPosition.bottomCenter);
              groups.putIfAbsent(pos, () => []).add(t);
            }

            return Stack(
              children: [
                for (final entry in groups.entries)
                  _buildGroup(context, media, wide, entry.key, entry.value),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroup(
    BuildContext context,
    MediaQueryData media,
    bool wide,
    HToastPosition pos,
    List<_ToastData> items,
  ) {
    final bottomInset = media.viewInsets.bottom > media.padding.bottom
        ? media
              .viewInsets
              .bottom // lift above the keyboard
        : media.padding.bottom;

    return Align(
      alignment: pos.alignment,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16 + media.padding.left,
          16 + media.padding.top,
          16 + media.padding.right,
          16 + bottomInset,
        ),
        child: _ToastGroup(position: pos, items: items, wide: wide),
      ),
    );
  }
}

/// Lays out the toasts of one position.
///
/// Collapsed (default): toasts overlap like a deck of cards - the newest is in
/// front, older ones peek out behind it, slightly smaller and faded.
/// Expanded (desktop hover): toasts spread out into a normal list.
///
/// Both states use the same [Stack] and every toast is animated between the
/// two, so expanding *and* collapsing are smooth.
class _ToastGroup extends StatefulWidget {
  const _ToastGroup({
    required this.position,
    required this.items,
    required this.wide,
  });

  final HToastPosition position;

  /// Oldest -> newest.
  final List<_ToastData> items;
  final bool wide;

  @override
  State<_ToastGroup> createState() => _ToastGroupState();
}

class _ToastGroupState extends State<_ToastGroup> {
  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.easeOutCubic;
  static const _gap = 8.0; // spacing when expanded
  static const _peek = 12.0; // offset per card when collapsed

  bool _expanded = false;

  void _setHover(bool v) {
    _ToastManager.instance.hovering.value = v;
    if (widget.wide) setState(() => _expanded = v);
  }

  @override
  void dispose() {
    _ToastManager.instance.hovering.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.position;
    final wide = widget.wide;
    final items = widget.items.reversed.toList(); // newest first
    final visible = items.length < HToast.maxVisible
        ? items.length
        : HToast.maxVisible;

    // Height of the whole stack in each state.
    final collapsedHeight = items.first.height + (visible - 1) * _peek;
    final expandedHeight =
        items.fold<double>(0, (sum, t) => sum + t.height) +
        _gap * (items.length - 1);

    var offset = 0.0; // running offset for the expanded layout
    final slots = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final t = items[i];

      final double y, scale, opacity;
      if (_expanded) {
        y = offset;
        scale = 1;
        opacity = 1;
      } else {
        y = i * _peek;
        scale = 1 - i * 0.06;
        opacity = i == 0
            ? 1
            : i < HToast.maxVisible
            ? 1 - i * 0.2
            : 0;
      }
      offset += t.height + _gap;

      slots.add(
        AnimatedPositioned(
          key: ValueKey(t.id),
          duration: _duration,
          curve: _curve,
          left: 0,
          right: 0,
          top: pos.isTop ? y : null,
          bottom: pos.isTop ? null : y,
          child: AnimatedScale(
            scale: scale,
            alignment: pos.isTop ? Alignment.topCenter : Alignment.bottomCenter,
            duration: _duration,
            curve: _curve,
            child: AnimatedOpacity(
              opacity: opacity.toDouble(),
              duration: _duration,
              child: IgnorePointer(
                ignoring: !_expanded && i > 0,
                child: _MeasureSize(
                  onChange: (size) {
                    if (t.height != size.height) {
                      t.height = size.height;
                      if (mounted) setState(() {});
                    }
                  },
                  child: _ToastItem(
                    key: t.key,
                    data: t,
                    wide: wide,
                    position: pos,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedContainer(
        duration: _duration,
        curve: _curve,
        width: wide ? 400 : double.infinity,
        height: _expanded ? expandedHeight : collapsedHeight,
        child: Stack(
          clipBehavior: Clip.none,
          // Paint oldest first so the newest ends up in front.
          children: slots.reversed.toList(),
        ),
      ),
    );
  }
}

/// Reports its child's size after layout.
class _MeasureSize extends StatefulWidget {
  const _MeasureSize({required this.onChange, required this.child});

  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  Size? _last;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = context.size;
      if (size != null && size != _last) {
        _last = size;
        widget.onChange(size);
      }
    });
    return widget.child;
  }
}

class _ToastItem extends StatefulWidget {
  const _ToastItem({
    super.key,
    required this.data,
    required this.wide,
    required this.position,
  });

  final _ToastData data;
  final bool wide;
  final HToastPosition position;

  @override
  State<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<_ToastItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 180),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _startTimer();
    _ToastManager.instance.hovering.addListener(_onHover);
  }

  void _onHover() {
    if (_ToastManager.instance.hovering.value) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final d = widget.data.duration;
    if (d == null || widget.data.closing) return;
    _timer = Timer(d, dismiss);
  }

  void dismiss() {
    if (!mounted) return;
    widget.data.closing = true;
    _timer?.cancel();
    _c.reverse().whenComplete(() {
      _ToastManager.instance.remove(widget.data.id);
    });
  }

  @override
  void dispose() {
    _ToastManager.instance.hovering.removeListener(_onHover);
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  // ---- Colors ----

  Color _base(ColorScheme s) => switch (widget.data.type) {
    HToastType.info => s.primary,
    HToastType.success => const Color(0xFF17C964),
    HToastType.warning => const Color(0xFFF5A524),
    HToastType.error => const Color(0xFFF31260),
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = widget.data;
    final base = _base(scheme);

    final bg = scheme.surfaceContainerLow;
    final fg = scheme.onSurface;
    final accent = base;
    final border = scheme.outlineVariant;

    Widget card = Container(
      width: widget.wide ? 400 : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (d.icon != null) ...[
            Icon(d.icon, size: 22, color: accent),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  d.title,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                if (d.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      d.description!,
                      style: TextStyle(
                        color: fg.withValues(alpha: 0.75),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (d.actionLabel != null) ...[
            const SizedBox(width: 12),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                d.onAction?.call();
                dismiss();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  d.actionLabel!,
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (d.dismissible) ...[
            const SizedBox(width: 4),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: dismiss,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: fg.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // Swipe sideways to dismiss (mainly for touch devices).
    if (d.dismissible) {
      card = Dismissible(
        key: ValueKey(d.id),
        direction: DismissDirection.horizontal,
        onDismissed: (_) {
          d.closing = true;
          _timer?.cancel();
          _ToastManager.instance.remove(d.id);
        },
        child: card,
      );
    }

    final curved = CurvedAnimation(
      parent: _c,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final pos = widget.position;
    final begin = pos.isLeft && widget.wide
        ? const Offset(-0.3, 0)
        : pos.isRight && widget.wide
        ? const Offset(0.3, 0)
        : Offset(0, pos.isTop ? -0.4 : 0.4);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
        child: card,
      ),
    );
  }
}
