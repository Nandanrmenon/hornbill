import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';

class ButtonsScreen extends StatefulWidget {
  const ButtonsScreen({super.key});

  @override
  State<ButtonsScreen> createState() => _ButtonsScreenState();
}

class _ButtonsScreenState extends State<ButtonsScreen> {
  @override
  Widget build(BuildContext context) {
    return HornbillScaffold(
      appBar: SliverAppBar(title: Text('Buttons')),
      slivers: [
        SliverToBoxAdapter(child: HListHeader(title: 'Text')),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              spacing: 16.0,
              children: [
                TextButton(onPressed: () {}, child: Text('Button')),
                TextButton.icon(
                  onPressed: () {},
                  label: Text('Button'),
                  icon: Icon(Symbols.add_rounded),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: HListHeader(title: 'Outlined')),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              spacing: 16.0,
              children: [
                OutlinedButton(onPressed: () {}, child: Text('Button')),
                OutlinedButton.icon(
                  onPressed: () {},
                  label: Text('Button'),
                  icon: Icon(Symbols.add_rounded),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: HListHeader(title: 'Filled')),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              spacing: 16.0,
              children: [
                FilledButton.tonal(onPressed: () {}, child: Text('Button')),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  label: Text('Button'),
                  icon: Icon(Symbols.add_rounded),
                ),
                FilledButton(onPressed: () {}, child: Text('Button')),
                FilledButton.icon(
                  onPressed: () {},
                  label: Text('Button'),
                  icon: Icon(Symbols.add_rounded),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: HListHeader(title: 'Filled')),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              spacing: 16.0,
              children: [
                IconButton(
                  onPressed: () {},
                  tooltip: 'Button',
                  icon: Icon(Symbols.android_rounded),
                ),
                IconButton.outlined(
                  onPressed: () {},
                  tooltip: 'Button',
                  icon: Icon(Symbols.android_rounded),
                ),
                IconButton.filledTonal(
                  onPressed: () {},
                  tooltip: 'Button',
                  icon: Icon(Symbols.android_rounded),
                ),
                IconButton.filled(
                  onPressed: () {},
                  tooltip: 'Button',
                  icon: Icon(Symbols.android_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
