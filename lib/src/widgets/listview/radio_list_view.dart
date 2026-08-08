part of 'package:hornbill/src/widgets/list_widgets.dart';

/// The data for a single row rendered by [HRadioListView].
@immutable
class HRadioListItemData<T> {
  /// Creates the data for one [HRadioListView] row.
  const HRadioListItemData({
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

  /// The value this row represents. Selected when it equals
  /// `HRadioListView.groupValue`.
  final T value;

  /// Reserved for a future leading widget. Not currently rendered — see
  /// [suffix] for the widget slot `RadioListTile` actually exposes.
  final Widget? leading;

  /// Widget shown alongside the radio control
  /// (`RadioListTile.secondary`), e.g. an [Icon].
  final Widget? suffix;
}

/// A grouped, rounded-corner, single-select radio list.
///
/// Mirrors [HListView]'s two construction styles:
///
///  * [HRadioListView.new] for an eagerly-built `items` list.
///  * [HRadioListView.builder] for lazily-built rows.
///
/// Example:
/// ```dart
/// HRadioListView<String>(
///   groupValue: selected,
///   onChanged: (value) => setState(() => selected = value),
///   items: const [
///     HRadioListItemData(title: 'Small', subtitle: '', value: 's'),
///     HRadioListItemData(title: 'Large', subtitle: '', value: 'l'),
///   ],
/// )
/// ```
class HRadioListView<T> extends StatelessWidget {
  /// Creates a grouped radio list from an eagerly-built [items] list.
  const HRadioListView({
    super.key,
    required List<HRadioListItemData<T>> this.items,
    required this.groupValue,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
  }) : itemCount = null,
       itemBuilder = null;

  /// Creates a grouped radio list that builds its [itemCount] rows lazily
  /// via [itemBuilder], analogous to [ListView.builder].
  const HRadioListView.builder({
    super.key,
    required int this.itemCount,
    required HRadioListItemData<T> Function(int index) this.itemBuilder,
    required this.groupValue,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
  }) : items = null;

  /// The rows to render, when constructed via [HRadioListView.new].
  final List<HRadioListItemData<T>>? items;

  /// The number of rows to render, when constructed via
  /// [HRadioListView.builder].
  final int? itemCount;

  /// Builds the row at the given index, when constructed via
  /// [HRadioListView.builder].
  final HRadioListItemData<T> Function(int index)? itemBuilder;

  /// The currently-selected value. The row whose
  /// `HRadioListItemData.value` equals this is rendered as selected.
  final T groupValue;

  /// Called with the newly-selected value when the user picks a row.
  final ValueChanged<T> onChanged;

  /// Whether the list can be scrolled independently of its parent.
  ///
  /// See [HListView.enableScroll] for details; the default is the same.
  final bool? enableScroll;

  /// Whether the list should size itself to its content.
  ///
  /// See [HListView.shrinkWrap] for details; the default is the same.
  final bool? shrinkWrap;

  /// The number of rows this list will render, regardless of which
  /// constructor was used.
  int get _count => items?.length ?? itemCount!;

  /// The row data at [index], regardless of which constructor was used.
  HRadioListItemData<T> _itemAt(int index) =>
      items != null ? items![index] : itemBuilder!(index);

  @override
  Widget build(BuildContext context) {
    final count = _count;
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      child: ListView.separated(
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
            child: RadioListTile<T>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              contentPadding: const EdgeInsets.only(left: 16.0, right: 18.0),
              title: item.title,
              subtitle: item.subtitle.isNotEmpty
                  ? Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              value: item.value,
              secondary: item.suffix,
            ),
          );
        },
        separatorBuilder: (context, index) =>
            const SizedBox(height: _kItemSpacing),
      ),
    );
  }
}
