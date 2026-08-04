import 'package:flutter/material.dart';

class HornbillTextField extends StatefulWidget {
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
  const HornbillTextField({
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
  });

  @override
  State<HornbillTextField> createState() => _HornbillTextFieldState();
}

class _HornbillTextFieldState extends State<HornbillTextField> {
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
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          validator: (value) {
            if (widget.isRequired) {
              return value == null || value.isEmpty
                  ? '${widget.label ?? 'Field'} is required'
                  : null;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: widget.trailingWidget,
          ),
          keyboardType: widget.keyboardType ?? TextInputType.text,
          focusNode: widget.focusNode,
          onFieldSubmitted: widget.onFieldSubmitted,
        ),
      ],
    );
  }
}
