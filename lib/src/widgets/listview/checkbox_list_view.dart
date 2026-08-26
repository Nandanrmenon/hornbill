part of 'package:hornbill/src/widgets/list_widgets.dart';

/// The data for a single row rendered by [HCheckboxListView].
@immutable
class HCheckboxListItemData {
  /// Creates the data for one [HCheckboxListView] row.
  const HCheckboxListItemData({
    required this.title,
    required this.subtitle,
    required this.value,
    this.leading,
    this.suffix,
  });

  /// The row's primary text.
  final Widget title;

  /// The row's secondary text. Pass an empty string to omit it.
  final String subtitle;

  /// Whether this row's checkbox is checked.
  final bool value;

  /// Reserved for a future leading widget. Not currently rendered — see
  /// [suffix] for the widget slot `CheckboxListTile` actually exposes.
  final Widget? leading;

  /// Widget shown alongside the checkbox (`CheckboxListTile.secondary`),
  /// e.g. an [Icon].
  final Widget? suffix;
}

/// A grouped, rounded-corner, multi-select checkbox list.
///
/// Mirrors [HListView]'s two construction styles:
///
///  * [HCheckboxListView.new] for an eagerly-built `items` list.
///  * [HCheckboxListView.builder] for lazily-built rows.
///
/// [onChanged] is called with the toggled row's index and its new value —
/// callers are expected to own and update the underlying data (e.g. in a
/// `List<HCheckboxListItemData>` held in state).
///
/// Example:
/// ```dart
/// HCheckboxListView(
///   items: options,
///   onChanged: (index, value) => setState(() {
///     options[index] = HCheckboxListItemData(
///       title: options[index].title,
///       subtitle: options[index].subtitle,
///       value: value,
///     );
///   }),
/// )
/// ```
class HCheckboxListView extends StatelessWidget {
  /// Creates a grouped checkbox list from an eagerly-built [items] list.
  const HCheckboxListView({
    super.key,
    required List<HCheckboxListItemData> this.items,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
    this.dense,
  }) : itemCount = null,
       itemBuilder = null;

  /// Creates a grouped checkbox list that builds its [itemCount] rows
  /// lazily via [itemBuilder], analogous to [ListView.builder].
  const HCheckboxListView.builder({
    super.key,
    required int this.itemCount,
    required HCheckboxListItemData Function(int index) this.itemBuilder,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
    this.dense,
  }) : items = null;

  /// The rows to render, when constructed via [HCheckboxListView.new].
  final List<HCheckboxListItemData>? items;

  /// The number of rows to render, when constructed via
  /// [HCheckboxListView.builder].
  final int? itemCount;

  /// Builds the row at the given index, when constructed via
  /// [HCheckboxListView.builder].
  final HCheckboxListItemData Function(int index)? itemBuilder;

  /// Called with a row's index and its new checked state when the user
  /// toggles it.
  final void Function(int index, bool value) onChanged;

  /// Whether the list can be scrolled independently of its parent.
  ///
  /// See [HListView.enableScroll] for details; the default is the same.
  final bool? enableScroll;

  /// Whether the list should size itself to its content.
  ///
  /// See [HListView.shrinkWrap] for details; the default is the same.
  final bool? shrinkWrap;

  /// Whether rows use the compact/"dense" [ListTile] layout.
  ///
  /// Defaults to `false`. Also tightens the list's outer padding.
  final bool? dense;

  /// The number of rows this list will render, regardless of which
  /// constructor was used.
  int get _count => items?.length ?? itemCount!;

  /// The row data at [index], regardless of which constructor was used.
  HCheckboxListItemData _itemAt(int index) =>
      items != null ? items![index] : itemBuilder!(index);

  @override
  Widget build(BuildContext context) {
    final isDense = dense ?? false;
    final count = _count;
    return ListView.separated(
      shrinkWrap: _resolveShrinkWrap(shrinkWrap),
      padding: isDense
          ? const EdgeInsets.all(8)
          : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      physics: _resolvePhysics(enableScroll),
      itemCount: count,
      itemBuilder: (context, index) {
        final item = _itemAt(index);
        return _ListCard(
          key: ValueKey('${item.title}_$index'),
          index: index,
          itemCount: count,
          child: CheckboxListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            contentPadding: const EdgeInsets.only(left: 16.0, right: 4.0),
            title: item.title,
            subtitle: item.subtitle.isNotEmpty
                ? Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            value: item.value,
            onChanged: (value) {
              if (value != null) onChanged(index, value);
            },
            secondary: item.suffix,
            dense: dense,
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const SizedBox(height: _kItemSpacing),
    );
  }
}
