import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class ButtonsScreen extends StatefulWidget {
  const ButtonsScreen({super.key});

  @override
  State<ButtonsScreen> createState() => _ButtonsScreenState();
}

class _ButtonsScreenState extends State<ButtonsScreen> {
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: 'Buttons'),
      slivers: [
        SliverToBoxAdapter(child: HListHeader(title: 'Text')),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              spacing: 16.0,
              children: [
                HButton.text(label: 'Button', onPressed: () {}),
                HButton.text(
                  label: 'Button',
                  onPressed: () {},
                  showIcon: true,
                  icon: Symbols.add_rounded,
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
                HButton.outlined(label: 'Button', onPressed: () {}),
                HButton.outlined(
                  label: 'Button',
                  onPressed: () {},
                  showIcon: true,
                  icon: Symbols.add_rounded,
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
                HButton.tonal(label: 'Button', onPressed: () {}),
                HButton.tonal(
                  label: 'Button',
                  onPressed: () {},
                  showIcon: true,
                  icon: Symbols.add_rounded,
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
                HButton.filled(label: 'Button', onPressed: () {}),
                HButton.filled(
                  label: 'Button',
                  onPressed: () {},
                  showIcon: true,
                  icon: Symbols.add_rounded,
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
                HIconButton.filled(
                  icon: Symbols.android_rounded,
                  onPressed: () {},
                  tooltip: 'Button',
                ),
                HIconButton.outlined(
                  icon: Symbols.android_rounded,
                  onPressed: () {},
                  tooltip: 'Button',
                ),
                HIconButton.tonal(
                  icon: Symbols.android_rounded,
                  onPressed: () {},
                  tooltip: 'Button',
                ),
                HIconButton.text(
                  icon: Symbols.android_rounded,
                  onPressed: () {},
                  tooltip: 'Button',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
