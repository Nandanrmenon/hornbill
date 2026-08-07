import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';

class DataTableScreen extends StatefulWidget {
  const DataTableScreen({super.key});

  @override
  State<DataTableScreen> createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  @override
  Widget build(BuildContext context) {
    return HornbillScaffold(
      appBar: SliverAppBar.large(title: Text('Data Table')),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: HornbillDataTable(
              columns: [
                DataColumn(label: Text('Column 1')),
                DataColumn(label: Text('Column 2')),
                DataColumn(label: Text('Column 3')),
              ],
              rows: [
                DataRow(
                  onHover: (value) {},
                  onSelectChanged: (value) {},
                  cells: [
                    DataCell(Text('Row 1, Cell 1')),
                    DataCell(Text('Row 1, Cell 2')),
                    DataCell(Text('Row 1, Cell 3')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('Row 2, Cell 1')),
                    DataCell(Text('Row 2, Cell 2')),
                    DataCell(Text('Row 2, Cell 3')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('Row 3, Cell 1')),
                    DataCell(Text('Row 3, Cell 2')),
                    DataCell(Text('Row 3, Cell 3')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('Row 4, Cell 1')),
                    DataCell(Text('Row 4, Cell 2')),
                    DataCell(Text('Row 4, Cell 3')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      bottomNavigationBar: HornbillPageNavigation(
        pageNr: 7,
        totalPages: 10,
        totalRecords: 20,
        onPrevious: () {},
        onNext: () {},
        onPageSelected: (page) {},
      ),
    );
  }
}
