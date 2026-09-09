import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class TabbarScreen extends StatefulWidget {
  const TabbarScreen({super.key});

  @override
  State<TabbarScreen> createState() => _TabbarScreenState();
}

class _TabbarScreenState extends State<TabbarScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = HTabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(
        title: Text('Tabbar'),
        bottom: HTabBar(
          controller: _tabController,
          tabs: const [
            HTab(icon: Icon(Symbols.preview), label: Text('Preview')),
            HTab(icon: Icon(Symbols.code), label: Text('Usage')),
          ],
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: HTabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                HTab(icon: Icon(Symbols.preview), label: Text('Preview')),
                HTab(icon: Icon(Symbols.code), label: Text('Usage')),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          child: Expanded(
            child: HTabView(
              controller: _tabController,
              children: [
                Center(child: Text('One')),
                Center(child: Text('Two')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
