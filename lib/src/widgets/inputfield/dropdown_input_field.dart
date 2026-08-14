import 'package:material_ui/material_ui.dart';

class HornbillDropDownField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool isRequired;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final Icon? icon;
  final Widget? trailingWidget;
  final List<DropdownMenuEntry<String>>? dropdownMenuEntries;
  final String? initialSelection;
  final void Function(String?)? onSelected;
  const HornbillDropDownField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.isRequired = false,
    this.keyboardType,
    this.focusNode,
    this.onFieldSubmitted,
    this.icon,
    this.trailingWidget,
    this.dropdownMenuEntries,
    this.initialSelection,
    this.onSelected,
  });

  @override
  State<HornbillDropDownField> createState() => _HornbillDropDownFieldState();
}

class _HornbillDropDownFieldState extends State<HornbillDropDownField> {
  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final themeText = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: .start,
      spacing: widget.icon != null ? 8.0 : 4.0,
      children: [
        Row(
          spacing: 4.0,
          children: [
            widget.icon ?? const SizedBox.shrink(),
            Text(
              widget.label ?? 'Label',
              style: themeText.labelMedium?.copyWith(
                color: themeColor.onSurfaceVariant,
              ),
            ),
          ],
        ),
        DropdownMenu(
          initialSelection: widget.initialSelection,
          controller: widget.controller,
          onSelected: (value) => widget.onSelected,
          dropdownMenuEntries: widget.dropdownMenuEntries ?? [],
          focusNode: widget.focusNode,
          hintText: widget.hintText ?? 'Select an option',
          keyboardType: widget.keyboardType ?? TextInputType.text,
        ),
      ],
    );
  }
}
