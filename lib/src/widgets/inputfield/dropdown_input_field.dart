import 'package:material_ui/material_ui.dart';

class HDropDownField extends StatefulWidget {
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
  final double? width;
  const HDropDownField({
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
    this.width,
  });

  @override
  State<HDropDownField> createState() => _HDropDownFieldState();
}

class _HDropDownFieldState extends State<HDropDownField> {
  @override
  Widget build(BuildContext context) {
    // final themeColor = Theme.of(context).colorScheme;
    // final themeText = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: .center,
      spacing: widget.icon != null ? 8.0 : 4.0,
      children: [
        (widget.icon ?? const SizedBox.shrink()),
        Flexible(
          child: DropdownMenu(
            width: widget.width,
            initialSelection: widget.initialSelection,
            controller: widget.controller,
            onSelected: (value) => widget.onSelected,
            dropdownMenuEntries: widget.dropdownMenuEntries ?? [],
            focusNode: widget.focusNode,
            alignmentOffset: const Offset(0, 4),
            label: Text(widget.label!),
            hintText: widget.hintText ?? 'Select an option',
            keyboardType: widget.keyboardType ?? TextInputType.text,
          ),
        ),
      ],
    );
  }
}
