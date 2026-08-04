part of 'package:hornbill/src/widgets/list_widgets.dart';

/// Corner radius applied to the first and last item in a grouped list.
const double _kOuterRadius = 12.0;

/// Corner radius applied to items in the middle of a grouped list.
const double _kInnerRadius = 4.0;

/// Vertical gap rendered between consecutive items by `ListView.separated`.
const double _kItemSpacing = 4.0;

/// Computes the per-corner rounding for the item at [index] within a list
/// of [itemCount] items.
///
/// Only the first item gets rounded top corners and only the last item
/// gets rounded bottom corners (both using [_kOuterRadius]); every other
/// corner uses the smaller [_kInnerRadius], producing the "grouped card"
/// look shared by every list widget in this package.
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

/// Wraps a single list item's content in the "card" chrome (clipped,
/// rounded corners + surface color) shared by every list widget in this
/// package.
///
/// Centralizing this avoids repeating the same `ClipRRect` + `Material`
/// boilerplate in [HListView], [HRadioListView], and [HCheckboxListView],
/// which previously drifted out of sync with one another.
class _ListCard extends StatelessWidget {
  /// Creates the shared card chrome for one list item.
  const _ListCard({
    super.key,
    required this.index,
    required this.itemCount,
    required this.child,
    this.color,
  });

  /// The zero-based position of this item within its list.
  final int index;

  /// The total number of items in the list. Used together with [index] to
  /// determine whether this item is first/last and should get the larger
  /// outer corner radius.
  final int itemCount;

  /// Background color for this item's card.
  ///
  /// Falls back to `Theme.of(context).colorScheme.surfaceContainerLow`
  /// when null.
  final Color? color;

  /// The content rendered inside the card — typically a `ListTile`,
  /// `RadioListTile`, or `CheckboxListTile`.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _cardRadius(index, itemCount),
      child: Material(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

/// Resolves the effective `shrinkWrap` value for this package's list
/// widgets, defaulting to `true` when [shrinkWrap] is omitted.
bool _resolveShrinkWrap(bool? shrinkWrap) => shrinkWrap ?? true;

/// Resolves the effective `ScrollPhysics` for this package's list widgets.
///
/// Scrolling is disabled (`NeverScrollableScrollPhysics`) unless
/// [enableScroll] is explicitly `true`, matching these widgets' primary use
/// case of being embedded inside an already-scrollable parent.
ScrollPhysics _resolvePhysics(bool? enableScroll) => (enableScroll ?? false)
    ? const AlwaysScrollableScrollPhysics()
    : const NeverScrollableScrollPhysics();
