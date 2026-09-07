part of 'package:hornbill/src/widgets/list_widgets.dart';

/// A grouped, rounded-corner list of [HListTile] rows.
///
/// Mirrors [ListView] / [ListView.builder]'s two construction styles:
///
///  * Use the default constructor, [HListView.new], when you already have
///    the full list of items available:
///    ```dart
///    HListView(
///      items: [
///        HListTile(title: 'Wi-Fi', onTap: () {}),
///        HListTile(title: 'Bluetooth', onTap: () {}),
///      ],
///    )
///    ```
///  * Use [HListView.builder] when items are generated on demand (e.g. from
///    a large or dynamic data source):
///    ```dart
///    HListView.builder(
///      itemCount: users.length,
///      itemBuilder: (index) => HListTile(title: users[index].name),
///    )
///    ```
///
/// Both constructors produce an identical visual result; only how items
/// are supplied differs.
class HListView extends StatelessWidget {
  /// Creates a grouped list from an eagerly-built [items] list.
  const HListView({
    super.key,
    required List<HListTile> this.items,
    this.enableScroll,
    this.shrinkWrap,
    this.dense,
  }) : itemCount = null,
       itemBuilder = null;

  /// Creates a grouped list that builds its [itemCount] rows lazily via
  /// [itemBuilder], analogous to [ListView.builder].
  const HListView.builder({
    super.key,
    required int this.itemCount,
    required HListTile Function(int index) this.itemBuilder,
    this.enableScroll,
    this.shrinkWrap,
    this.dense,
  }) : items = null;

  /// The rows to render, when constructed via [HListView.new].
  ///
  /// Null when constructed via [HListView.builder]; use [itemBuilder] and
  /// [itemCount] instead.
  final List<HListTile>? items;

  /// The number of rows to render, when constructed via [HListView.builder].
  ///
  /// Null when constructed via [HListView.new]; use [items].length instead.
  final int? itemCount;

  /// Builds the row at the given index, when constructed via
  /// [HListView.builder].
  ///
  /// Null when constructed via [HListView.new].
  final HListTile Function(int index)? itemBuilder;

  /// Whether the list can be scrolled independently of its parent.
  ///
  /// Defaults to `false`, which uses [NeverScrollableScrollPhysics] — the
  /// common case when this list is already nested inside a scrollable
  /// parent (e.g. a `CustomScrollView` or another `ListView`). Pass `true`
  /// to make the list scroll on its own with
  /// [AlwaysScrollableScrollPhysics].
  final bool? enableScroll;

  /// Whether the list should size itself to its content
  /// (`ListView.shrinkWrap`).
  ///
  /// Defaults to `true`, so the list doesn't force its parent to provide
  /// unbounded height. Pass `false` to use the list's available space
  /// instead — typically paired with `enableScroll: true`.
  final bool? shrinkWrap;

  /// Whether rows use the compact/"dense" [ListTile] layout.
  ///
  /// Defaults to `false`. Also tightens the list's outer padding.
  final bool? dense;

  /// The number of rows this list will render, regardless of which
  /// constructor was used.
  int get _count => items?.length ?? itemCount!;

  /// The row data at [index], regardless of which constructor was used.
  HListTile _itemAt(int index) =>
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
          color: item.color?.withValues(alpha: 0.2),
          child: item._buildContent(context, denseOverride: dense),
        );
      },
      separatorBuilder: (context, index) =>
          const SizedBox(height: _kItemSpacing),
    );
  }
}
