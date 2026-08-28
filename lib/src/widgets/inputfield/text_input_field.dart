import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class HTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? counterText;
  final String? errorText;
  final String? prefixText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool isRequired;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final Icon? icon;
  final Widget? trailingWidget;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final VoidCallback? onEditingComplete;
  final Function(String)? onChanged;
  final bool? autocorrect;
  final bool expands;
  final int? maxLines;
  const HTextField({
    super.key,
    this.label,
    this.hintText,
    this.counterText,
    this.errorText,
    this.prefixText,
    this.controller,
    this.obscureText = false,
    this.isRequired = false,
    this.keyboardType,
    this.focusNode,
    this.onFieldSubmitted,
    this.icon,
    this.trailingWidget,
    this.inputFormatters,
    this.maxLength,
    this.onEditingComplete,
    this.onChanged,
    this.autocorrect,
    this.expands = false,
    this.maxLines,
  });

  @override
  State<HTextField> createState() => _HTextFieldState();
}

class _HTextFieldState extends State<HTextField> {
  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final themeText = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: .center,
      spacing: widget.icon != null ? 8.0 : 4.0,
      children: [
        (widget.icon ?? const SizedBox.shrink()),
        Flexible(
          child: TextFormField(
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
            maxLength: widget.maxLength,
            decoration: InputDecoration(
              hintText: widget.hintText,
              labelText: widget.label,
              suffixIcon: widget.trailingWidget,
              counterText: widget.counterText,
              errorText: widget.errorText,
              prefixText: widget.prefixText,
              alignLabelWithHint: true,
            ),
            autocorrect: widget.autocorrect ?? false,
            expands: widget.expands,
            maxLines: widget.expands ? null : widget.maxLines ?? 1,
            keyboardType: widget.keyboardType ?? TextInputType.text,
            inputFormatters: widget.inputFormatters,
            focusNode: widget.focusNode,
            onFieldSubmitted: widget.onFieldSubmitted,
            onEditingComplete: widget.onEditingComplete,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
