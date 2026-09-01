import 'package:hornbill/hornbill.dart';
import 'package:hornbill_example/screens/breadcrumbs_screen.dart';
import 'package:hornbill_example/screens/buttons_screen.dart';
import 'package:hornbill_example/screens/cards_screen.dart';
import 'package:hornbill_example/screens/chips_screen.dart';
import 'package:hornbill_example/screens/datatable_screen.dart';
import 'package:hornbill_example/screens/dialog_screen.dart';
import 'package:hornbill_example/screens/icons_screen.dart';
import 'package:hornbill_example/screens/listview_screen.dart';
import 'package:hornbill_example/screens/navigationbar_screen.dart';
import 'package:hornbill_example/screens/progressindicator_screen.dart';
import 'package:hornbill_example/screens/scaffold_screen.dart';
import 'package:hornbill_example/screens/sidebar_screen.dart';
import 'package:hornbill_example/screens/switch.dart';
import 'package:hornbill_example/screens/textinputfield_screen.dart';
import 'package:hornbill_example/screens/theme_screen.dart';
import 'package:hornbill_example/screens/toast_screen.dart';
import 'package:hornbill_example/theme_controller.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class HornbilExampleApp extends StatefulWidget {
  const HornbilExampleApp({super.key, required this.themeController});

  /// Drives the live colour-scheme picker on the Themes screen.
  final HThemeController themeController;

  @override
  State<HornbilExampleApp> createState() => _HornbilExampleAppState();
}

class _HornbilExampleAppState extends State<HornbilExampleApp> {
  bool get _isDesktop => MediaQuery.of(context).size.width >= 600;

  // Track active view using a unique string key instead of fragile indices
  String _activeScreenKey = 'themes';

  // Helper to switch desktop content safely
  void _selectScreen(String screenKey) {
    setState(() {
      _activeScreenKey = screenKey;
    });
  }

  List<HSideBarItem> _desktopSidebarItems() {
    return [
      HSideBarItem(
        label: 'Themes',
        icon: Symbols.palette_rounded,
        selected: _activeScreenKey == 'themes',
        onTap: () => _selectScreen('themes'),
      ),
      HSideBarItem(
        label: 'Icons',
        icon: Symbols.package,
        selected: _activeScreenKey == 'icons',
        onTap: () => _selectScreen('icons'),
      ),
      HSideBarItem(
        icon: Symbols.folder_rounded,
        label: 'Layout',
        initiallyExpanded: true,
        children: [
          HSideBarItem(
            icon: Symbols.menu_rounded,
            label: 'Navigation Bar',
            selected: _activeScreenKey == 'navigation_bar',
            onTap: () => _selectScreen('navigation_bar'),
          ),
          HSideBarItem(
            icon: Symbols.mobile_layout,
            label: 'Scaffold',
            selected: _activeScreenKey == 'scaffold',
            onTap: () => _selectScreen('scaffold'),
          ),
          HSideBarItem(
            icon: Symbols.side_navigation,
            label: 'Sidebar',
            selected: _activeScreenKey == 'sidebar',
            onTap: () => _selectScreen('sidebar'),
          ),
          HSideBarItem(
            icon: Symbols.mobile_layout,
            label: 'Dialog',
            selected: _activeScreenKey == 'dialog',
            onTap: () => _selectScreen('dialog'),
          ),
          HSideBarItem(
            icon: Symbols.chevron_right_rounded,
            label: 'Breadcrumbs',
            selected: _activeScreenKey == 'breadcrumbs',
            onTap: () => _selectScreen('breadcrumbs'),
          ),
        ],
      ),
      HSideBarItem(
        icon: Symbols.folder_rounded,
        label: 'Forms',
        initiallyExpanded: true,
        children: [
          HSideBarItem(
            icon: Symbols.text_fields_alt_rounded,
            label: 'TextField',
            selected: _activeScreenKey == 'textfield',
            onTap: () => _selectScreen('textfield'),
          ),
          HSideBarItem(
            icon: Symbols.web_traffic_rounded,
            label: 'Button',
            selected: _activeScreenKey == 'button',
            onTap: () => _selectScreen('button'),
          ),
          HSideBarItem(
            icon: Symbols.toggle_on_rounded,
            label: 'Switch',
            selected: _activeScreenKey == 'switch',
            onTap: () => _selectScreen('switch'),
          ),
        ],
      ),
      HSideBarItem(
        icon: Symbols.folder_rounded,
        label: 'Data Presentation',
        initiallyExpanded: true,
        children: [
          HSideBarItem(
            label: 'Cards',
            icon: Symbols.credit_card_rounded,
            selected: _activeScreenKey == 'cards',
            onTap: () => _selectScreen('cards'),
          ),
          HSideBarItem(
            icon: Symbols.event_list_rounded,
            label: 'List View',
            selected: _activeScreenKey == 'list_view',
            onTap: () => _selectScreen('list_view'),
          ),
          HSideBarItem(
            icon: Symbols.table_rows_rounded,
            label: 'Data Table',
            selected: _activeScreenKey == 'data_table',
            onTap: () => _selectScreen('data_table'),
          ),
        ],
      ),
      HSideBarItem(
        icon: Symbols.folder_rounded,
        label: 'Feedback',
        initiallyExpanded: true,
        children: [
          HSideBarItem(
            icon: Symbols.message,
            label: 'Toast',
            selected: _activeScreenKey == 'toast',
            onTap: () => _selectScreen('toast'),
          ),
          HSideBarItem(
            icon: Symbols.table_rows_rounded,
            label: 'Chip',
            selected: _activeScreenKey == 'chip',
            onTap: () => _selectScreen('chip'),
          ),
          HSideBarItem(
            icon: Symbols.percent,
            label: 'Progress Indicators',
            selected: _activeScreenKey == 'progress_indicators',
            onTap: () => _selectScreen('progress_indicators'),
          ),
        ],
      ),
    ];
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return HSideBar(
      // Passing -1 disables HSideBar's default global numeric index watcher,
      // letting our explicit item `onTap` and `selected` properties take total control.
      selectedIndex: -1,
      onItemSelected: (_) {},
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
            const HListHeader(title: 'Helper'),
            HListView(
              items: [
                HListItemData(
                  leading: const Icon(Symbols.palette_rounded),
                  title: const Text('Themes'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ThemeScreen(themeController: widget.themeController),
                    ),
                  ),
                ),
              ],
            ),
            HListView(
              items: [
                HListItemData(
                  leading: const Icon(Symbols.package),
                  title: const Text('Icons'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IconsScreen()),
                  ),
                ),
              ],
            ),
            const HListHeader(title: 'Layout'),
            HListView(
              items: [
                HListItemData(
                  leading: const Icon(Symbols.menu_rounded),
                  title: const Text('Navigation Bar'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NavigationbarScreen(),
                    ),
                  ),
                ),
                HListItemData(
                  leading: const Icon(Symbols.side_navigation),
                  title: const Text('Sidebar'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SidebarScreen(),
                    ),
                  ),
                ),
                HListItemData(
                  leading: const Icon(Symbols.dialogs_rounded),
                  title: const Text('Dialogs'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DialogScreen(),
                    ),
                  ),
                ),
                HListItemData(
                  leading: const Icon(Symbols.mobile_layout),
                  title: const Text('Scaffold'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScaffoldScreen(),
                    ),
                  ),
                ),
                HListItemData(
                  title: const Text('Breadcrumbs'),
                  leading: const Icon(Symbols.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BreadcrumbsScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const HListHeader(title: 'Form'),
            HListView(
              items: [
                HListItemData(
                  leading: const Icon(Symbols.text_fields_alt_rounded),
                  title: const Text('Text Input Field'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TextinputfieldScreen(),
                    ),
                  ),
                ),
                HListItemData(
                  leading: const Icon(Symbols.web_traffic_rounded),
                  title: const Text('Buttons'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ButtonsScreen(),
                    ),
                  ),
                ),
                HListItemData(
                  leading: const Icon(Symbols.toggle_on_rounded),
                  title: const Text('Switch'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SwitchScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const HListHeader(title: 'Data Presentation'),
            HListView(
              items: [
                HListItemData(
                  title: const Text('Cards'),
                  leading: const Icon(Symbols.credit_card_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CardsScreen(),
                    ),
                  ),
                ),
                HListItemData(
                  leading: const Icon(Symbols.event_list_rounded),
                  title: const Text('List View'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ListViewScreen(),
                    ),
                  ),
                ),
                HListItemData(
                  leading: const Icon(Symbols.table_rows_rounded),
                  title: const Text('Data Table'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataTableScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const HListHeader(title: 'Feedback'),
            HListView(
              items: [
                HListItemData(
                  leading: const Icon(Symbols.label),
                  title: const Text('Chip'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChipsScreen(),
                    ),
                  ),
                ),
                HListItemData(
                  leading: const Icon(Symbols.percent),
                  title: const Text('Progress Indicators'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProgressIndicatorScreen(),
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

  // Clean widget switch mechanism replacing IndexedStack
  Widget _buildSelectedScreen() {
    switch (_activeScreenKey) {
      case 'themes':
        return ThemeScreen(themeController: widget.themeController);
      case 'icons':
        return const IconsScreen();
      case 'navigation_bar':
        return const NavigationbarScreen();
      case 'scaffold':
        return const ScaffoldScreen();
      case 'sidebar':
        return const SidebarScreen();
      case 'dialog':
        return const DialogScreen();
      case 'textfield':
        return const TextinputfieldScreen();
      case 'button':
        return const ButtonsScreen();
      case 'switch':
        return const SwitchScreen();
      case 'list_view':
        return const ListViewScreen();
      case 'data_table':
        return const DataTableScreen();
      case 'toast':
        return const ToastScreen();
      case 'chip':
        return const ChipsScreen();
      case 'progress_indicators':
        return const ProgressIndicatorScreen();
      case 'breadcrumbs':
        return const BreadcrumbsScreen();
      case 'cards':
        return const CardsScreen();
      default:
        return ThemeScreen(themeController: widget.themeController);
    }
  }

  List<Widget> _buildDesktopSlivers() {
    return [
      SliverFillRemaining(hasScrollBody: false, child: _buildSelectedScreen()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: _isDesktop ? null : const HAppBar(title: 'Hornbill Example App'),
      sidebar: _isDesktop ? _buildDesktopSidebar(context) : null,
      slivers: _isDesktop
          ? _buildDesktopSlivers()
          : _buildMobileSlivers(context),
    );
  }
}
