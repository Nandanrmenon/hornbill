import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';

class DataTableScreen extends StatefulWidget {
  const DataTableScreen({super.key});

  @override
  State<DataTableScreen> createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  int _currentPage = 0; // Start at 0 for the first page
  final int _rowsPerPage = 20;
  final int _totalRecords = 50;

  final Set<int> _selectedIndices = {};

  late final List<Map<String, String>> _allRecords = List.generate(
    _totalRecords,
    (index) => {
      'col1': 'Record ${index + 1}, Cell 1',
      'col2': 'Record ${index + 1}, Cell 2',
      'col3': 'Record ${index + 1}, Cell 3',
    },
  );

  @override
  Widget build(BuildContext context) {
    int totalPages = (_totalRecords / _rowsPerPage).ceil();

    // Clamp between 0 and totalPages - 1 for 0-based indexing
    _currentPage = _currentPage.clamp(0, totalPages > 0 ? totalPages - 1 : 0);

    int startIndex = _currentPage * _rowsPerPage; // 0-based math
    int endIndex = (startIndex + _rowsPerPage).clamp(0, _totalRecords);
    List<Map<String, String>> currentPageRecords = _allRecords.sublist(
      startIndex,
      endIndex,
    );

    return HScaffold(
      appBar: HAppBar(title: 'Data Table'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: HDataTable(
              onSelectAll: (value) {
                setState(() {
                  if (value == true) {
                    _selectedIndices.addAll(
                      List.generate(
                        currentPageRecords.length,
                        (i) => startIndex + i,
                      ),
                    );
                  } else {
                    _selectedIndices.removeAll(
                      List.generate(
                        currentPageRecords.length,
                        (i) => startIndex + i,
                      ),
                    );
                  }
                });
              },
              showCheckboxColumn: true,
              columns: [
                HDataColumn(label: Text('Column 1'), minWidth: 300, width: 300),
                HDataColumn(label: Text('Column 2'), minWidth: 300, width: 300),
                HDataColumn(label: Text('Column 3'), minWidth: 300, width: 300),
              ],
              rows: List.generate(currentPageRecords.length, (localIndex) {
                int globalIndex = startIndex + localIndex;
                final record = currentPageRecords[localIndex];
                bool isSelected = _selectedIndices.contains(globalIndex);

                return HDataRow(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedIndices.add(globalIndex);
                      } else {
                        _selectedIndices.remove(globalIndex);
                      }
                    });
                  },
                  cells: [
                    HDataCell(Text(record['col1']!)),
                    HDataCell(Text(record['col2']!)),
                    HDataCell(Text(record['col3']!)),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
      bottomNavigationBar: HPageNavigation(
        pageNr: _currentPage,
        totalPages: totalPages,
        totalRecords: _totalRecords,
        onPrevious: () {
          if (_currentPage > 0) {
            setState(() {
              _currentPage--;
            });
          }
        },
        onNext: () {
          if (_currentPage < totalPages - 1) {
            setState(() {
              _currentPage++;
            });
          }
        },
        onPageSelected: (page) {
          setState(() {
            _currentPage = page;
          });
        },
      ),
    );
  }
}
