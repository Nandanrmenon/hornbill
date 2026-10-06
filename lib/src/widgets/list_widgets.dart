/// Rounded, grouped list widgets for Flutter.
///
/// Rows are rendered as a single visually-grouped "card": small corners
/// between rows, large corners at the very top and bottom. Common in settings
/// screens and grouped forms.
///
/// ## One list, one tile
///
///  * [HListView] is the only list widget. Construct it eagerly with
///    [HListView.new] or lazily with [HListView.builder].
///  * [HListTile] is the only row type. It has three flavours:
///    - `HListTile(...)`           plain row (tap, leading, suffix, ...)
///    - `HListTile.radio<T>(...)`  single-select row
///    - `HListTile.checkbox(...)`  multi-select row
///    The same tile can be used standalone, outside a list.
///  * [HListHeader] labels a group.
///
/// ```dart
/// HListView(
///   items: [
///     HListTile(title: Text('Wi-Fi'), subtitle: Text('Connected')),
///     HListTile.radio<String>(
///       title: Text('Small'),
///       value: 's',
///       groupValue: size,
///       onChanged: (v) => setState(() => size = v),
///     ),
///     HListTile.checkbox(
///       title: Text('Notifications'),
///       value: enabled,
///       onChanged: (v) => setState(() => enabled = v),
///     ),
///   ],
/// )
/// ```
///
/// [HRadioListView] and [HCheckboxListView] remain as thin wrappers over
/// [HListView] so existing call sites keep working.
///
/// Nothing here uses Material's ListTile, Material, InkWell or ColorScheme;
/// all colours come from [HColors].
library;

import 'package:hornbill/src/theme.dart';
import 'package:material_ui/material_ui.dart';

// -----------------------------------------------------------------------------
// Card chrome
// -----------------------------------------------------------------------------

/// Corner radius applied to the first and last item in a grouped list.
const double _kOuterRadius = 12.0;

/// Corner radius applied to items in the middle of a grouped list.
const double _kInnerRadius = 4.0;

/// Vertical gap between consecutive rows.
const double _kItemSpacing = 4.0;

BorderRadius _cardRadius(int index, int itemCount) {
  final isFirst = index == 0;
  final isLast = index == itemCount - 1;
  return BorderRadius.only(
    topLeft: Radius.circular(isFirst ? _kOuterRadius : _kInnerRadius),
    topRight: Radius.circular(isFirst ? _kOuterRadius : _kInnerRadius),
    bottomLeft: Radius.circular(isLast ? _kOuterRadius : _kInnerRadius),
    bottomRight: Radius.circular(isLast ? _kOuterRadius : _kInnerRadius),
  );
}

/// Clipped, rounded background shared by every row.
class _ListCard extends StatelessWidget {
  const _ListCard({
    super.key,
    required this.index,
    required this.itemCount,
    required this.child,
    this.tint,
  });

  final int index;
  final int itemCount;

  /// Optional accent colour, blended lightly over the card colour.
  final Color? tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = HColors.of(context);
    final base = c.backgroundStrong;
    return ClipRRect(
      borderRadius: _cardRadius(index, itemCount),
      child: ColoredBox(
        color: tint == null
            ? base
            : Color.alphaBlend(tint!.withValues(alpha: 0.2), base),
        child: child,
      ),
    );
  }
}

bool _resolveShrinkWrap(bool? shrinkWrap) => shrinkWrap ?? true;

ScrollPhysics _resolvePhysics(bool? enableScroll) => (enableScroll ?? false)
    ? const AlwaysScrollableScrollPhysics()
    : const NeverScrollableScrollPhysics();

EdgeInsets _listPadding(bool dense) => dense
    ? const EdgeInsets.all(8)
    : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

// -----------------------------------------------------------------------------
// Header
// -----------------------------------------------------------------------------

/// A small section header, placed above an [HListView] to label the group.
class HListHeader extends StatelessWidget {
  const HListHeader({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.dense,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Called when the header is tapped. If null the header isn't interactive.
  final VoidCallback? onTap;

  /// Widget at the end of the header (an action button, "See all", ...).
  final Widget? trailing;

  /// Tightens the header's padding.
  final bool? dense;

  /// Overrides the header's padding (e.g. to match an [HListView] that uses
  /// custom padding).
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final muted = HColors.of(context).mutedForeground;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: padding ?? _listPadding(dense == true),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: muted),
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
                      color: muted,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: muted.withValues(alpha: 0.7),
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

// -----------------------------------------------------------------------------
// Tile
// -----------------------------------------------------------------------------

/// A single row. Works standalone or inside an [HListView].
///
/// Flavours: the default constructor (plain), [HListTile.radio] and
/// [HListTile.checkbox].
class HListTile extends StatelessWidget {
  /// A plain row.
  const HListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onLongPress,
    this.leading,
    this.suffix,
    this.selected = false,
    this.color,
    this.dense,
  }) : _control = null;

  const HListTile._({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    this.suffix,
    this.color,
    this.dense,
    required Widget control,
  }) : onLongPress = null,
       selected = false,
       _control = control;

  /// A single-select row. Selected when [value] equals [groupValue]; tapping
  /// calls [onChanged] with [value]. Put several of these in one [HListView]
  /// sharing the same [groupValue].
  static HListTile radio<T>({
    Key? key,
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? suffix,
    required T value,
    required T groupValue,
    required ValueChanged<T> onChanged,
    Color? color,
    bool? dense,
  }) => HListTile._(
    key: key,
    title: title,
    subtitle: subtitle,
    leading: leading,
    suffix: suffix,
    color: color,
    dense: dense,
    onTap: () => onChanged(value),
    control: _RadioDot(selected: value == groupValue),
  );

  /// A multi-select row. Tapping calls [onChanged] with the toggled value.
  factory HListTile.checkbox({
    Key? key,
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? suffix,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? color,
    bool? dense,
  }) => HListTile._(
    key: key,
    title: title,
    subtitle: subtitle,
    leading: leading,
    suffix: suffix,
    color: color,
    dense: dense,
    onTap: () => onChanged(!value),
    control: _CheckBox(checked: value),
  );

  /// Primary text.
  final Widget title;

  /// Secondary text. Null means no subtitle space is reserved.
  final Widget? subtitle;

  /// Called on tap. If null (and no long press) the row isn't interactive.
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Widget at the start of the row (an [Icon], avatar, ...).
  final Widget? leading;

  /// Widget at the end of the row (a switch, chevron, trailing icon, ...).
  final Widget? suffix;

  /// Renders the row in its selected state (accent-coloured text and icons).
  final bool selected;

  /// Optional accent colour: tints the card background and is used as the
  /// selected colour. Defaults to the theme's primary colour for selection.
  final Color? color;

  /// Compact layout.
  final bool? dense;

  /// Radio / checkbox indicator, shown before [leading].
  final Widget? _control;

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      index: 0,
      itemCount: 1,
      tint: color,
      child: _TileRow(tile: this),
    );
  }
}

/// Compatibility alias for [HListTile].
typedef HListItemData = HListTile;

/// The row content of an [HListTile].
///
/// This is a real widget (not a method called with someone else's context) so
/// that it reads [HColors] with *its own* BuildContext. That way it registers
/// itself as a dependent of the theme and is rebuilt whenever the theme
/// changes, instead of keeping colours baked in by a parent's earlier build.
class _TileRow extends StatelessWidget {
  const _TileRow({required this.tile, this.denseOverride});

  final HListTile tile;
  final bool? denseOverride;

  @override
  Widget build(BuildContext context) {
    final c = HColors.of(context);
    final isDense = denseOverride ?? tile.dense ?? false;
    final accent = tile.color ?? c.primary.base;
    final selected = tile.selected;
    final fg = selected ? accent : c.foreground;
    final subFg = selected ? accent.withValues(alpha: 0.8) : c.mutedForeground;
    final hasSubtitle = tile.subtitle != null;
    final vPad = isDense ? 8.0 : (hasSubtitle ? 12.0 : 14.0);
    final control = tile._control;

    final row = Padding(
      padding: EdgeInsets.fromLTRB(16, vPad, 16, vPad),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: isDense ? 32 : 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (control != null) ...[control, const SizedBox(width: 16)],
            if (tile.leading != null) ...[
              IconTheme(
                data: IconThemeData(color: fg, size: 24),
                child: tile.leading!,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: isDense ? 14 : 16,
                      fontWeight: FontWeight.w500,
                      color: fg,
                    ),
                    child: tile.title,
                  ),
                  if (hasSubtitle)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: isDense ? 12 : 14,
                          color: subFg,
                        ),
                        child: tile.subtitle!,
                      ),
                    ),
                ],
              ),
            ),
            if (tile.suffix != null) ...[
              const SizedBox(width: 16),
              IconTheme(
                data: IconThemeData(
                  color: selected ? fg : c.mutedForeground,
                  size: 24,
                ),
                child: tile.suffix!,
              ),
            ],
          ],
        ),
      ),
    );

    return _TileSurface(
      onTap: tile.onTap,
      onLongPress: tile.onLongPress,
      child: row,
    );
  }
}

/// Hover / press feedback, without Material's InkWell.
class _TileSurface extends StatefulWidget {
  const _TileSurface({
    required this.child,
    required this.onTap,
    required this.onLongPress,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<_TileSurface> createState() => _TileSurfaceState();
}

class _TileSurfaceState extends State<_TileSurface> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;
    final fg = HColors.of(context).foreground;
    final overlay = _pressed
        ? fg.withValues(alpha: 0.08)
        : _hovered
        ? fg.withValues(alpha: 0.04)
        : const Color(0x00000000);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: overlay,
          child: widget.child,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Radio / checkbox indicators
// -----------------------------------------------------------------------------

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = HColors.of(context);
    const duration = Duration(milliseconds: 150);
    return AnimatedContainer(
      duration: duration,
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.primary.base : c.borderStrong,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: duration,
        curve: Curves.easeOutBack,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.primary.base,
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final c = HColors.of(context);
    const duration = Duration(milliseconds: 150);
    return AnimatedContainer(
      duration: duration,
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: checked ? c.primary.base : const Color(0x00000000),
        border: Border.all(
          color: checked ? c.primary.base : c.borderStrong,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: checked ? 1 : 0,
        duration: duration,
        curve: Curves.easeOutBack,
        child: Icon(Icons.check_rounded, size: 16, color: c.primary.onBase),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// List
// -----------------------------------------------------------------------------

/// A grouped, rounded-corner list of [HListTile] rows.
///
///  * [HListView.new]: you already have the rows.
///  * [HListView.builder]: rows are generated on demand.
///
/// Rows can freely mix plain, radio and checkbox tiles.
class HListView extends StatelessWidget {
  const HListView({
    super.key,
    required List<HListTile> this.items,
    this.enableScroll,
    this.shrinkWrap,
    this.dense,
    this.padding,
  }) : itemCount = null,
       itemBuilder = null;

  const HListView.builder({
    super.key,
    required int this.itemCount,
    required HListTile Function(int index) this.itemBuilder,
    this.enableScroll,
    this.shrinkWrap,
    this.dense,
    this.padding,
  }) : items = null;

  /// Rows when constructed via [HListView.new].
  final List<HListTile>? items;

  /// Row count when constructed via [HListView.builder].
  final int? itemCount;

  /// Row builder when constructed via [HListView.builder].
  final HListTile Function(int index)? itemBuilder;

  /// Whether the list scrolls on its own. Default `false` (it is usually
  /// nested in a scrollable parent).
  final bool? enableScroll;

  /// Whether the list sizes itself to its content. Default `true`.
  final bool? shrinkWrap;

  /// Compact rows and tighter outer padding. Default `false`.
  final bool? dense;

  /// Outer padding around the list. Overrides the default (16 horizontal /
  /// 8 vertical, or 8 all round when [dense]). Use `EdgeInsets.zero` for none,
  /// or e.g. `EdgeInsets.symmetric(vertical: 8)` to drop only the horizontal
  /// padding.
  final EdgeInsetsGeometry? padding;

  int get _count => items?.length ?? itemCount!;

  HListTile _itemAt(int index) =>
      items != null ? items![index] : itemBuilder!(index);

  @override
  Widget build(BuildContext context) {
    final count = _count;
    return ListView.separated(
      shrinkWrap: _resolveShrinkWrap(shrinkWrap),
      padding: padding ?? _listPadding(dense ?? false),
      physics: _resolvePhysics(enableScroll),
      itemCount: count,
      itemBuilder: (context, index) {
        final item = _itemAt(index);
        return _ListCard(
          key: item.key ?? ValueKey(index),
          index: index,
          itemCount: count,
          tint: item.color,
          child: _TileRow(tile: item, denseOverride: dense),
        );
      },
      separatorBuilder: (context, index) =>
          const SizedBox(height: _kItemSpacing),
    );
  }
}

// -----------------------------------------------------------------------------
// Compatibility wrappers
// -----------------------------------------------------------------------------

/// The data for a single row of [HRadioListView].
@immutable
class HRadioListItemData<T> {
  const HRadioListItemData({
    required this.title,
    required this.subtitle,
    required this.value,
    this.leading,
    this.suffix,
  });

  final Widget title;

  /// Pass an empty string to omit it.
  final String subtitle;
  final T value;
  final Widget? leading;
  final Widget? suffix;
}

/// Thin wrapper over [HListView] + [HListTile.radio].
class HRadioListView<T> extends StatelessWidget {
  const HRadioListView({
    super.key,
    required List<HRadioListItemData<T>> this.items,
    required this.groupValue,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
    this.dense,
    this.padding,
  }) : itemCount = null,
       itemBuilder = null;

  const HRadioListView.builder({
    super.key,
    required int this.itemCount,
    required HRadioListItemData<T> Function(int index) this.itemBuilder,
    required this.groupValue,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
    this.dense,
    this.padding,
  }) : items = null;

  final List<HRadioListItemData<T>>? items;
  final int? itemCount;
  final HRadioListItemData<T> Function(int index)? itemBuilder;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final bool? enableScroll;
  final bool? shrinkWrap;
  final bool? dense;

  /// Outer padding around the list. See [HListView.padding].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return HListView.builder(
      itemCount: items?.length ?? itemCount!,
      enableScroll: enableScroll,
      shrinkWrap: shrinkWrap,
      dense: dense,
      padding: padding,
      itemBuilder: (i) {
        final d = items != null ? items![i] : itemBuilder!(i);
        return HListTile.radio<T>(
          title: d.title,
          subtitle: d.subtitle.isNotEmpty
              ? Text(d.subtitle, maxLines: 2)
              : null,
          leading: d.leading,
          suffix: d.suffix,
          value: d.value,
          groupValue: groupValue,
          onChanged: onChanged,
        );
      },
    );
  }
}

/// The data for a single row of [HCheckboxListView].
@immutable
class HCheckboxListItemData {
  const HCheckboxListItemData({
    required this.title,
    required this.subtitle,
    required this.value,
    this.leading,
    this.suffix,
  });

  final Widget title;

  /// Pass an empty string to omit it.
  final String subtitle;
  final bool value;
  final Widget? leading;
  final Widget? suffix;
}

/// Thin wrapper over [HListView] + [HListTile.checkbox].
///
/// [onChanged] receives the toggled row's index and new value; the caller
/// owns the data.
class HCheckboxListView extends StatelessWidget {
  const HCheckboxListView({
    super.key,
    required List<HCheckboxListItemData> this.items,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
    this.dense,
    this.padding,
  }) : itemCount = null,
       itemBuilder = null;

  const HCheckboxListView.builder({
    super.key,
    required int this.itemCount,
    required HCheckboxListItemData Function(int index) this.itemBuilder,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
    this.dense,
    this.padding,
  }) : items = null;

  final List<HCheckboxListItemData>? items;
  final int? itemCount;
  final HCheckboxListItemData Function(int index)? itemBuilder;
  final void Function(int index, bool value) onChanged;
  final bool? enableScroll;
  final bool? shrinkWrap;
  final bool? dense;

  /// Outer padding around the list. See [HListView.padding].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return HListView.builder(
      itemCount: items?.length ?? itemCount!,
      enableScroll: enableScroll,
      shrinkWrap: shrinkWrap,
      dense: dense,
      padding: padding,
      itemBuilder: (i) {
        final d = items != null ? items![i] : itemBuilder!(i);
        return HListTile.checkbox(
          title: d.title,
          subtitle: d.subtitle.isNotEmpty
              ? Text(d.subtitle, maxLines: 2)
              : null,
          leading: d.leading,
          suffix: d.suffix,
          value: d.value,
          onChanged: (v) => onChanged(i, v),
        );
      },
    );
  }
}
