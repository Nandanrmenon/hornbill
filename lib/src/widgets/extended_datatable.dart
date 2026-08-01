import 'package:flutter/material.dart';
import 'package:hornbill/src/helpers/constants.dart';

class RSExtendedDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showCheckbox;
  final DataRow? header;
  final DataRow? footer;

  const RSExtendedDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckbox = false,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    ScrollController horizontalScrollController = ScrollController();
    ScrollController verticalScrollController = ScrollController();
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    columnSpacing: 16,
                    headingRowColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.primaryContainer,
                    ),
                    border: TableBorder.symmetric(
                      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      outside: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    headingRowHeight: 48,
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 44,
                    clipBehavior: Clip.antiAlias,
                    columns: columns,
                    rows: [?header, ...rows, ?footer],
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
