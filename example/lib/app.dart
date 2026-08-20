import 'package:hornbill/hornbill.dart';
import 'package:hornbill_example/screens/buttons_screen.dart';
import 'package:hornbill_example/screens/chips_screen.dart';
import 'package:hornbill_example/screens/datatable_screen.dart';
import 'package:hornbill_example/screens/listview_screen.dart';
import 'package:hornbill_example/screens/navigationbar_screen.dart';
import 'package:hornbill_example/screens/progressindicator_screen.dart';
import 'package:hornbill_example/screens/switch.dart';
import 'package:hornbill_example/screens/textinputfield_screen.dart';
import 'package:hornbill_example/screens/theme_screen.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class HornbilExampleApp extends StatefulWidget {
  const HornbilExampleApp({super.key});

  @override
  State<HornbilExampleApp> createState() => _HornbilExampleAppState();
}

class _HornbilExampleAppState extends State<HornbilExampleApp> {
  bool get _isDesktop => MediaQuery.of(context).size.width >= 600;
  int _desktopSelectedIndex = 0;

  HSideBarItem _navigationItem({
    required IconData icon,
    required String label,
  }) {
    return HSideBarItem(icon: icon, label: label);
  }

  List<HSideBarItem> _desktopSidebarItems() {
    return [
      _navigationItem(icon: Symbols.palette_rounded, label: 'Themes'),
      _navigationItem(icon: Symbols.menu_rounded, label: 'Navigation Bar'),
      _navigationItem(
        icon: Symbols.text_fields_alt_rounded,
        label: 'Text Input Field',
      ),
      _navigationItem(icon: Symbols.web_traffic_rounded, label: 'Buttons'),
      _navigationItem(icon: Symbols.toggle_on_rounded, label: 'Switch'),
      _navigationItem(icon: Symbols.event_list_rounded, label: 'List View'),
      _navigationItem(icon: Symbols.table_rows_rounded, label: 'Data Table'),
      _navigationItem(icon: Symbols.label, label: 'Chip'),
      _navigationItem(icon: Symbols.percent, label: 'Progress Indicators'),
    ];
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return HSideBar(
      selectedIndex: _desktopSelectedIndex,
      onItemSelected: (index) {
        setState(() => _desktopSelectedIndex = index);
      },
      header: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Hornbill UI'),
      ),
      footer: HSideBarAccountTile(
        title: 'Ada Lovelace',
        subtitle: 'ada@example.com',
        onLogout: () {},
        accounts: const [
          HSideBarAccount(title: 'Ada Lovelace', subtitle: 'ada@example.com'),
          HSideBarAccount(title: 'Grace Hopper', subtitle: 'grace@example.com'),
        ],
        onAccountSelected: (value) {},
        onAddAccount: () {},
      ),

      items: _desktopSidebarItems(),
    );
  }

  List<Widget> _buildMobileSlivers(BuildContext context) {
    return [
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
                    MaterialPageRoute(builder: (context) => DataTableScreen()),
                  ),
                ),
              ],
            ),
            HListHeader(title: 'Feedback'),
            HListView(
              items: [
                HListItemData(
                  leading: Icon(Symbols.label),
                  title: Text('Chip'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChipsScreen()),
                  ),
                ),
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
    ];
  }

  List<Widget> _buildDesktopSlivers() {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: IndexedStack(
          index: _desktopSelectedIndex,
          children: const [
            ThemeScreen(),
            NavigationbarScreen(),
            TextinputfieldScreen(),
            ButtonsScreen(),
            SwitchScreen(),
            ListViewScreen(),
            DataTableScreen(),
            ChipsScreen(),
            ProgressIndicatorScreen(),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HornbillScaffold(
      appBar: _isDesktop
          ? null
          : SliverAppBar.large(title: Text('Hornbill Example App')),
      sidebar: _isDesktop ? _buildDesktopSidebar(context) : null,
      slivers: _isDesktop
          ? _buildDesktopSlivers()
          : _buildMobileSlivers(context),
    );
  }
}
