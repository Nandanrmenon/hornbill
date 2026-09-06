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
          child: Column(
            children: [
              HListHeader(title: 'Chats'),
              HListView.builder(
                itemCount: 20,
                itemBuilder: (index) {
                  return HListItemData(
                    title: Text('Chat $index'),
                    subtitle: 'Message $index',
                    leading: CircleAvatar(child: Icon(Symbols.person_rounded)),
                    // suffix: Icon(Symbols.arrow_forward_rounded),
                    onTap: () {},
                  );
                },
              ),
            ],
          ),
        ),
      ],
      bottomNavigationBar: HNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          HNavigationBarItem(
            icon: Symbols.message_rounded,
            selectedIcon: Symbols.message_rounded,
            label: 'Chats',
          ),
          HNavigationBarItem(icon: Symbols.search_rounded, label: 'Search'),
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
    );
  }
}
