import 'package:flutter/material.dart';
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
      appBar: SliverAppBar(title: Text('List View')),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              MListHeader(title: 'List View - Normal'),
              MListView(
                items: [
                  MListItemData(title: 'Item 1'),
                  MListItemData(title: 'Item 2'),
                  MListItemData(title: 'Item 3'),
                ],
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              MListHeader(title: 'List View - Normal w/ subtitle'),
              MListView(
                items: [
                  MListItemData(title: 'Item 1', subtitle: 'Subtitle 1'),
                  MListItemData(title: 'Item 2', subtitle: 'Subtitle 2'),
                  MListItemData(title: 'Item 3', subtitle: 'Subtitle 3'),
                ],
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              MListHeader(title: 'List View - Normal w/ other properties'),
              MListView(
                items: [
                  MListItemData(
                    title: 'Item 1',
                    subtitle: 'Subtitle 1',
                    leading: Icon(Symbols.star_rounded),
                    suffix: Icon(Symbols.arrow_forward_rounded),
                  ),
                  MListItemData(
                    title: 'Item 2',
                    subtitle: 'Subtitle 2',
                    suffix: Icon(Symbols.arrow_forward_rounded),
                  ),
                  MListItemData(
                    title: 'Item 3',
                    subtitle: 'Subtitle 3',
                    leading: Icon(Symbols.star_rounded),
                  ),
                  MListItemData(
                    title: 'Item 4',
                    subtitle: 'Subtitle 4',
                    leading: Icon(Symbols.star_rounded),
                    selected: true,
                    onTap: () {},
                  ),
                  MListItemData(
                    title: 'Item 5',
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
              MListHeader(title: 'List View - Checkbox'),
              MCheckboxListView(
                onChanged: (index, value) {},
                items: [
                  MCheckboxListItemData(
                    title: '12312',
                    subtitle: 'asd',
                    value: false,
                  ),
                  MCheckboxListItemData(
                    title: '123234',
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
              MListHeader(title: 'List View - Radio'),
              MRadioListView(
                groupValue: 1,
                items: [
                  MRadioListItemData(title: '12312', subtitle: 'asd', value: 1),
                  MRadioListItemData(
                    title: '123234',
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
