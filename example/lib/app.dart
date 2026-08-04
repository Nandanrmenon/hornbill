import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';
import 'package:hornbill_example/screens/buttons_screen.dart';
import 'package:hornbill_example/screens/datatable_screen.dart';
import 'package:hornbill_example/screens/listview_screen.dart';
import 'package:hornbill_example/screens/textinputfield_screen.dart';
import 'package:material_symbols_icons/symbols.dart';

class HornbilExampleApp extends StatefulWidget {
  const HornbilExampleApp({super.key});

  @override
  State<HornbilExampleApp> createState() => _HornbilExampleAppState();
}

class _HornbilExampleAppState extends State<HornbilExampleApp> {
  @override
  Widget build(BuildContext context) {
    return HornbillScaffold(
      appBar: SliverAppBar.large(title: Text('Hornbill Example App')),
      slivers: [
        SliverToBoxAdapter(
          child: HListView(
            items: [
              HListItemData(
                leading: Icon(Symbols.text_fields_alt_rounded),
                title: 'Text Input Field',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TextinputfieldScreen(),
                  ),
                ),
              ),
              HListItemData(
                leading: Icon(Symbols.event_list_rounded),
                title: 'List View',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListViewScreen()),
                ),
              ),
              HListItemData(
                leading: Icon(Symbols.web_traffic_rounded),
                title: 'Buttons',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ButtonsScreen()),
                ),
              ),
              HListItemData(
                leading: Icon(Symbols.table_rows_rounded),
                title: 'Buttons',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataTableScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
