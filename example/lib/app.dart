import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';
import 'package:hornbill_example/screens/buttons_screen.dart';
import 'package:hornbill_example/screens/datatable_screen.dart';
import 'package:hornbill_example/screens/listview_screen.dart';
import 'package:hornbill_example/screens/navigationbar_screen.dart';
import 'package:hornbill_example/screens/progressindicator_screen.dart';
import 'package:hornbill_example/screens/switch.dart';
import 'package:hornbill_example/screens/textinputfield_screen.dart';
import 'package:hornbill_example/screens/theme_screen.dart';
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
          child: Column(
            children: [
              HListHeader(title: 'Helper'),
              HListView(
                items: [
                  HListItemData(
                    leading: Icon(Symbols.palette_rounded),
                    title: Text('Themes'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ThemeScreen()),
                    ),
                  ),
                ],
              ),
              HListHeader(title: 'Layout'),
              HListView(
                items: [
                  HListItemData(
                    leading: Icon(Symbols.menu_rounded),
                    title: Text('Navigation Bar'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationbarScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              HListHeader(title: 'Form'),
              HListView(
                items: [
                  HListItemData(
                    leading: Icon(Symbols.text_fields_alt_rounded),
                    title: Text('Text Input Field'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TextinputfieldScreen(),
                      ),
                    ),
                  ),
                  HListItemData(
                    leading: Icon(Symbols.web_traffic_rounded),
                    title: Text('Buttons'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ButtonsScreen()),
                    ),
                  ),
                  HListItemData(
                    leading: Icon(Symbols.table_rows_rounded),
                    title: Text('Data Table'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataTableScreen(),
                      ),
                    ),
                  ),
                  HListItemData(
                    leading: Icon(Symbols.toggle_on_rounded),
                    title: Text('Switch'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SwitchScreen()),
                    ),
                  ),
                ],
              ),
              HListHeader(title: 'Data Presentation'),
              HListView(
                items: [
                  HListItemData(
                    leading: Icon(Symbols.event_list_rounded),
                    title: Text('List View'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListViewScreen()),
                    ),
                  ),

                  HListItemData(
                    leading: Icon(Symbols.table_rows_rounded),
                    title: Text('Data Table'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataTableScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              HListHeader(title: 'Feedback'),
              HListView(
                items: [
                  HListItemData(
                    leading: Icon(Symbols.percent),
                    title: Text('Progress Indicators'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgressIndicatorScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
