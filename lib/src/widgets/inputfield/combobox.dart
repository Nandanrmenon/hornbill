import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:hornbill/hornbill.dart'
    show
        HColors,
        HSelectItem,
        HSelectLabelPlacement,
        HSelectSize,
        HSelectVariant;
import 'package:material_ui/material_ui.dart';

/// A HeroUI-style combo box: an [HSelect] you can type into to search.
///
///  * type to filter the list (case-insensitive "contains" on the label, or
///    pass your own [filter] / [onInputChanged] for async search)
///  * pick an option with the mouse, or with Arrow keys + Enter
///  * a clear button, a chevron toggle, and a "No results" state
///  * the same variants, sizes, label placement, description, error and
///    popover as [HSelect] (it reuses [HSelectItem], [HSelectVariant],
///    [HSelectSize] and [HSelectLabelPlacement])
///
/// While you are typing, the list is filtered. If you close the menu without
/// choosing, the text snaps back to the current selection.
///
/// The field fills the available width. Inside a `Row`, wrap it in `Expanded`
/// or pass [width].
///
/// ```dart
/// HComboBox<String>(
///   label: 'Country',
///   placeholder: 'Search a country',
///   value: country,
///   onChanged: (v) => setState(() => country = v),
///   items: const [
///     HSelectItem(value: 'in', label: 'India'),
///     HSelectItem(value: 'us', label: 'United States'),
///   ],
/// )
/// ```
class HComboBox<T> extends StatefulWidget {
  const HComboBox({
    super.key,
    required this.items,
    this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.description,
    this.errorText,
    this.variant = HSelectVariant.flat,
    this.size,
    this.labelPlacement = HSelectLabelPlacement.inside,
    this.radius,
    this.isRequired = false,
    this.isDisabled = false,
    this.isClearable = true,
    this.startContent,
    this.width,
    this.maxMenuHeight = 256,
    this.emptyText = 'No results found',
    this.filter,
    this.onInputChanged,
  });

  final List<HSelectItem<T>> items;

  /// The selected value, or null for none.
  final T? value;

  /// Called with the chosen value, or `null` when the user clears the field.
  /// Passing a null callback disables the field.
  final ValueChanged<T?>? onChanged;

  final String? label;
  final String? placeholder;
  final String? description;

  /// When non-null the field is invalid: red border and this message.
  final String? errorText;

  final HSelectVariant variant;

  /// sm / md / lg. Null (default) adapts: sm on desktop and wide screens,
  /// md on mobile.
  final HSelectSize? size;

  final HSelectLabelPlacement labelPlacement;

  /// Overrides the field and menu corner radius (sm 8, md 12, lg 14).
  final double? radius;

  final bool isRequired;
  final bool isDisabled;

  /// Shows an x button when there is a selection or text.
  final bool isClearable;

  final Widget? startContent;
  final double? width;
  final double maxMenuHeight;

  /// Text shown when the search matches nothing.
  final String emptyText;

  /// Custom matching. Defaults to a case-insensitive "contains" on the label.
  final bool Function(HSelectItem<T> item, String query)? filter;

  /// Called on every keystroke, e.g. to load results from a server. Update
  /// [items] in response.
  final ValueChanged<String>? onInputChanged;

  @override
  State<HComboBox<T>> createState() => _HComboBoxState<T>();
}

class _HComboBoxState<T> extends State<HComboBox<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();

  /// Shared by the field, its TextField and the popover so a click inside any
  /// of them is "inside" (and does not unfocus or close).
  final Object _tapGroup = Object();

  late final FocusNode _focusNode = FocusNode(onKeyEvent: _onKey);
  late final FocusNode _searchFocusNode = FocusNode(onKeyEvent: _onKey);
  final TextEditingController _text = TextEditingController();

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    reverseDuration: const Duration(milliseconds: 120),
  );

  OverlayEntry? _entry;
  bool _open = false;
  bool _hovered = false;
  bool _focused = false;

  /// True once the user edits the text; until then the list shows everything.
  bool _typing = false;

  final ValueNotifier<int> _highlight = ValueNotifier<int>(-1);
  final List<GlobalKey> _itemKeys = [];

  double _triggerWidth = 0;
  bool _above = false;
  double _menuMaxHeight = 256;

  // ---------------------------------------------------------------------------
  // Derived state
  // ---------------------------------------------------------------------------

  bool get _enabled => !widget.isDisabled && widget.onChanged != null;
  bool get _invalid => widget.errorText != null;

  HSelectItem<T>? get _selectedItem {
    final v = widget.value;
    if (v == null) return null;
    for (final i in widget.items) {
      if (i.value == v) return i;
    }
    return null;
  }

  String? get _selectedLabel => _selectedItem?.label;

  List<HSelectItem<T>> get _filtered {
    if (!_typing) return widget.items;
    final query = _text.text.trim();
    if (query.isEmpty) return widget.items;
    final match =
        widget.filter ??
        (HSelectItem<T> item, String q) =>
            item.label.toLowerCase().contains(q.toLowerCase());
    return [
      for (final i in widget.items)
        if (match(i, query)) i,
    ];
  }

  HSelectSize _resolveSize(BuildContext context) {
    final explicit = widget.size;
    if (explicit != null) return explicit;
    final isNativeDesktop =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux);
    final isWideWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 600;
    return (isNativeDesktop || isWideWeb) ? HSelectSize.sm : HSelectSize.md;
  }

  bool get _insideLabel =>
      widget.label != null &&
      widget.labelPlacement == HSelectLabelPlacement.inside;

  double _height(HSelectSize s) {
    final inside = _insideLabel;
    return switch (s) {
      HSelectSize.sm => inside ? 48 : 32,
      HSelectSize.md => inside ? 56 : 40,
      HSelectSize.lg => inside ? 64 : 48,
    };
  }

  double _radiusFor(HSelectSize s) =>
      widget.radius ??
      switch (s) {
        HSelectSize.sm => 8,
        HSelectSize.md => 12,
        HSelectSize.lg => 14,
      };

  double _valueFont(HSelectSize s) => s == HSelectSize.lg ? 16 : 14;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _text.text = _selectedLabel ?? '';
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant HComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_typing && oldWidget.value != widget.value) {
      _setText(_selectedLabel ?? '');
    }
    if (_open && !_enabled) {
      _closeMenu();
      return;
    }
    if (_entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _entry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _removeEntry();
    _anim.dispose();
    _highlight.dispose();
    _focusNode.dispose();
    _searchFocusNode.dispose();
    _text.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _focused = _focusNode.hasFocus);
    if (!_focusNode.hasFocus) _closeMenu();
  }

  void _setText(String value) {
    _text.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  // ---------------------------------------------------------------------------
  // Open / close
  // ---------------------------------------------------------------------------

  void _openMenu() {
    if (_open || !_enabled) return;

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

    // Account for the search field when estimating the menu height.
    final estimated = math.min(
      widget.maxMenuHeight,
      widget.items.length * 40.0 + 56,
    );

    _triggerWidth = size.width;
    _above = estimated > below && above > below;
    _menuMaxHeight = math.max(
      120.0,
      math.min(widget.maxMenuHeight, (_above ? above : below) - 6),
    );

    final list = _filtered;
    final selected = list.indexWhere((i) => widget.value == i.value);
    _highlight.value = selected >= 0 ? selected : _nextEnabled(-1, 1, list);

    _entry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_entry!);

    setState(() => _open = true);
    _anim.forward();

    // The search field lives inside the overlay, so wait until it exists
    // before requesting focus.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _open) {
        _searchFocusNode.requestFocus();
      }
    });

    _scrollToHighlight();
  }

  /// Closes the popover. [resetText] snaps the field back to the selection
  /// (skipped right after a pick, when the text was already set).
  void _closeMenu({bool resetText = true}) {
    if (resetText) {
      _typing = false;
      _setText(_selectedLabel ?? '');
    }
    if (!_open) {
      if (mounted) setState(() {});
      return;
    }
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

  void _toggle() {
    if (_open) {
      _closeMenu();
    } else {
      _focusNode.requestFocus();
      _openMenu();
    }
  }

  void _select(HSelectItem<T> item) {
    if (!item.enabled) return;
    widget.onChanged?.call(item.value);
    _typing = false;
    _setText(item.label);
    _closeMenu(resetText: false);
  }

  void _clear() {
    widget.onChanged?.call(null);
    _typing = false;
    _setText('');
    _focusNode.requestFocus();
    _entry?.markNeedsBuild();
    setState(() {});
  }

  void _onTextChanged(String value) {
    _typing = true;
    widget.onInputChanged?.call(value);
    if (!_open) {
      _openMenu();
    }
    _highlight.value = _nextEnabled(-1, 1, _filtered);
    _entry?.markNeedsBuild();
    _scrollToHighlight();
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Keyboard
  // ---------------------------------------------------------------------------

  int _nextEnabled(int from, int step, List<HSelectItem<T>> list) {
    final n = list.length;
    if (n == 0) return -1;
    var i = from;
    for (var count = 0; count < n; count++) {
      i = (i + step) % n;
      if (i < 0) i += n;
      if (list[i].enabled) return i;
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

  // Attached to the TextField's own FocusNode, so it runs before the text
  // field handles the arrow keys itself.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_enabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      if (!_open) {
        _openMenu();
        return KeyEventResult.handled;
      }
      final list = _filtered;
      _highlight.value = _nextEnabled(
        _highlight.value,
        key == LogicalKeyboardKey.arrowDown ? 1 : -1,
        list,
      );
      _scrollToHighlight();
      return KeyEventResult.handled;
    }

    if (!_open) return KeyEventResult.ignored;

    if (key == LogicalKeyboardKey.escape) {
      _closeMenu();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      _closeMenu();
      return KeyEventResult.ignored; // let focus move on
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      final list = _filtered;
      final i = _highlight.value;
      if (i >= 0 && i < list.length && list[i].enabled) {
        _select(list[i]);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // ---------------------------------------------------------------------------
  // Field
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = HColors.of(context);
    final size = _resolveSize(context);
    final active = _open || _focused;
    final height = _height(size);
    final radius = _radiusFor(size);
    final underlined = widget.variant == HSelectVariant.underlined;

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

    final labelColor = _invalid
        ? c.danger.base
        : (active ? c.foreground : c.neutral[600]!);

    final valueFont = _valueFont(size);
    // final hasText = _text.text.isNotEmpty;
    final hasText = _selectedLabel?.isNotEmpty ?? false;
    final floated = _open || _focused || hasText;

    // final floated = _open || hasText;
    final triggerText =
        _selectedLabel ?? (_open ? widget.placeholder ?? '' : '');

    final Widget body;
    if (_insideLabel) {
      final floatTop = switch (size) {
        HSelectSize.sm => 6.0,
        HSelectSize.md => 8.0,
        HSelectSize.lg => 10.0,
      };

      body = Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            top: floated ? floatTop : (height - 20) / 2,
            child: IgnorePointer(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: floated ? 12 : valueFont,
                  height: 1.3,
                  color: labelColor,
                ),
                child: _labelText(c),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: floatTop,
            child: Text(
              triggerText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: valueFont,
                height: 1.3,
                color: hasText ? c.foreground : c.mutedForeground,
              ),
            ),
          ),
        ],
      );
    } else {
      body = Align(
        alignment: Alignment.centerLeft,
        child: Text(
          triggerText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: valueFont,
            height: 1.3,
            color: hasText ? c.foreground : c.mutedForeground,
          ),
        ),
      );
    }

    final showClear = widget.isClearable && _enabled && widget.value != null;

    final trigger = MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: CompositedTransformTarget(
        link: _link,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled
              ? () {
                  _focusNode.requestFocus();
                  if (!_open) _openMenu();
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
                Expanded(child: body),
                if (showClear)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _clear,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: c.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _enabled ? _toggle : null,
                  child: MouseRegion(
                    cursor: _enabled
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        child: Icon(
                          Icons.expand_more_rounded,
                          size: 20,
                          color: c.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
        child: TapRegion(
          groupId: _tapGroup,
          onTapOutside: (_) => _closeMenu(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null && !_insideLabel)
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
    final radius = _radiusFor(_resolveSize(context));
    final curved = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);

    return Builder(
      builder: (context) {
        final c = HColors.of(context);
        // No full-screen barrier: clicks outside are detected with TapRegion,
        // so the text field stays clickable while the list is open.
        return Stack(
          children: [
            Positioned(
              width: _triggerWidth,
              child: CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                targetAnchor: _above ? Alignment.topLeft : Alignment.bottomLeft,
                followerAnchor: _above
                    ? Alignment.bottomLeft
                    : Alignment.topLeft,
                offset: Offset(0, _above ? -6 : 6),
                child: TapRegion(
                  groupId: _tapGroup,
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenu(HColors c, double radius) {
    final list = _filtered;

    while (_itemKeys.length < list.length) {
      _itemKeys.add(GlobalKey());
    }

    final searchField = TextField(
      controller: _text,
      focusNode: _searchFocusNode,
      enabled: _enabled,
      groupId: _tapGroup,
      maxLines: 1,
      autocorrect: false,
      enableSuggestions: false,
      cursorColor: c.primary.base,
      style: TextStyle(fontSize: 14, height: 1.3, color: c.foreground),
      decoration: InputDecoration(
        hintText: widget.placeholder ?? 'Search...',
        hintStyle: TextStyle(fontSize: 14, color: c.mutedForeground),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 18,
          color: c.mutedForeground,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
      onChanged: _onTextChanged,
    );

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.neutral[100],
                      borderRadius: BorderRadius.circular(
                        math.max(radius - 4, 4),
                      ),
                    ),
                    child: searchField,
                  ),
                ),
                Flexible(
                  child: list.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: Text(
                            widget.emptyText,
                            style: TextStyle(
                              fontSize: 14,
                              color: c.mutedForeground,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(4),
                          child: ValueListenableBuilder<int>(
                            valueListenable: _highlight,
                            builder: (context, highlighted, _) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: 2,
                                children: [
                                  for (var i = 0; i < list.length; i++)
                                    _ComboOption<T>(
                                      key: _itemKeys[i],
                                      item: list[i],
                                      selected:
                                          widget.value != null &&
                                          widget.value == list[i].value,
                                      highlighted: i == highlighted,
                                      radius: math.max(radius - 4, 4),
                                      onHover: () => _highlight.value = i,
                                      onTap: () => _select(list[i]),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One row in the popover list.
class _ComboOption<T> extends StatelessWidget {
  const _ComboOption({
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
