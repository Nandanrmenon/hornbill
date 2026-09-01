import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_ui/material_ui.dart';

/// A single column definition for [HDataTable].
///
/// Unlike Flutter's [DataColumn], width is explicit (and, unless
/// [resizable] is false, user-adjustable by dragging the column's
/// trailing edge at runtime).
class HDataColumn {
  const HDataColumn({
    required this.label,
    this.width = 120,
    this.minWidth = 48,
    this.maxWidth,
    this.resizable = true,
    this.sortable = false,
    this.numeric = false,
    this.tooltip,
  });

  /// Header content. Usually a [Text], but can be anything.
  final Widget label;

  /// Starting width in logical pixels. If the user drags to resize this
  /// column, [HDataTable] tracks the live width itself from here.
  final double width;

  /// Lower bound when resizing.
  final double minWidth;

  /// Upper bound when resizing. Unbounded if null.
  final double? maxWidth;

  /// Whether this column shows a drag handle to resize it.
  final bool resizable;

  /// Whether tapping the header cell triggers [HDataTable.onSort].
  final bool sortable;

  /// Right-aligns both the header label and every cell in this column,
  /// matching the usual convention for numeric data.
  final bool numeric;

  /// Optional tooltip shown on hover over the header cell.
  final String? tooltip;
}

/// A single cell inside an [HDataRow].
class HDataCell {
  const HDataCell(this.child, {this.onTap});

  /// Cell content.
  final Widget child;

  /// Called when this specific cell is tapped, in addition to
  /// [HDataRow.onTap] if that's also set.
  final VoidCallback? onTap;
}

/// A single row of data in [HDataTable].
///
/// [cells] must have exactly as many entries as [HDataTable.columns]
/// (plus, implicitly, the checkbox column if [HDataTable.showCheckboxColumn]
/// is true — don't include a cell for that yourself).
class HDataRow {
  const HDataRow({
    required this.cells,
    this.key,
    this.selected = false,
    this.onSelectChanged,
    this.onTap,
    this.onLongPress,
    this.color,
  });

  final LocalKey? key;
  final List<HDataCell> cells;

  /// Whether this row is currently selected. Only meaningful if
  /// [onSelectChanged] is also provided.
  final bool selected;

  /// Provide this to make the row selectable — shows a checkbox (when
  /// [HDataTable.showCheckboxColumn] is true) and participates in the
  /// header's "select all" tri-state checkbox.
  final ValueChanged<bool?>? onSelectChanged;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Explicit background color for this row. Takes priority over
  /// striping, but is still overridden by hover/selected highlighting.
  final Color? color;
}

/// A data table built from scratch (no [DataTable]) to support what
/// Flutter's Material table can't:
/// - virtualized rows (only visible rows are built — scales to large
///   datasets, unlike [DataTable] which builds everything up front)
/// - a header that's genuinely pinned while scrolling vertically
/// - resizable columns
/// - row hover highlighting
///
/// Column sorting is "controlled": [HDataTable] only renders the sort
/// arrow and reports taps via [onSort] — you own re-ordering [rows]
/// yourself, exactly like Flutter's own [DataTable.onSort] convention.
class HDataTable extends StatefulWidget {
  const HDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckboxColumn = false,
    this.checkboxColumnWidth = 56,
    this.onSelectAll,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.header,
    this.footer,
    this.oddRowColor,
    this.evenRowColor,
    this.selectedRowColor,
    this.hoverRowColor,
    this.headingRowColor,
    this.rowHeight = 44,
    this.headingRowHeight = 48,
    this.columnSpacing = 16,
    this.showColumnDividers = true,
    this.showRowDividers = true,
    this.dividerColor,
    this.emptyState,
    this.loading = false,
    this.physics,
    this.shrinkWrap = false,
  });

  final List<HDataColumn> columns;
  final List<HDataRow> rows;

  /// Adds a leading checkbox column with a tri-state "select all" in the
  /// header. The header checkbox reflects [rows] whose
  /// [HDataRow.onSelectChanged] is non-null: checked if all such rows
  /// are [HDataRow.selected], unchecked if none are, indeterminate
  /// otherwise.
  final bool showCheckboxColumn;
  final double checkboxColumnWidth;

  /// Called when the header checkbox is tapped. Receives `true`/`false`
  /// (never null — tapping an indeterminate checkbox selects all).
  final ValueChanged<bool?>? onSelectAll;

  /// Index into [columns] of the currently sorted column, purely for
  /// drawing the arrow indicator. Null shows no arrow.
  final int? sortColumnIndex;
  final bool sortAscending;

  /// Called with `(columnIndex, ascending)` when a sortable header is
  /// tapped. [HDataTable] doesn't sort [rows] itself — re-sort and pass
  /// new data back down, same as [DataTable.onSort].
  final void Function(int columnIndex, bool ascending)? onSort;

  /// Extra row rendered first, above the data rows but below the sticky
  /// header — e.g. a summary/subtitle row. Not sticky itself.
  final HDataRow? header;

  /// Extra row rendered last, below the data rows.
  final HDataRow? footer;

  final Color? oddRowColor;
  final Color? evenRowColor;
  final Color? selectedRowColor;
  final Color? hoverRowColor;
  final Color? headingRowColor;

  final double rowHeight;
  final double headingRowHeight;
  final double columnSpacing;

  /// Draws a vertical line between columns (and after the checkbox
  /// column, if shown).
  final bool showColumnDividers;

  /// Draws a horizontal line under every row, including the header.
  final bool showRowDividers;

  /// Color used for both [showColumnDividers] and [showRowDividers].
  /// Defaults to the theme's [ColorScheme.outlineVariant].
  final Color? dividerColor;

  /// Shown instead of the row list when [rows] is empty and
  /// [loading] is false. Defaults to a centered "No data" text.
  final Widget? emptyState;

  /// Shows a centered spinner instead of rows/[emptyState].
  final bool loading;

  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  State<HDataTable> createState() => _HDataTableState();
}

class _HDataTableState extends State<HDataTable> {
  late List<double> _columnWidths;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  int? _hoveredRowIndex;

  @override
  void initState() {
    super.initState();
    _columnWidths = widget.columns.map((c) => c.width).toList();
  }

  @override
  void didUpdateWidget(covariant HDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columns.length != widget.columns.length) {
      _columnWidths = widget.columns.map((c) => c.width).toList();
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _resizeColumn(int index, double delta) {
    final column = widget.columns[index];
    setState(() {
      final next = _columnWidths[index] + delta;
      final min = column.minWidth;
      final max = column.maxWidth;
      _columnWidths[index] = max == null
          ? (next < min ? min : next)
          : next.clamp(min, max);
    });
  }

  double get _tableWidth =>
      _columnWidths.fold(0.0, (sum, w) => sum + w) +
      (widget.showCheckboxColumn ? widget.checkboxColumnWidth : 0);

  bool? get _allSelected {
    final selectable = widget.rows.where((r) => r.onSelectChanged != null);
    if (selectable.isEmpty) return false;
    final selectedCount = selectable.where((r) => r.selected).length;
    if (selectedCount == 0) return false;
    if (selectedCount == selectable.length) return true;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedEven = widget.evenRowColor ?? theme.colorScheme.surface;
    final resolvedOdd =
        widget.oddRowColor ?? theme.colorScheme.surfaceContainerLow;
    final resolvedSelected =
        widget.selectedRowColor ??
        theme.colorScheme.primaryContainer.withValues(alpha: 0.4);
    final resolvedHover =
        widget.hoverRowColor ??
        theme.colorScheme.onSurface.withValues(alpha: 0.04);
    final resolvedHeading =
        widget.headingRowColor ??
        theme.colorScheme.primaryContainer.withValues(alpha: 0.12);
    final resolvedDivider =
        widget.dividerColor ?? theme.colorScheme.outlineVariant;

    final extraRows = <HDataRow>[
      if (widget.header != null) widget.header!,
      ...widget.rows,
      if (widget.footer != null) widget.footer!,
    ];
    final headerOffset = widget.header != null ? 1 : 0;

    Widget body;
    if (widget.loading) {
      body = const SizedBox.expand(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (widget.rows.isEmpty) {
      body = SizedBox.expand(
        child: Center(
          child:
              widget.emptyState ??
              Text(
                'No data',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
        ),
      );
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) {
          final width = _tableWidth < constraints.maxWidth
              ? constraints.maxWidth
              : _tableWidth;

          // A CustomScrollView is a real Viewport and needs a bounded
          // height from its parent, same as any ListView.builder. If
          // whatever's above HDataTable didn't bound the height (e.g. it
          // was placed directly in a Column instead of an Expanded/
          // SizedBox), fall back to a shrink-wrapped, non-scrolling-here
          // mode instead of crashing. SliverFixedExtentList can compute
          // its total extent as itemExtent * childCount without laying
          // out every row, so this fallback still doesn't lose
          // virtualization — the trade-off is just that the header can
          // no longer stay pinned, since there's no local scroll
          // position for it to pin against; the ancestor scrollable (if
          // any) drives scrolling instead.
          final bool boundedHeight = constraints.maxHeight.isFinite;
          final bool effectiveShrinkWrap = widget.shrinkWrap || !boundedHeight;
          final ScrollPhysics? effectivePhysics = boundedHeight
              ? widget.physics
              : const NeverScrollableScrollPhysics();

          return Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  child: CustomScrollView(
                    controller: _verticalController,
                    physics: effectivePhysics,
                    shrinkWrap: effectiveShrinkWrap,
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _HeaderDelegate(
                          height: widget.headingRowHeight,
                          child: _buildHeadingRow(
                            theme,
                            resolvedHeading,
                            resolvedDivider,
                          ),
                        ),
                      ),
                      SliverFixedExtentList(
                        itemExtent: widget.rowHeight,
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final row = extraRows[index];
                          final isHeaderRow =
                              widget.header != null && index == 0;
                          final isFooterRow =
                              widget.footer != null &&
                              index == extraRows.length - 1;
                          final dataIndex = index - headerOffset;

                          final Color background;
                          if (row.selected) {
                            background = resolvedSelected;
                          } else if (!isHeaderRow &&
                              !isFooterRow &&
                              _hoveredRowIndex == dataIndex) {
                            background = resolvedHover;
                          } else if (row.color != null) {
                            background = row.color!;
                          } else if (isHeaderRow || isFooterRow) {
                            background = resolvedEven;
                          } else {
                            background = dataIndex.isEven
                                ? resolvedEven
                                : resolvedOdd;
                          }

                          return _HDataTableRow(
                            row: row,
                            columns: widget.columns,
                            columnWidths: _columnWidths,
                            columnSpacing: widget.columnSpacing,
                            showCheckboxColumn: widget.showCheckboxColumn,
                            checkboxColumnWidth: widget.checkboxColumnWidth,
                            showColumnDividers: widget.showColumnDividers,
                            showRowDivider: widget.showRowDividers,
                            dividerColor: resolvedDivider,
                            background: background,
                            hoverable: !isHeaderRow && !isFooterRow,
                            onHoverChanged: (hovering) {
                              setState(() {
                                _hoveredRowIndex = hovering
                                    ? dataIndex
                                    : (_hoveredRowIndex == dataIndex
                                          ? null
                                          : _hoveredRowIndex);
                              });
                            },
                          );
                        }, childCount: extraRows.length),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      margin: const EdgeInsets.only(bottom: 32),
      child: body,
    );
  }

  Widget _buildHeadingRow(
    ThemeData theme,
    Color background,
    Color dividerColor,
  ) {
    final headingStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );

    return Container(
      decoration: BoxDecoration(
        color: background,
        border: widget.showRowDividers
            ? Border(bottom: BorderSide(color: dividerColor))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showCheckboxColumn)
            Container(
              width: widget.checkboxColumnWidth,
              decoration: widget.showColumnDividers
                  ? BoxDecoration(
                      border: Border(right: BorderSide(color: dividerColor)),
                    )
                  : null,
              child: Center(
                child: Checkbox(
                  value: _allSelected,
                  tristate: true,
                  onChanged: (value) => widget.onSelectAll?.call(value ?? true),
                ),
              ),
            ),
          for (var i = 0; i < widget.columns.length; i++)
            _buildHeaderCell(i, headingStyle, theme, dividerColor),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    int index,
    TextStyle style,
    ThemeData theme,
    Color dividerColor,
  ) {
    final column = widget.columns[index];
    final isSorted = widget.sortColumnIndex == index;
    final canSort = column.sortable && widget.onSort != null;

    Widget content = DefaultTextStyle(
      style: style,
      child: Row(
        mainAxisAlignment: column.numeric
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (column.numeric && column.sortable) _sortIcon(isSorted),
          Flexible(child: column.label),
          if (!column.numeric && column.sortable) _sortIcon(isSorted),
        ],
      ),
    );

    if (canSort) {
      content = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              widget.onSort!(index, isSorted ? !widget.sortAscending : true),
          child: content,
        ),
      );
    }

    if (column.tooltip != null) {
      content = Tooltip(message: column.tooltip!, child: content);
    }

    return SizedBox(
      width: _columnWidths[index],
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.columnSpacing / 2),
            child: Align(
              alignment: column.numeric
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: content,
            ),
          ),
          if (column.resizable)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) =>
                      _resizeColumn(index, details.delta.dx),
                  child: const SizedBox(width: 8),
                ),
              ),
            ),
          if (widget.showColumnDividers && index < widget.columns.length - 1)
            Positioned(
              right: 0,
              top: 8,
              bottom: 8,
              child: VerticalDivider(width: 1, color: dividerColor),
            ),
        ],
      ),
    );
  }

  Widget _sortIcon(bool isSorted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: AnimatedOpacity(
        opacity: isSorted ? 1 : 0.3,
        duration: const Duration(milliseconds: 150),
        child: AnimatedRotation(
          turns: isSorted && !widget.sortAscending ? 0.5 : 0,
          duration: const Duration(milliseconds: 150),
          child: const Icon(Icons.arrow_upward_rounded, size: 14),
        ),
      ),
    );
  }
}

/// Pins the heading row at a fixed height while the body scrolls under it.
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

/// A single rendered row: checkbox (optional) + cells, with hover
/// tracking. Split out so hover state doesn't rebuild the whole table.
class _HDataTableRow extends StatelessWidget {
  const _HDataTableRow({
    required this.row,
    required this.columns,
    required this.columnWidths,
    required this.columnSpacing,
    required this.showCheckboxColumn,
    required this.checkboxColumnWidth,
    required this.showColumnDividers,
    required this.showRowDivider,
    required this.dividerColor,
    required this.background,
    required this.hoverable,
    required this.onHoverChanged,
  });

  final HDataRow row;
  final List<HDataColumn> columns;
  final List<double> columnWidths;
  final double columnSpacing;
  final bool showCheckboxColumn;
  final double checkboxColumnWidth;
  final bool showColumnDividers;
  final bool showRowDivider;
  final Color dividerColor;
  final Color background;
  final bool hoverable;
  final ValueChanged<bool> onHoverChanged;

  @override
  Widget build(BuildContext context) {
    final canTap = row.onTap != null || row.onSelectChanged != null;

    final content = Container(
      decoration: BoxDecoration(
        color: background,
        border: showRowDivider
            ? Border(bottom: BorderSide(color: dividerColor))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showCheckboxColumn)
            Container(
              width: checkboxColumnWidth,
              decoration: showColumnDividers
                  ? BoxDecoration(
                      border: Border(right: BorderSide(color: dividerColor)),
                    )
                  : null,
              child: Center(
                child: row.onSelectChanged != null
                    ? Checkbox(
                        value: row.selected,
                        onChanged: row.onSelectChanged,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          for (var i = 0; i < row.cells.length; i++)
            SizedBox(
              width: columnWidths[i],
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: columnSpacing / 2,
                    ),
                    child: Align(
                      alignment: columns[i].numeric
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: row.cells[i].onTap,
                        child: row.cells[i].child,
                      ),
                    ),
                  ),
                  if (showColumnDividers && i < row.cells.length - 1)
                    Positioned(
                      right: 0,
                      top: 6,
                      bottom: 6,
                      child: VerticalDivider(width: 1, color: dividerColor),
                    ),
                ],
              ),
            ),
        ],
      ),
    );

    final tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canTap
          ? () {
              row.onTap?.call();
              if (row.onSelectChanged != null) {
                row.onSelectChanged!(!row.selected);
              }
            }
          : null,
      onLongPress: row.onLongPress,
      child: content,
    );

    if (!hoverable) return tappable;

    return MouseRegion(
      cursor: canTap ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: tappable,
    );
  }
}
