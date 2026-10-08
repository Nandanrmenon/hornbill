import 'package:flutter/services.dart';
import 'package:hornbill/hornbill.dart';
import 'package:hornbill/src/theme.dart';
import 'package:material_ui/material_ui.dart';

enum HTextFieldVariant { flat, faded, bordered, underlined }

enum HTextFieldSize { sm, md, lg }

/// A text field styled to match [HSelect].
///
///  * four variants, three sizes, label above the field
///  * description, error message, required marker
///  * start / end content, inline prefix / suffix text, clear button and a
///    show / hide toggle for obscured text
///  * works inside a [Form]: [validator], [onSaved] and [autovalidateMode]
///    behave like they do on a `TextFormField`
///  * single line by default; set [maxLines] / [minLines] (or [expands]) for
///    multi-line input
///
/// The field fills the available width. Inside a `Row`, wrap it in `Expanded`
/// or pass [width].
///
/// ```dart
/// HTextField(
///   label: 'Email',
///   hintText: 'you@example.com',
///   keyboardType: TextInputType.emailAddress,
///   startContent: const Icon(Icons.mail_outline_rounded),
///   isRequired: true,
///   isClearable: true,
///   onChanged: (v) => print(v),
/// )
/// ```
class HTextField extends StatefulWidget {
  const HTextField({
    super.key,
    // Content
    this.label,
    this.hintText,
    this.description,
    this.errorText,
    this.counterText,
    this.prefixText,
    this.suffixText,
    this.initialValue,
    // Look
    this.variant = HTextFieldVariant.flat,
    this.size = HTextFieldSize.md,
    this.radius,
    this.width,
    this.startContent,
    this.endContent,
    this.icon,
    this.suffix,
    this.isClearable = false,
    this.showVisibilityToggle = true,
    this.style,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.showCursor,
    // Behaviour
    this.controller,
    this.focusNode,
    this.isRequired = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.autocorrect,
    this.enableSuggestions = true,
    this.enableInteractiveSelection,
    this.expands = false,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.maxLengthEnforcement,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardAppearance,
    this.autofillHints,
    this.scrollPadding = const EdgeInsets.all(20),
    this.scrollController,
    this.scrollPhysics,
    this.spellCheckConfiguration,
    this.contextMenuBuilder,
    this.undoController,
    this.restorationId,
    // Callbacks
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    // Form
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.groupId,
  });

  // ---- Content --------------------------------------------------------------

  final String? label;
  final String? hintText;

  /// Helper text under the field.
  final String? description;

  /// When non-null the field is invalid: red border and this message. Takes
  /// priority over the message returned by [validator].
  final String? errorText;

  /// Text shown at the right under the field. When null and [maxLength] is
  /// set, a `length/maxLength` counter is shown. Pass `''` to hide it.
  final String? counterText;

  /// Inline text before / after the input (e.g. `\$`, `kg`).
  final String? prefixText;
  final String? suffixText;

  /// Initial text. Ignored when [controller] is provided.
  final String? initialValue;

  // ---- Look -----------------------------------------------------------------

  final HTextFieldVariant variant;

  /// sm = 32px, md = 40px, lg = 48px tall. These match [HButton]'s heights, and
  /// like [HButton] the default is md on every platform.
  final HTextFieldSize size;

  /// Overrides the corner radius (sm 8, md 12, lg 14).
  final double? radius;

  /// Fixed width. Defaults to the available width.
  final double? width;

  /// Widget before the input (usually an icon).
  final Widget? startContent;

  /// Widget after the input (usually an icon or a small button).
  final Widget? endContent;

  /// Backwards-compatible alias for [startContent]. Unlike before, it is now
  /// drawn inside the field instead of beside it.
  final Widget? icon;

  /// Backwards-compatible alias for [endContent].
  final Widget? suffix;

  /// Shows a clear (x) button while the field has text and is editable.
  final bool isClearable;

  /// When [obscureText] is true, shows an eye button to reveal the text.
  final bool showVisibilityToggle;

  /// Merged on top of the field's default input text style.
  final TextStyle? style;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final Color? cursorColor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool? showCursor;

  // ---- Behaviour ------------------------------------------------------------

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Adds a red `*` to the label and fails validation when empty.
  final bool isRequired;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool canRequestFocus;
  final bool obscureText;
  final String obscuringCharacter;
  final bool? autocorrect;
  final bool enableSuggestions;
  final bool? enableInteractiveSelection;

  /// Fill the parent's height. Needs a bounded height (e.g. inside `Expanded`
  /// or a `SizedBox`). [maxLines] and [minLines] are ignored.
  final bool expands;
  final int? minLines;

  /// 1 by default. Null means unlimited.
  final int? maxLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Brightness? keyboardAppearance;
  final Iterable<String>? autofillHints;
  final EdgeInsets scrollPadding;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final UndoHistoryController? undoController;
  final String? restorationId;

  // ---- Callbacks ------------------------------------------------------------

  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;

  // ---- Form -----------------------------------------------------------------

  /// Runs after the built-in required check.
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final AutovalidateMode? autovalidateMode;

  final Object? groupId;

  @override
  State<HTextField> createState() => _HTextFieldState();
}

class _HTextFieldState extends State<HTextField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;

  bool _hovered = false;
  bool _focused = false;
  bool _obscured = true;

  TextEditingController get _controller => widget.controller ?? _ownController!;
  FocusNode get _focusNode => widget.focusNode ?? _ownFocusNode!;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownController = TextEditingController(text: widget.initialValue);
    }
    if (widget.focusNode == null) {
      _ownFocusNode = FocusNode(debugLabel: 'HTextField');
    }
    _controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChanged);
    _focused = _focusNode.hasFocus;
    _obscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant HTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      final old = oldWidget.controller ?? _ownController!;
      old.removeListener(_onControllerChanged);
      if (widget.controller == null) {
        _ownController = TextEditingController(text: old.text);
      } else {
        _ownController?.dispose();
        _ownController = null;
      }
      _controller.addListener(_onControllerChanged);
    }

    if (oldWidget.focusNode != widget.focusNode) {
      final old = oldWidget.focusNode ?? _ownFocusNode!;
      old.removeListener(_onFocusChanged);
      if (widget.focusNode == null) {
        _ownFocusNode = FocusNode(debugLabel: 'HTextField');
      } else {
        _ownFocusNode?.dispose();
        _ownFocusNode = null;
      }
      _focusNode.addListener(_onFocusChanged);
      _focused = _focusNode.hasFocus;
    }

    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _focusNode.removeListener(_onFocusChanged);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onFocusChanged() {
    if (mounted) setState(() => _focused = _focusNode.hasFocus);
  }

  // ---------------------------------------------------------------------------
  // Derived state
  // ---------------------------------------------------------------------------

  bool get _multiline => widget.expands || widget.maxLines != 1;

  bool get _editable => widget.enabled && !widget.readOnly;

  String? _validate(String? _) {
    final text = _controller.text;
    if (widget.isRequired && text.isEmpty) {
      return '${widget.label ?? 'Field'} is required';
    }
    return widget.validator?.call(text);
  }

  // ---------------------------------------------------------------------------
  // Size / style tokens
  // ---------------------------------------------------------------------------

  double _height(HTextFieldSize s) => switch (s) {
    HTextFieldSize.sm => 32,
    HTextFieldSize.md => 40,
    HTextFieldSize.lg => 48,
  };

  double _radiusFor(HTextFieldSize s) =>
      widget.radius ??
      switch (s) {
        HTextFieldSize.sm => 8,
        HTextFieldSize.md => 12,
        HTextFieldSize.lg => 14,
      };

  double _valueFont(HTextFieldSize s) => s == HTextFieldSize.lg ? 16 : 14;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: _controller.text,
      enabled: widget.enabled,
      autovalidateMode: widget.autovalidateMode,
      onSaved: widget.onSaved,
      validator: _validate,
      builder: (state) => _buildField(context, state),
    );
  }

  Widget _buildField(BuildContext context, FormFieldState<String> state) {
    final c = HColors.of(context);
    final size = widget.size;
    final height = _height(size);
    final radius = _radiusFor(size);
    final valueFont = _valueFont(size);
    final underlined = widget.variant == HTextFieldVariant.underlined;

    final errorMessage = widget.errorText ?? state.errorText;
    final invalid = errorMessage != null;
    final active = _focused;

    // ---- Colours per variant (mirrors HSelect) ----
    Color? bg;
    Color? borderColor;
    switch (widget.variant) {
      case HTextFieldVariant.flat:
        bg = (_hovered && !active) ? c.neutral[200]! : c.neutral[100]!;
        borderColor = null;
      case HTextFieldVariant.faded:
        bg = c.neutral[100]!;
        borderColor = active
            ? c.neutral[400]!
            : (_hovered ? c.neutral[300]! : c.neutral[200]!);
      case HTextFieldVariant.bordered:
        bg = null;
        borderColor = active
            ? c.foreground
            : (_hovered ? c.neutral[400]! : c.neutral[200]!);
      case HTextFieldVariant.underlined:
        bg = null;
        borderColor = active
            ? c.foreground
            : (_hovered ? c.neutral[300]! : c.neutral[200]!);
    }
    if (invalid) borderColor = c.danger.base;
    if (invalid && widget.variant == HTextFieldVariant.flat) {
      bg = Color.alphaBlend(
        c.danger.base.withValues(alpha: 0.1),
        c.neutral[100]!,
      );
    }

    // Height left inside the border, used to centre things.
    final borderTotal = borderColor == null ? 0.0 : (underlined ? 2.0 : 4.0);
    final inner = height - borderTotal;

    // ---- Input ----
    final textStyle = TextStyle(
      fontSize: valueFont,
      height: 1.3,
      color: c.foreground,
    ).merge(widget.style);

    final textField = TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      canRequestFocus: widget.canRequestFocus,
      obscureText: widget.obscureText && _obscured,
      obscuringCharacter: widget.obscuringCharacter,
      autocorrect: widget.autocorrect ?? false,
      enableSuggestions: widget.enableSuggestions,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      expands: widget.expands,
      minLines: widget.expands ? null : widget.minLines,
      maxLines: widget.expands ? null : widget.maxLines,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      inputFormatters: widget.inputFormatters,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      keyboardAppearance: widget.keyboardAppearance,
      autofillHints: widget.autofillHints,
      scrollPadding: widget.scrollPadding,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      spellCheckConfiguration: widget.spellCheckConfiguration,
      contextMenuBuilder: widget.contextMenuBuilder,
      undoController: widget.undoController,
      restorationId: widget.restorationId,
      style: textStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      cursorColor: widget.cursorColor,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      showCursor: widget.showCursor,
      groupId: widget.groupId ?? Object(),
      // The counter is drawn under the field by HTextField itself.
      buildCounter:
          (
            context, {
            required currentLength,
            required isFocused,
            required maxLength,
          }) => null,
      // Every border is turned off explicitly so none of the global
      // InputDecorationTheme borders show through.
      decoration: InputDecoration(
        isCollapsed: true,
        filled: false,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: valueFont,
          height: 1.3,
          color: c.mutedForeground,
        ),
      ),
      onChanged: (v) {
        state.didChange(v);
        widget.onChanged?.call(v);
      },
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onFieldSubmitted,
    );

    // Inline prefix / suffix text next to the input.
    Widget inlineText(String text) => Text(
      text,
      style: TextStyle(
        fontSize: valueFont,
        height: 1.3,
        color: c.mutedForeground,
      ),
    );
    final fieldRow = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.prefixText != null)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: inlineText(widget.prefixText!),
          ),
        Expanded(child: textField),
        if (widget.suffixText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: inlineText(widget.suffixText!),
          ),
      ],
    );

    // ---- Body: the input, centred vertically ----
    final vPad = (_multiline ? 8.0 : ((inner - valueFont * 1.3) / 2)).clamp(
      4.0,
      double.infinity,
    );
    final body = ConstrainedBox(
      constraints: BoxConstraints(minHeight: inner),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPad),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
          child: fieldRow,
        ),
      ),
    );

    // ---- Leading / trailing ----
    final start = widget.startContent ?? widget.icon;
    final end = widget.endContent ?? widget.suffix;
    final showClear =
        widget.isClearable && _editable && _controller.text.isNotEmpty;
    final showToggle = widget.obscureText && widget.showVisibilityToggle;

    Widget aligned(Widget child) => _multiline
        ? Padding(padding: const EdgeInsets.only(top: 12), child: child)
        : child;

    final trigger = MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.text
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: _multiline ? null : height,
        constraints: _multiline ? BoxConstraints(minHeight: height) : null,
        padding: EdgeInsets.symmetric(
          horizontal: underlined ? 0 : (size == HTextFieldSize.sm ? 10 : 12),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: underlined ? null : BorderRadius.circular(radius),
          border: borderColor == null
              ? null
              : underlined
              ? Border(bottom: BorderSide(color: borderColor, width: 2))
              : Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          crossAxisAlignment: _multiline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (start != null) ...[
              aligned(
                IconTheme(
                  data: IconThemeData(color: c.mutedForeground, size: 20),
                  child: start,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(child: body),
            if (showClear) ...[
              const SizedBox(width: 4),
              aligned(
                _FieldIconButton(
                  icon: Icons.cancel_rounded,
                  onTap: () {
                    _controller.clear();
                    state.didChange('');
                    widget.onChanged?.call('');
                    _focusNode.requestFocus();
                  },
                ),
              ),
            ],
            if (showToggle) ...[
              const SizedBox(width: 4),
              aligned(
                _FieldIconButton(
                  icon: _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onTap: () => setState(() => _obscured = !_obscured),
                ),
              ),
            ],
            if (end != null) ...[
              const SizedBox(width: 8),
              aligned(
                IconTheme(
                  data: IconThemeData(color: c.mutedForeground, size: 20),
                  child: end,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // ---- Helper row: description / error + counter ----
    final helper = invalid ? errorMessage : widget.description;
    final String? counter = widget.counterText != null
        ? (widget.counterText!.isEmpty ? null : widget.counterText)
        : (widget.maxLength != null
              ? '${_controller.text.length}/${widget.maxLength}'
              : null);

    return SizedBox(
      width: widget.width ?? double.infinity,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: invalid ? c.danger.base : c.foreground,
                  ),
                  child: _labelText(c),
                ),
              ),
            trigger,
            if (helper != null || counter != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: helper == null
                          ? const SizedBox.shrink()
                          : Text(
                              helper,
                              style: TextStyle(
                                fontSize: 12,
                                color: invalid
                                    ? c.danger.base
                                    : c.mutedForeground,
                              ),
                            ),
                    ),
                    if (counter != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        counter,
                        style: TextStyle(
                          fontSize: 12,
                          color: c.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _labelText(HColors c) {
    final label = widget.label!;
    if (!widget.isRequired) {
      return Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(color: c.danger.base),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Small tappable icon used for the clear and show / hide buttons.
class _FieldIconButton extends StatelessWidget {
  const _FieldIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HButton(
      variant: HButtonVariant.light,
      size: HButtonSize.sm,
      onPressed: onTap,
      icon: icon,
    );
  }
}
