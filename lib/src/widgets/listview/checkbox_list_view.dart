part of 'package:hornbill/src/widgets/m_list_widgets.dart';

/// The data for a single row rendered by [MCheckboxListView].
@immutable
class MCheckboxListItemData {
  /// Creates the data for one [MCheckboxListView] row.
  const MCheckboxListItemData({
    required this.title,
    required this.subtitle,
    required this.value,
    this.leading,
    this.suffix,
  });

  /// The row's primary text.
  final String title;

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
/// Mirrors [MListView]'s two construction styles:
///
///  * [MCheckboxListView.new] for an eagerly-built `items` list.
///  * [MCheckboxListView.builder] for lazily-built rows.
///
/// [onChanged] is called with the toggled row's index and its new value —
/// callers are expected to own and update the underlying data (e.g. in a
/// `List<MCheckboxListItemData>` held in state).
///
/// Example:
/// ```dart
/// MCheckboxListView(
///   items: options,
///   onChanged: (index, value) => setState(() {
///     options[index] = MCheckboxListItemData(
///       title: options[index].title,
///       subtitle: options[index].subtitle,
///       value: value,
///     );
///   }),
/// )
/// ```
class MCheckboxListView extends StatelessWidget {
  /// Creates a grouped checkbox list from an eagerly-built [items] list.
  const MCheckboxListView({
    super.key,
    required List<MCheckboxListItemData> this.items,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
  }) : itemCount = null,
       itemBuilder = null;

  /// Creates a grouped checkbox list that builds its [itemCount] rows
  /// lazily via [itemBuilder], analogous to [ListView.builder].
  const MCheckboxListView.builder({
    super.key,
    required int this.itemCount,
    required MCheckboxListItemData Function(int index) this.itemBuilder,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
  }) : items = null;

  /// The rows to render, when constructed via [MCheckboxListView.new].
  final List<MCheckboxListItemData>? items;

  /// The number of rows to render, when constructed via
  /// [MCheckboxListView.builder].
  final int? itemCount;

  /// Builds the row at the given index, when constructed via
  /// [MCheckboxListView.builder].
  final MCheckboxListItemData Function(int index)? itemBuilder;

  /// Called with a row's index and its new checked state when the user
  /// toggles it.
  final void Function(int index, bool value) onChanged;

  /// Whether the list can be scrolled independently of its parent.
  ///
  /// See [MListView.enableScroll] for details; the default is the same.
  final bool? enableScroll;

  /// Whether the list should size itself to its content.
  ///
  /// See [MListView.shrinkWrap] for details; the default is the same.
  final bool? shrinkWrap;

  /// The number of rows this list will render, regardless of which
  /// constructor was used.
  int get _count => items?.length ?? itemCount!;

  /// The row data at [index], regardless of which constructor was used.
  MCheckboxListItemData _itemAt(int index) =>
      items != null ? items![index] : itemBuilder!(index);

  @override
  Widget build(BuildContext context) {
    final count = _count;
    return ListView.separated(
      shrinkWrap: _resolveShrinkWrap(shrinkWrap),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      physics: _resolvePhysics(enableScroll),
      itemCount: count,
      itemBuilder: (context, index) {
        final item = _itemAt(index);
        return _ListCard(
          key: ValueKey('${item.title}_$index'),
          index: index,
          itemCount: count,
          child: CheckboxListTile(
            contentPadding: const EdgeInsets.only(left: 16.0, right: 4.0),
            title: Text(item.title),
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
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const SizedBox(height: _kItemSpacing),
    );
  }
}
