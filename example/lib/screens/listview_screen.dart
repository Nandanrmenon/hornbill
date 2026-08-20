import 'package:material_ui/material_ui.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';

class ListViewScreen extends StatefulWidget {
  const ListViewScreen({super.key});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  @override
  Widget build(BuildContext context) {
    return HornbillScaffold(
      appBar: HAppBar(title: 'List View'),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              HListHeader(title: 'List View - Normal'),
              HListView.builder(
                itemCount: 20,
                itemBuilder: (index) {
                  return HListItemData(
                    title: Text('Item $index'),
                    subtitle: 'Subtitle $index',
                    leading: Icon(Symbols.star_rounded),
                    suffix: Icon(Symbols.arrow_forward_rounded),
                    onTap: () {},
                  );
                },
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              HListHeader(title: 'List View - Normal w/ subtitle'),
              HListView(
                items: [
                  HListItemData(title: Text('Item 1'), subtitle: 'Subtitle 1'),
                  HListItemData(title: Text('Item 2'), subtitle: 'Subtitle 2'),
                  HListItemData(title: Text('Item 3'), subtitle: 'Subtitle 3'),
                ],
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              HListHeader(title: 'List View - Normal w/ other properties'),
              HListView(
                items: [
                  HListItemData(
                    title: Text('Item 1'),
                    subtitle: 'Subtitle 1',
                    leading: Icon(Symbols.star_rounded),
                    suffix: Icon(Symbols.arrow_forward_rounded),
                  ),
                  HListItemData(
                    title: Text('Item 2'),
                    subtitle: 'Subtitle 2',
                    suffix: Icon(Symbols.arrow_forward_rounded),
                  ),
                  HListItemData(
                    title: Text('Item 3'),
                    subtitle: 'Subtitle 3',
                    leading: Icon(Symbols.star_rounded),
                  ),
                  HListItemData(
                    title: Text('Item 4'),
                    subtitle: 'Subtitle 4',
                    leading: Icon(Symbols.star_rounded),
                    selected: true,
                    onTap: () {},
                  ),
                  HListItemData(
                    title: Text('Item 5'),
                    subtitle: 'Subtitle 5',
                    leading: Icon(Symbols.star_rounded),
                    selected: true,
                    onTap: () {},
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              HListHeader(title: 'List View - Checkbox'),
              HCheckboxListView(
                onChanged: (index, value) {},
                items: [
                  HCheckboxListItemData(
                    title: Text('12312'),
                    subtitle: 'asd',
                    value: false,
                  ),
                  HCheckboxListItemData(
                    title: Text('123234'),
                    subtitle: 'asd',
                    value: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              HListHeader(title: 'List View - Radio'),
              HRadioListView(
                groupValue: 1,
                items: [
                  HRadioListItemData(
                    title: Text('12312'),
                    subtitle: 'asd',
                    value: 1,
                  ),
                  HRadioListItemData(
                    title: Text('123234'),
                    subtitle: 'asd',
                    value: 2,
                  ),
                ],
                onChanged: (int value) {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
