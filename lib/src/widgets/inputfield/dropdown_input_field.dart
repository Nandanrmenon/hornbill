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
  final double? width; // still honored if explicitly provided

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: widget.icon != null ? 8.0 : 4.0,
      children: [
        widget.icon ?? const SizedBox.shrink(),
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use explicit width if given, otherwise fall back to
              // the real, finite width the Flexible/Expanded gave us.
              final effectiveWidth = widget.width ?? constraints.maxWidth;

              return DropdownMenu<String>(
                width: effectiveWidth,
                initialSelection: widget.initialSelection,
                controller: widget.controller,
                onSelected: widget.onSelected, // see fix #2 below
                dropdownMenuEntries: widget.dropdownMenuEntries ?? [],
                focusNode: widget.focusNode,
                alignmentOffset: const Offset(0, 4),
                label: widget.label != null ? Text(widget.label!) : null,
                hintText: widget.hintText ?? 'Select an option',
                keyboardType: widget.keyboardType ?? TextInputType.text,
              );
            },
          ),
        ),
      ],
    );
  }
}