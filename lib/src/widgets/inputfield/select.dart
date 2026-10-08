import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:hornbill/src/theme.dart';
import 'package:material_ui/material_ui.dart';

enum HSelectVariant { flat, faded, bordered, underlined }

enum HSelectSize { sm, md, lg }

/// One option in an [HSelect].
class HSelectItem<T> {
  const HSelectItem({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.leading,
    this.enabled = true,
  });

  final T value;

  /// Shown in the list and, once selected, in the field.
  final String label;

  /// Small muted text under [label] in the list.
  final String? description;

  /// Shorthand for a leading icon. Ignored when [leading] is set.
  final IconData? icon;

  /// Custom leading widget (avatar, flag, ...).
  final Widget? leading;

  final bool enabled;
}

///  * four trigger variants, three sizes, label above the field
///  * description, error message, required marker
///  * a popover list that opens below the field (flips above when there is no
///    room), animates in, scrolls, and shows a check next to selected items
///  * keyboard support: Enter / Space / Arrow keys open it, Arrow keys move,
///    Enter / Space select, Escape closes
///  * single selection ([HSelect.new]) or multiple ([HSelect.multiple])
///
/// The field fills the available width. Inside a `Row`, wrap it in `Expanded`
/// or pass [width].
///
/// ```dart
/// HSelect<String>(
///   label: 'Favorite animal',
///   placeholder: 'Select an animal',
///   value: animal,
///   onChanged: (v) => setState(() => animal = v),
///   items: const [
///     HSelectItem(value: 'cat', label: 'Cat'),
///     HSelectItem(value: 'dog', label: 'Dog'),
///   ],
/// )
/// ```
class HSelect<T> extends StatefulWidget {
  /// Single selection.
  const HSelect({
    super.key,
    required this.items,
    T? value,
    ValueChanged<T>? onChanged,
    this.label,
    this.placeholder,
    this.description,
    this.errorText,
    this.variant = HSelectVariant.flat,
    this.size = HSelectSize.md,
    this.radius,
    this.isRequired = false,
    this.isDisabled = false,
    this.startContent,
    this.width,
    this.maxMenuHeight = 256,
  }) : _value = value,
       _onSingle = onChanged,
       _values = null,
       _onMulti = null;

  /// Multiple selection. The menu stays open while toggling.
  const HSelect.multiple({
    super.key,
    required this.items,
    required Set<T> values,
    ValueChanged<Set<T>>? onChanged,
    this.label,
    this.placeholder,
    this.description,
    this.errorText,
    this.variant = HSelectVariant.flat,
    this.size = HSelectSize.md,
    this.radius,
    this.isRequired = false,
    this.isDisabled = false,
    this.startContent,
    this.width,
    this.maxMenuHeight = 256,
  }) : _value = null,
       _onSingle = null,
       _values = values,
       _onMulti = onChanged;

  final List<HSelectItem<T>> items;

  final T? _value;
  final ValueChanged<T>? _onSingle;
  final Set<T>? _values;
  final ValueChanged<Set<T>>? _onMulti;

  final String? label;
  final String? placeholder;

  /// Helper text under the field.
  final String? description;

  /// When non-null the field is invalid: red border and this message.
  final String? errorText;

  final HSelectVariant variant;

  /// sm = 32px, md = 40px, lg = 48px tall. These match [HButton]'s heights, and
  /// like [HButton] the default is md on every platform.
  final HSelectSize size;

  /// Overrides the trigger and menu corner radius (sm 8, md 12, lg 14).
  final double? radius;

  /// Adds a red `*` to the label.
  final bool isRequired;
  final bool isDisabled;

  /// Widget before the value (usually an icon).
  final Widget? startContent;

  /// Fixed width. Defaults to the available width.
  final double? width;

  /// Max height of the popover list before it scrolls.
  final double maxMenuHeight;

  bool get _multiple => _values != null;

  @override
  State<HSelect<T>> createState() => _HSelectState<T>();
}

class _HSelectState<T> extends State<HSelect<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    reverseDuration: const Duration(milliseconds: 120),
  );

  OverlayEntry? _entry;
  bool _open = false;
  bool _hovered = false;
  bool _focused = false;

  /// Keyboard / hover highlight (index into widget.items), -1 for none.
  final ValueNotifier<int> _highlight = ValueNotifier<int>(-1);
  List<GlobalKey> _itemKeys = const [];

  double _triggerWidth = 0;
  bool _above = false;
  double _menuMaxHeight = 256;

  // ---------------------------------------------------------------------------
  // Derived state
  // ---------------------------------------------------------------------------

  bool get _enabled =>
      !widget.isDisabled &&
      (widget._multiple ? widget._onMulti != null : widget._onSingle != null);

  bool get _invalid => widget.errorText != null;

  bool _isSelected(T v) => widget._multiple
      ? widget._values!.contains(v)
      : widget._value != null && widget._value == v;

  String? get _valueText {
    if (widget._multiple) {
      final labels = [
        for (final i in widget.items)
          if (widget._values!.contains(i.value)) i.label,
      ];
      return labels.isEmpty ? null : labels.join(', ');
    }
    for (final i in widget.items) {
      if (widget._value != null && i.value == widget._value) return i.label;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Open / close
  // ---------------------------------------------------------------------------

  void _openMenu() {
    if (_open || !_enabled || widget.items.isEmpty) return;
    final box = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final size = box.size;
    final topLeft = box.localToGlobal(Offset.zero);
    final media = MediaQuery.of(context);
    final below =
        media.size.height -
        media.viewInsets.bottom -
        (topLeft.dy + size.height) -
        16;
    final above = topLeft.dy - media.padding.top - 16;
    final estimated = math.min(
      widget.maxMenuHeight,
      widget.items.length * 40.0 + 8,
    );

    _triggerWidth = size.width;
    _above = estimated > below && above > below;
    _menuMaxHeight = math.max(
      120.0,
      math.min(widget.maxMenuHeight, (_above ? above : below) - 6),
    );

    _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
    final selected = widget.items.indexWhere((i) => _isSelected(i.value));
    _highlight.value = selected >= 0 ? selected : _nextEnabled(-1, 1);

    _entry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_entry!);

    setState(() => _open = true);
    _anim.forward();
    _focusNode.requestFocus();
    _scrollToHighlight();
  }

  void _closeMenu() {
    if (!_open) return;
    setState(() => _open = false);
    _anim.reverse().then((_) {
      if (!mounted || _open) return;
      _removeEntry();
    });
  }

  void _removeEntry() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }

  void _toggle() => _open ? _closeMenu() : _openMenu();

  void _select(T value) {
    if (widget._multiple) {
      final next = {...widget._values!};
      next.contains(value) ? next.remove(value) : next.add(value);
      widget._onMulti?.call(next);
    } else {
      widget._onSingle?.call(value);
      _closeMenu();
      _focusNode.requestFocus();
    }
  }

  // ---------------------------------------------------------------------------
  // Keyboard
  // ---------------------------------------------------------------------------

  int _nextEnabled(int from, int step) {
    final n = widget.items.length;
    if (n == 0) return -1;
    var i = from;
    for (var count = 0; count < n; count++) {
      i = (i + step) % n;
      if (i < 0) i += n;
      if (widget.items[i].enabled) return i;
    }
    return -1;
  }

  void _scrollToHighlight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final i = _highlight.value;
      if (i < 0 || i >= _itemKeys.length) return;
      final ctx = _itemKeys[i].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 80),
        );
      }
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_enabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;

    if (!_open) {
      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.arrowDown ||
          key == LogicalKeyboardKey.arrowUp) {
        _openMenu();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.escape) {
      _closeMenu();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      _closeMenu();
      return KeyEventResult.ignored; // let focus move on
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _highlight.value = _nextEnabled(_highlight.value, 1);
      _scrollToHighlight();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _highlight.value = _nextEnabled(_highlight.value, -1);
      _scrollToHighlight();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _highlight.value = _nextEnabled(-1, 1);
      _scrollToHighlight();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _highlight.value = _nextEnabled(0, -1);
      _scrollToHighlight();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      final i = _highlight.value;
      if (i >= 0 && i < widget.items.length && widget.items[i].enabled) {
        _select(widget.items[i].value);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void didUpdateWidget(covariant HSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_open && !_enabled) {
      _closeMenu();
      return;
    }
    // The popover lives in the root Overlay, so it won't rebuild on its own
    // when the selection changes (multi-select). Nudge it after this frame.
    if (_entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _entry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _removeEntry();
    _anim.dispose();
    _highlight.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Size / style tokens
  // ---------------------------------------------------------------------------

  double _height(HSelectSize s) => switch (s) {
    HSelectSize.sm => 32,
    HSelectSize.md => 40,
    HSelectSize.lg => 48,
  };

  double _radiusFor(HSelectSize s) =>
      widget.radius ??
      switch (s) {
        HSelectSize.sm => kBorderRadiusSmall,
        HSelectSize.md => kBorderRadiusMedium,
        HSelectSize.lg => kBorderRadius,
      };

  double _valueFont(HSelectSize s) => s == HSelectSize.lg ? 16 : 14;

  // ---------------------------------------------------------------------------
  // Trigger
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = HColors.of(context);
    final size = widget.size;
    final active = _open || _focused;
    final height = _height(size);
    final radius = _radiusFor(size);
    final underlined = widget.variant == HSelectVariant.underlined;

    // ---- Colours per variant ----
    Color? bg;
    Color? borderColor;
    switch (widget.variant) {
      case HSelectVariant.flat:
        bg = (_hovered && !active) ? c.neutral[200]! : c.neutral[100]!;
        borderColor = null;
      case HSelectVariant.faded:
        bg = c.neutral[100]!;
        borderColor = active
            ? c.neutral[400]!
            : (_hovered ? c.neutral[300]! : c.neutral[200]!);
      case HSelectVariant.bordered:
        bg = null;
        borderColor = active
            ? c.foreground
            : (_hovered ? c.neutral[400]! : c.neutral[200]!);
      case HSelectVariant.underlined:
        bg = null;
        borderColor = active
            ? c.foreground
            : (_hovered ? c.neutral[300]! : c.neutral[200]!);
    }
    if (_invalid) borderColor = c.danger.base;
    if (_invalid && widget.variant == HSelectVariant.flat) {
      bg = Color.alphaBlend(
        c.danger.base.withValues(alpha: 0.1),
        c.neutral[100]!,
      );
    }

    final valueFont = _valueFont(size);

    // ---- Value ----
    final text = _valueText;
    final valueWidget = Text(
      text ?? widget.placeholder ?? '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: valueFont,
        height: 1.3,
        color: text != null ? c.foreground : c.mutedForeground,
      ),
    );

    final trigger = MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: CompositedTransformTarget(
        link: _link,
        child: Focus(
          focusNode: _focusNode,
          canRequestFocus: _enabled,
          onKeyEvent: _onKey,
          onFocusChange: (f) => setState(() => _focused = f),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _enabled
                ? () {
                    _focusNode.requestFocus();
                    _toggle();
                  }
                : null,
            child: AnimatedContainer(
              key: _triggerKey,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              height: height,
              padding: EdgeInsets.symmetric(
                horizontal: underlined ? 0 : (size == HSelectSize.sm ? 10 : 12),
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: underlined ? null : BorderRadius.circular(radius),
                border: borderColor == null
                    ? null
                    : underlined
                    ? Border(bottom: BorderSide(color: borderColor, width: 2))
                    : Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  if (widget.startContent != null) ...[
                    IconTheme(
                      data: IconThemeData(color: c.mutedForeground, size: 20),
                      child: widget.startContent!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: valueWidget,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: c.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final helper = _invalid ? widget.errorText : widget.description;

    return SizedBox(
      width: widget.width ?? double.infinity,
      child: Opacity(
        opacity: widget.isDisabled ? 0.5 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _invalid ? c.danger.base : c.foreground,
                  ),
                  child: _labelText(c),
                ),
              ),
            trigger,
            if (helper != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                child: Text(
                  helper,
                  style: TextStyle(
                    fontSize: 12,
                    color: _invalid ? c.danger.base : c.mutedForeground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _labelText(HColors c) {
    final label = widget.label!;
    if (!widget.isRequired) {
      return Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(color: c.danger.base),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ---------------------------------------------------------------------------
  // Popover
  // ---------------------------------------------------------------------------

  Widget _buildOverlay(BuildContext overlayContext) {
    final radius = _radiusFor(widget.size);
    final curved = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);

    return Builder(
      builder: (context) {
        final c = HColors.of(context);
        return Stack(
          children: [
            // Click-away barrier.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeMenu,
                onSecondaryTap: _closeMenu,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              width: _triggerWidth,
              child: CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                targetAnchor: _above ? Alignment.topLeft : Alignment.bottomLeft,
                followerAnchor: _above
                    ? Alignment.bottomLeft
                    : Alignment.topLeft,
                offset: Offset(0, _above ? -6 : 0),
                child: FadeTransition(
                  opacity: curved,
                  child: ScaleTransition(
                    alignment: _above
                        ? Alignment.bottomCenter
                        : Alignment.topCenter,
                    scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
                    child: _buildMenu(c, radius),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenu(HColors c, double radius) {
    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.content1,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: c.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: c.shadow.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: _menuMaxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              child: ValueListenableBuilder<int>(
                valueListenable: _highlight,
                builder: (context, highlighted, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 2,
                    children: [
                      for (var i = 0; i < widget.items.length; i++)
                        _OptionTile<T>(
                          key: _itemKeys[i],
                          item: widget.items[i],
                          selected: _isSelected(widget.items[i].value),
                          highlighted: i == highlighted,
                          radius: math.max(radius - 4, 4),
                          onHover: () => _highlight.value = i,
                          onTap: () => _select(widget.items[i].value),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One row in the popover list.
class _OptionTile<T> extends StatelessWidget {
  const _OptionTile({
    super.key,
    required this.item,
    required this.selected,
    required this.highlighted,
    required this.radius,
    required this.onHover,
    required this.onTap,
  });

  final HSelectItem<T> item;
  final bool selected;
  final bool highlighted;
  final double radius;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HColors.of(context);

    final leading =
        item.leading ??
        (item.icon != null
            ? Icon(item.icon, size: 20, color: c.mutedForeground)
            : null);

    return MouseRegion(
      cursor: item.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: item.enabled ? (_) => onHover() : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: item.enabled ? onTap : null,
        child: Opacity(
          opacity: item.enabled ? 1 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (highlighted && item.enabled) ? c.neutral[200]! : null,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading, const SizedBox(width: 10)],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: c.foreground,
                        ),
                      ),
                      if (item.description != null)
                        Text(
                          item.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: c.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.check_rounded, size: 18, color: c.primary.base),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
