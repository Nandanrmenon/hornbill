import 'package:flutter_code_view/flutter_code_view.dart';
import 'package:hornbill/hornbill.dart';
import 'package:hornbill_example/widgets/prop_table.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

const _animals = <HSelectItem<String>>[
  HSelectItem(value: 'cat', label: 'Cat'),
  HSelectItem(value: 'dog', label: 'Dog'),
  HSelectItem(value: 'bird', label: 'Bird'),
];

class TextinputfieldScreen extends StatefulWidget {
  const TextinputfieldScreen({super.key});

  @override
  State<TextinputfieldScreen> createState() => _TextinputfieldScreenState();
}

class _TextinputfieldScreenState extends State<TextinputfieldScreen> {
  final _formKey = GlobalKey<FormState>();

  // A controller you pass in is yours to dispose.
  final _controller = TextEditingController(text: 'Controlled text');

  String _lastChange = '';
  String _formResult = '';
  String? _row;

  /// Stores the examples currently displaying code.
  final Set<String> _showCode = <String>{};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitForm() {
    final valid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _formResult = valid ? 'Form is valid' : 'Fix the errors';
    });
  }

  String _title(String s) => s[0].toUpperCase() + s.substring(1);

  Widget _card(Widget child, String? title, String? subtitle) {
    return HFilledCard(
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
  }

  Widget _text(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Text(text),
  );

  bool _isShowingCode(String title) => _showCode.contains(title);

  void _toggleCode(String title) {
    setState(() {
      if (_showCode.contains(title)) {
        _showCode.remove(title);
      } else {
        _showCode.add(title);
      }
    });
  }

  /// A documentation example card with a Preview / Code toggle.
  Widget _exampleCard({
    required BuildContext context,
    required String title,
    required String? subtitle,
    required Widget preview,
    required String code,
  }) {
    final colors = HColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showCode = _isShowingCode(title);

    return HFilledCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HListHeader(
                  title: title,
                  subtitle: subtitle,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 16),
              HButton(
                icon: showCode ? Symbols.remove_red_eye : Symbols.code_blocks,
                label: Text(showCode ? 'Show Preview' : 'Show Code'),
                variant: HButtonVariant.light,
                color: .primary,
                onPressed: () => _toggleCode(title),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: showCode
                ? FlutterCodeView(
                    key: const ValueKey('code'),
                    source: code,
                    themeType: isDark ? ThemeType.vs2015 : ThemeType.githubGist,
                    language: Languages.dart,
                    autoDetection: true,
                    borderColor: colors.border,
                    paddingBorder: const EdgeInsets.all(1),
                    borderRadiusCodeView: BorderRadius.circular(8),
                    borderRadius: BorderRadius.circular(8),
                    showLineNumbers: true,
                    fontSize: 14,
                    selectionColor: colors.tertiary.base.withValues(alpha: 0.3),
                  )
                : KeyedSubtree(key: const ValueKey('preview'), child: preview),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HColors.of(context);

    return HScaffold(
      appBar: HAppBar(title: const Text('Text Input Field')),
      slivers: [
        // ---------------------------------------------------------------------
        // Intro
        // ---------------------------------------------------------------------

        const SliverToBoxAdapter(child: HListHeader(title: 'Text Input Field')),

        SliverToBoxAdapter(
          child: _text(
            'HTextField lets people type text. It matches HSelect, HComboBox '
            'and HButton: the same variants, heights and corner radii. The '
            'label is always above the field, the default size is md (40px, '
            'the same height as an HButton), and it works inside a Form like '
            'a TextFormField.',
          ),
        ),

        // ---------------------------------------------------------------------
        // Basic
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Basic',
            subtitle: 'A simple text field with a label and hint.',
            preview: const HTextField(label: 'Name', hintText: 'Your name'),
            code: '''
HTextField(
  label: 'Name',
  hintText: 'Your name',
)
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // Variants
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Variants',
            subtitle: 'flat, faded, bordered and underlined.',
            preview: Column(
              spacing: 16,
              children: [
                for (final variant in HTextFieldVariant.values)
                  HTextField(
                    variant: variant,
                    label: _title(variant.name),
                    hintText: 'Type something',
                  ),
              ],
            ),
            code: '''
for (final variant in HTextFieldVariant.values)
  HTextField(
    variant: variant,
    label: variant.name,
    hintText: 'Type something',
  ),
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // Sizes
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Sizes',
            subtitle: 'sm (32px), md (40px) and lg (48px).',
            preview: Column(
              spacing: 16,
              children: [
                for (final size in HTextFieldSize.values)
                  HTextField(
                    size: size,
                    label: _title(size.name),
                    hintText: 'Same height as an HButton',
                  ),
              ],
            ),
            code: '''
HTextField(
  size: HTextFieldSize.sm,
  label: 'Small',
  hintText: '32px',
)

HTextField(
  size: HTextFieldSize.md,
  label: 'Medium',
  hintText: '40px',
)

HTextField(
  size: HTextFieldSize.lg,
  label: 'Large',
  hintText: '48px',
)
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // Start / end content
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Start and end content',
            subtitle: 'Widgets can be placed before and after the input.',
            preview: Column(
              spacing: 16,
              children: [
                HTextField(
                  label: 'Search',
                  hintText: 'Search...',
                  startContent: const Icon(Symbols.search),
                  endContent: HButton(
                    label: const Text('Go'),
                    variant: .light,
                    onPressed: () {},
                  ),
                ),
                HTextField(
                  label: 'Price',
                  hintText: '0.00',
                  prefixText: '\$',
                  suffixText: 'USD',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
            code: '''
HTextField(
  label: 'Search',
  hintText: 'Search...',
  startContent: Icon(Symbols.search),
  endContent: HButton(
    label: Text('Go'),
    variant: .light,
    onPressed: () {},
  ),
)

HTextField(
  label: 'Price',
  hintText: '0.00',
  prefixText: '\$',
  suffixText: 'USD',
  keyboardType: TextInputType.numberWithOptions(
    decimal: true,
  ),
)
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // Clearable / password
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Clearable and password',
            subtitle: 'Built-in clear and visibility controls.',
            preview: Column(
              spacing: 16,
              children: [
                HTextField(
                  label: 'Search',
                  hintText: 'Type, then tap the x',
                  isClearable: true,
                  startContent: const Icon(Symbols.search),
                ),
                HTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  obscureText: true,
                  startContent: const Icon(Symbols.lock),
                ),
              ],
            ),
            code: '''
HTextField(
  label: 'Search',
  hintText: 'Type, then tap the x',
  isClearable: true,
  startContent: Icon(Symbols.search),
)

HTextField(
  label: 'Password',
  hintText: 'Enter your password',
  obscureText: true,
  startContent: Icon(Symbols.lock),
)
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // Description / required / error
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Description, required and error',
            subtitle: 'Helper text, required fields and validation states.',
            preview: const Column(
              spacing: 16,
              children: [
                HTextField(
                  label: 'Email',
                  hintText: 'you@example.com',
                  description: 'We will never share your email.',
                ),
                HTextField(
                  label: 'Username',
                  hintText: 'Pick a username',
                  isRequired: true,
                ),
                HTextField(
                  label: 'Email',
                  hintText: 'you@example.com',
                  errorText: 'This value is not valid',
                ),
                HTextField(
                  label: 'Email (bordered)',
                  hintText: 'you@example.com',
                  errorText: 'This value is not valid',
                  variant: HTextFieldVariant.bordered,
                ),
              ],
            ),
            code: '''
HTextField(
  label: 'Email',
  hintText: 'you@example.com',
  description: 'We will never share your email.',
)

HTextField(
  label: 'Username',
  hintText: 'Pick a username',
  isRequired: true,
)

HTextField(
  label: 'Email',
  hintText: 'you@example.com',
  errorText: 'This value is not valid',
)

HTextField(
  label: 'Email (bordered)',
  hintText: 'you@example.com',
  errorText: 'This value is not valid',
  variant: HTextFieldVariant.bordered,
)
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // Multi-line
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Multi-line',
            subtitle: 'Use minLines and maxLines for expandable text input.',
            preview: const HTextField(
              label: 'Bio',
              hintText: 'Grows from 3 to 6 lines',
              minLines: 3,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              variant: HTextFieldVariant.faded,
            ),
            code: '''
HTextField(
  label: 'Bio',
  hintText: 'Grows from 3 to 6 lines',
  minLines: 3,
  maxLines: 6,
  keyboardType: TextInputType.multiline,
  variant: HTextFieldVariant.faded,
)
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // Counter
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Character counter',
            subtitle: 'Limit input length and show a character counter.',
            preview: const HTextField(
              label: 'Short note',
              hintText: 'Max 40 characters',
              maxLength: 40,
              variant: HTextFieldVariant.bordered,
            ),
            code: '''
HTextField(
  label: 'Short note',
  hintText: 'Max 40 characters',
  maxLength: 40,
  variant: HTextFieldVariant.bordered,
)
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // onChanged / controller
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'onChanged and controller',
            subtitle: 'React to changes or control the field programmatically.',
            preview: Column(
              spacing: 16,
              children: [
                HTextField(
                  label: 'Reports changes',
                  hintText: 'Type to see onChanged',
                  description: _lastChange.isEmpty
                      ? 'Nothing typed yet'
                      : 'Last value: $_lastChange',
                  onChanged: (value) {
                    setState(() => _lastChange = value);
                  },
                ),
                HTextField(
                  label: 'Controlled',
                  controller: _controller,
                  isClearable: true,
                  description: 'Driven by a TextEditingController',
                ),
              ],
            ),
            code: '''
HTextField(
  label: 'Reports changes',
  hintText: 'Type to see onChanged',
  onChanged: (value) {
    print(value);
  },
)

final controller = TextEditingController(
  text: 'Controlled text',
);

HTextField(
  label: 'Controlled',
  controller: controller,
)

// Dispose the controller when it is no longer needed.
controller.dispose();
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // Disabled / read only
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Disabled and read only',
            subtitle: 'Disable editing or make existing text read-only.',
            preview: const Column(
              spacing: 16,
              children: [
                HTextField(
                  label: 'Disabled',
                  hintText: 'Cannot be edited',
                  enabled: false,
                ),
                HTextField(
                  label: 'Read only',
                  initialValue: 'Selectable, not editable',
                  readOnly: true,
                ),
              ],
            ),
            code: '''
HTextField(
  label: 'Disabled',
  hintText: 'Cannot be edited',
  enabled: false,
)

HTextField(
  label: 'Read only',
  initialValue: 'Selectable, not editable',
  readOnly: true,
)
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // Form validation
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Form validation',
            subtitle: 'HTextField works with Flutter Form validation.',
            preview: Form(
              key: _formKey,
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HTextField(
                    label: 'Email',
                    hintText: 'you@example.com',
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    startContent: const Icon(Symbols.mail),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      return value != null && value.contains('@')
                          ? null
                          : 'Enter a valid email address';
                    },
                  ),
                  HTextField(
                    label: 'Password',
                    hintText: 'At least 8 characters',
                    isRequired: true,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    startContent: const Icon(Symbols.lock),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      return value != null && value.length >= 8
                          ? null
                          : 'Use at least 8 characters';
                    },
                    onFieldSubmitted: (_) => _submitForm(),
                  ),
                  Row(
                    spacing: 12,
                    children: [
                      HButton(
                        label: const Text('Validate'),
                        color: HButtonColor.primary,
                        onPressed: _submitForm,
                      ),
                      if (_formResult.isNotEmpty) Text(_formResult),
                    ],
                  ),
                ],
              ),
            ),
            code: '''
final formKey = GlobalKey<FormState>();

Form(
  key: formKey,
  child: Column(
    children: [
      HTextField(
        label: 'Email',
        isRequired: true,
        validator: (value) {
          return value != null && value.contains('@')
              ? null
              : 'Enter a valid email address';
        },
      ),

      HTextField(
        label: 'Password',
        obscureText: true,
        isRequired: true,
        validator: (value) {
          return value != null && value.length >= 8
              ? null
              : 'Use at least 8 characters';
        },
      ),

      HButton(
        label: Text('Validate'),
        onPressed: () {
          formKey.currentState!.validate();
        },
      ),
    ],
  ),
)
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // Inside a Row
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _exampleCard(
            context: context,
            title: 'Inside a Row',
            subtitle:
                'Use Expanded when the field should fill available space.',
            preview: Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  flex: 3,
                  child: HTextField(label: 'Name', hintText: 'Your name'),
                ),
                Expanded(
                  flex: 2,
                  child: HSelect<String>(
                    label: 'Animal',
                    placeholder: 'Select',
                    value: _row,
                    onChanged: (value) {
                      setState(() => _row = value);
                    },
                    items: _animals,
                  ),
                ),
                HButton(
                  label: const Text('Save'),
                  color: HButtonColor.primary,
                  onPressed: () {},
                ),
              ],
            ),
            code: '''
Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Expanded(
      flex: 3,
      child: HTextField(
        label: 'Name',
        hintText: 'Your name',
      ),
    ),

    Expanded(
      flex: 2,
      child: HSelect<String>(
        label: 'Animal',
        placeholder: 'Select',
        value: selectedAnimal,
        onChanged: (value) {
          setState(() => selectedAnimal = value);
        },
        items: animals,
      ),
    ),

    HButton(
      label: Text('Save'),
      onPressed: save,
    ),
  ],
)
''',
          ),
        ),

        // ---------------------------------------------------------------------
        // API: Content and look
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _card(
            PropTable(
              colors: colors,
              rows: const [
                ('label', 'String?', 'Label above the field.'),
                ('hintText', 'String?', 'Placeholder inside the field.'),
                ('description', 'String?', 'Helper text under the field.'),
                (
                  'errorText',
                  'String?',
                  'Makes the field invalid and shows this message. '
                      'Wins over validator.',
                ),
                (
                  'counterText',
                  'String?',
                  'Replaces the counter text. Empty string hides it.',
                ),
                ('prefixText', 'String?', 'Inline text before the input.'),
                ('suffixText', 'String?', 'Inline text after the input.'),
                (
                  'initialValue',
                  'String?',
                  'Starting text. Ignored when a controller is passed.',
                ),
                (
                  'variant',
                  'HTextFieldVariant',
                  'flat (default), faded, bordered or underlined.',
                ),
                (
                  'size',
                  'HTextFieldSize',
                  'sm (32), md (40, default) or lg (48).',
                ),
                (
                  'radius',
                  'double?',
                  'Corner radius. Defaults by size (8, 12, 14).',
                ),
                ('width', 'double?', 'Fixed width. Defaults to fill.'),
                ('startContent', 'Widget?', 'Widget before the input.'),
                ('endContent', 'Widget?', 'Widget after the input.'),
                (
                  'icon / suffix',
                  'Widget?',
                  'Aliases for startContent / endContent.',
                ),
                (
                  'isClearable',
                  'bool',
                  'Shows an x button while the field has text.',
                ),
                (
                  'showVisibilityToggle',
                  'bool',
                  'Eye button when obscureText is true (true).',
                ),
                (
                  'style',
                  'TextStyle?',
                  'Merged on top of the default input text style.',
                ),
              ],
            ),
            'HTextField: content and look',
            'Properties that control what the field shows.',
          ),
        ),

        // ---------------------------------------------------------------------
        // API: Behaviour
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _card(
            PropTable(
              colors: colors,
              rows: const [
                (
                  'controller',
                  'TextEditingController?',
                  'Read or set the text. The field makes its own if null.',
                ),
                (
                  'focusNode',
                  'FocusNode?',
                  'Control focus. The field makes its own if null.',
                ),
                (
                  'isRequired',
                  'bool',
                  'Adds a red * and fails validation when empty.',
                ),
                ('enabled', 'bool', 'false greys the field out (true).'),
                ('readOnly', 'bool', 'Selectable but not editable (false).'),
                ('autofocus', 'bool', 'Focus the field on first build.'),
                ('obscureText', 'bool', 'Hide the text, e.g. passwords.'),
                (
                  'maxLines / minLines',
                  'int?',
                  'Height range in lines. maxLines is 1 by default; '
                      'null is unlimited.',
                ),
                (
                  'expands',
                  'bool',
                  'Fill the parent height. Needs a bounded height.',
                ),
                (
                  'maxLength',
                  'int?',
                  'Limits the input and shows an n/max counter.',
                ),
                (
                  'inputFormatters',
                  'List<TextInputFormatter>?',
                  'Filter or format what is typed.',
                ),
                (
                  'keyboardType',
                  'TextInputType?',
                  'On-screen keyboard to show.',
                ),
                (
                  'textInputAction',
                  'TextInputAction?',
                  'Keyboard action button (next, done, ...).',
                ),
                (
                  'textCapitalization',
                  'TextCapitalization',
                  'none (default), words, sentences or characters.',
                ),
                (
                  'autofillHints',
                  'Iterable<String>?',
                  'Hints for the platform autofill service.',
                ),
                (
                  'autocorrect / enableSuggestions',
                  'bool',
                  'Autocorrect is off by default; suggestions are on.',
                ),
                ('textAlign', 'TextAlign', 'Horizontal alignment of the text.'),
                (
                  'cursorColor, cursorWidth, ...',
                  '',
                  'Cursor appearance, same as TextField.',
                ),
                (
                  'spellCheckConfiguration, contextMenuBuilder, '
                      'scrollController, ...',
                  '',
                  'Passed straight through to TextField.',
                ),
              ],
            ),
            'HTextField: behaviour',
            'Most of these are passed straight to the TextField inside.',
          ),
        ),

        // ---------------------------------------------------------------------
        // API: Callbacks and Form
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: _card(
            PropTable(
              colors: colors,
              rows: const [
                ('onChanged', 'ValueChanged<String>?', 'Called on every edit.'),
                (
                  'onFieldSubmitted',
                  'ValueChanged<String>?',
                  'Called when the user submits (done / enter).',
                ),
                (
                  'onEditingComplete',
                  'VoidCallback?',
                  'Called when editing finishes.',
                ),
                (
                  'onTap',
                  'GestureTapCallback?',
                  'Called when the field is tapped.',
                ),
                (
                  'onTapOutside',
                  'TapRegionCallback?',
                  'Called when a tap lands outside the field.',
                ),
                (
                  'validator',
                  'FormFieldValidator<String>?',
                  'Runs after the required check. Return null if valid.',
                ),
                (
                  'onSaved',
                  'FormFieldSetter<String>?',
                  'Called by Form.save().',
                ),
                (
                  'autovalidateMode',
                  'AutovalidateMode?',
                  'When to validate without being asked.',
                ),
              ],
            ),
            'HTextField: callbacks and form',
            'Events, and the properties that connect the field to a Form.',
          ),
        ),
      ],
    );
  }
}
