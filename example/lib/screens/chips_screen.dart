import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class ChipsScreen extends StatefulWidget {
  const ChipsScreen({super.key});

  @override
  State<ChipsScreen> createState() => _ChipsScreenState();
}

class _ChipsScreenState extends State<ChipsScreen> {
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: 'Chips'),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 200),
              child: Column(
                spacing: 16.0,
                children: [
                  Row(
                    spacing: 8.0,
                    children: [
                      HChip(label: 'Chip', type: ChipType.primary),
                      HChip(
                        label: 'Chip',
                        iconData: Symbols.tag,
                        type: ChipType.primary,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8.0,
                    children: [
                      HChip(label: 'Chip', type: ChipType.primaryContainer),
                      HChip(
                        label: 'Chip',
                        iconData: Symbols.tag,
                        type: ChipType.primaryContainer,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8.0,
                    children: [
                      HChip(label: 'Chip', type: ChipType.secondary),
                      HChip(
                        label: 'Chip',
                        iconData: Symbols.tag,
                        type: ChipType.secondary,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8.0,
                    children: [
                      HChip(label: 'Chip', type: ChipType.tertiary),
                      HChip(
                        label: 'Chip',
                        iconData: Symbols.tag,
                        type: ChipType.tertiary,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8.0,
                    children: [
                      HChip(
                        label: 'Chip',
                        type: ChipType.surfaceContainerHighest,
                      ),
                      HChip(
                        label: 'Chip',
                        iconData: Symbols.tag,
                        type: ChipType.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
