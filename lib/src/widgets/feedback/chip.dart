import 'package:material_ui/material_ui.dart';
import 'package:hornbill/src/helpers/constants.dart';

enum ChipType {
  primary,
  primaryContainer,
  secondary,
  tertiary,
  surfaceContainerHighest,
}

class HChip extends StatefulWidget {
  final String label;
  final ChipType type;
  final IconData? iconData;
  const HChip({
    super.key,
    required this.label,
    this.type = ChipType.primary,
    this.iconData,
  });

  @override
  State<HChip> createState() => _HChipState();
}

class _HChipState extends State<HChip> {
  Color getBackgroundColor() {
    switch (widget.type) {
      case ChipType.primary:
        return Theme.of(context).colorScheme.primary;
      case ChipType.primaryContainer:
        return Theme.of(context).colorScheme.primaryContainer;
      case ChipType.secondary:
        return Theme.of(context).colorScheme.secondaryContainer;
      case ChipType.tertiary:
        return Theme.of(context).colorScheme.tertiaryContainer;
      case ChipType.surfaceContainerHighest:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  Color getForegroundColor() {
    switch (widget.type) {
      case ChipType.primary:
        return Theme.of(context).colorScheme.onPrimary;
      case ChipType.primaryContainer:
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case ChipType.secondary:
        return Theme.of(context).colorScheme.onSecondaryContainer;
      case ChipType.tertiary:
        return Theme.of(context).colorScheme.onTertiaryContainer;
      case ChipType.surfaceContainerHighest:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: getBackgroundColor(),
      borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: .min,
          children: [
            if (widget.iconData != null) ...[
              Icon(widget.iconData, color: getForegroundColor()),
              SizedBox(width: 4),
            ],
            Text(
              widget.label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: getForegroundColor()),
            ),
          ],
        ),
      ),
    );
  }
}
