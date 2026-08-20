import 'package:material_ui/material_ui.dart';
import 'package:hornbill/src/helpers/constants.dart';

class HDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showCheckbox;
  final DataRow? header;
  final DataRow? footer;

  /// Background color for odd-indexed data rows (1st, 3rd, ... i.e. index 0, 2, ...
  /// depending on how you count — see [_applyStripe] for the exact rule).
  final Color? oddRowColor;

  /// Background color for even-indexed data rows.
  final Color? evenRowColor;

  const HDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckbox = false,
    this.header,
    this.footer,
    this.oddRowColor,
    this.evenRowColor,
  });

  /// Returns [row] with a striped background color applied, unless the row
  /// already defines its own explicit [DataRow.color] — in that case the
  /// row's own color always wins.
  DataRow _applyStripe(DataRow row, int index, Color even, Color odd) {
    if (row.color != null) return row;

    final stripeColor = index.isEven ? even : odd;

    return DataRow(
      key: row.key,
      selected: row.selected,
      onSelectChanged: row.onSelectChanged,
      onLongPress: row.onLongPress,
      mouseCursor: row.mouseCursor,
      onHover: row.onHover,
      color: WidgetStateProperty.all(stripeColor),
      cells: row.cells,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScrollController horizontalScrollController = ScrollController();
    ScrollController verticalScrollController = ScrollController();

    final theme = Theme.of(context);
    final Color resolvedEven = evenRowColor ?? theme.colorScheme.surface;
    final Color resolvedOdd =
        oddRowColor ?? theme.colorScheme.surfaceContainerLow;

    final List<DataRow> stripedRows = [
      for (int i = 0; i < rows.length; i++)
        _applyStripe(rows[i], i, resolvedEven, resolvedOdd),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          controller: horizontalScrollController,
          notificationPredicate: (notification) => notification.depth == 1,
          child: SingleChildScrollView(
            controller: verticalScrollController,
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: horizontalScrollController,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: DataTable(
                    showCheckboxColumn: showCheckbox,
                    headingTextStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    columnSpacing: 16,
                    headingRowColor: WidgetStateProperty.all(
                      theme.colorScheme.primaryContainer,
                    ),
                    border: TableBorder.symmetric(
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      // outside: BorderSide(
                      //   color: theme.colorScheme.outlineVariant,
                      //   width: 1,
                      // ),
                    ),
                    headingRowHeight: 48,
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 44,
                    clipBehavior: Clip.antiAlias,
                    columns: columns,
                    rows: [?header, ...stripedRows, ?footer],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
