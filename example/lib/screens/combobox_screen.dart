import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

const _animals = <HSelectItem<String>>[
  HSelectItem(value: 'cat', label: 'Cat', description: 'Independent'),
  HSelectItem(value: 'dog', label: 'Dog', description: 'Loyal'),
  HSelectItem(value: 'bird', label: 'Bird', description: 'Can fly'),
  HSelectItem(value: 'fish', label: 'Fish', description: 'Lives in water'),
  HSelectItem(
    value: 'hamster',
    label: 'Hamster',
    description: 'Small and quick',
    enabled: false,
  ),
];

class ComboBoxScreen extends StatefulWidget {
  const ComboBoxScreen({super.key});

  @override
  State<ComboBoxScreen> createState() => _ComboBoxScreenState();
}

class _ComboBoxScreenState extends State<ComboBoxScreen> {
  // Variant demos
  final Map<HSelectVariant, String?> _variants = {
    for (final v in HSelectVariant.values) v: null,
  };
  String _title(String s) => s[0].toUpperCase() + s.substring(1);

  Widget _card(Widget child, String? title, String? subtitle) => HCard(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    padding: EdgeInsets.fromLTRB(24, title != null ? 24 : 0, 24, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16.0,
      children: [
        if (title != null)
          HListHeader(
            title: title,
            subtitle: subtitle,
            padding: EdgeInsets.zero,
          ),
        child,
      ],
    ),
  );

  Widget _text(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Text(text),
  );
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: Text('ComboBox')),
      slivers: [
        SliverToBoxAdapter(child: HListHeader(title: 'ComboBox')),
        SliverToBoxAdapter(
          child: HCard(
            margin: EdgeInsets.all(16.0),
            child: Column(
              spacing: 16.0,
              children: [
                HComboBox(
                  items: [
                    HSelectItem(value: 'item1', label: 'Item 1'),
                    HSelectItem(value: 'item2', label: 'Item 2'),
                  ],
                  onChanged: (String? value) {},
                  label: 'Select an item',
                ),
                for (final v in HSelectVariant.values)
                  HComboBox<String>(
                    variant: v,
                    label: _title(v.name),
                    placeholder: 'Select an animal',
                    value: _variants[v],
                    onChanged: (value) => setState(() => _variants[v] = value),
                    items: _animals,
                    // labelPlacement: HSelectLabelPlacement.outside,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
