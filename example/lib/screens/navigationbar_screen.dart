import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class NavigationbarScreen extends StatefulWidget {
  const NavigationbarScreen({super.key});

  @override
  State<NavigationbarScreen> createState() => _NavigationbarScreenState();
}

class _NavigationbarScreenState extends State<NavigationbarScreen> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: 'Navigation Bar'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                HListHeader(title: 'Navigation Bar'),
                SizedBox(height: 16),
                Center(
                  child: HNavigationBar(
                    currentIndex: _index,
                    onTap: (i) => setState(() => _index = i),
                    items: const [
                      HNavigationBarItem(
                        icon: Symbols.home_rounded,
                        selectedIcon: Symbols.home_rounded,
                        label: 'Home',
                      ),
                      HNavigationBarItem(
                        icon: Symbols.search_rounded,
                        label: 'Search',
                      ),
                      HNavigationBarItem(
                        icon: Symbols.favorite_rounded,
                        selectedIcon: Symbols.favorite_rounded,
                        label: 'Favorites',
                      ),
                      HNavigationBarItem(
                        icon: Symbols.person_rounded,
                        selectedIcon: Symbols.person_rounded,
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      bottomNavigationBar: HNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          HNavigationBarItem(
            icon: Symbols.home,
            selectedIcon: Symbols.home,
            label: 'Home',
          ),
          HNavigationBarItem(icon: Symbols.search, label: 'Search'),
          HNavigationBarItem(
            icon: Symbols.favorite_border,
            selectedIcon: Symbols.favorite,
            label: 'Favorites',
          ),
          HNavigationBarItem(
            icon: Symbols.person_outline,
            selectedIcon: Symbols.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
