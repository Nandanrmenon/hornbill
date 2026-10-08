import 'package:flutter_code_view/flutter_code_view.dart';
import 'package:hornbill/hornbill.dart';
import 'package:hornbill_example/widgets/prop_table.dart';
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

class SelectScreen extends StatefulWidget {
  const SelectScreen({super.key});

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  String? _basic;
  String? _sm = 'cat';
  String? _md = 'dog';
  String? _lg = 'bird';
  String? _inside;
  String? _outside;
  String? _required;
  String? _withIcons;
  String? _row;
  final Set<String> _multi = {'cat', 'dog'};

  // Variant demos
  final Map<HSelectVariant, String?> _variants = {
    for (final v in HSelectVariant.values) v: null,
  };

  String _title(String s) => s[0].toUpperCase() + s.substring(1);

  Widget _card(Widget child, String? title, String? subtitle) => HFilledCard(
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
    child: Text(
      text,
      style: TextStyle(color: HColors.of(context).mutedForeground),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = HColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HScaffold(
      appBar: HAppBar(title: const Text('Select')),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: _text(
            'HSelect lets people pick one or several options from a list. '
            'The list opens in a popover below the field (or above it when '
            'there is no room), and it is fully keyboard accessible.',
          ),
        ),
        SliverToBoxAdapter(
          child: _card(
            HSelect<String>(
              label: 'Favorite animal',
              placeholder: 'Select an animal',
              value: _basic,
              onChanged: (v) => setState(() => _basic = v),
              items: _animals,
            ),
            'Basic',
            null,
          ),
        ),
        SliverToBoxAdapter(
          child: _card(
            Column(
              spacing: 16,
              children: [
                for (final v in HSelectVariant.values)
                  HSelect<String>(
                    variant: v,
                    label: _title(v.name),
                    placeholder: 'Select an animal',
                    value: _variants[v],
                    onChanged: (value) => setState(() => _variants[v] = value),
                    items: _animals,
                  ),
              ],
            ),
            'Variants',
            'flat (default), faded, bordered and underlined.',
          ),
        ),
        SliverToBoxAdapter(
          child: _card(
            Column(
              spacing: 16,
              children: [
                HSelect<String>(
                  size: HSelectSize.sm,
                  label: 'Small',
                  value: _sm,
                  onChanged: (v) => setState(() => _sm = v),
                  items: _animals,
                ),
                HSelect<String>(
                  size: HSelectSize.md,
                  label: 'Medium',
                  value: _md,
                  onChanged: (v) => setState(() => _md = v),
                  items: _animals,
                ),
                HSelect<String>(
                  size: HSelectSize.lg,
                  label: 'Large',
                  value: _lg,
                  onChanged: (v) => setState(() => _lg = v),
                  items: _animals,
                ),
              ],
            ),
            'Sizes',
            'sm, md and lg. When you leave size out, it adapts: small on desktop and wide screens, medium on mobile.',
          ),
        ),
        SliverToBoxAdapter(
          child: _card(
            Column(
              spacing: 16,
              children: [
                HSelect<String>(
                  label: 'Inside',
                  placeholder: 'Select an animal',
                  value: _inside,
                  onChanged: (v) => setState(() => _inside = v),
                  items: _animals,
                ),
                HSelect<String>(
                  label: 'Outside',
                  placeholder: 'Select an animal',
                  value: _outside,
                  onChanged: (v) => setState(() => _outside = v),
                  items: _animals,
                ),
              ],
            ),
            'Label placement',
            'Inside floats the label above the value (default).',
          ),
        ),
        SliverToBoxAdapter(
          child: _card(
            Column(
              spacing: 16,
              children: [
                HSelect<String>(
                  label: 'Favorite animal',
                  description: 'Choose the animal you like the most.',
                  placeholder: 'Select an animal',
                  value: _inside,
                  onChanged: (v) => setState(() => _inside = v),
                  items: _animals,
                ),
                HSelect<String>(
                  label: 'Favorite animal',
                  isRequired: true,
                  placeholder: 'Select an animal',
                  // Shown only while nothing is selected.
                  errorText: _required == null
                      ? 'Please select an animal'
                      : null,
                  value: _required,
                  onChanged: (v) => setState(() => _required = v),
                  items: _animals,
                ),
              ],
            ),
            'Description, required and error',
            null,
          ),
        ),
        SliverToBoxAdapter(
          child: _card(
            HSelect<String>(
              label: 'Contact method',
              placeholder: 'How should we reach you?',
              startContent: const Icon(Symbols.contact_page_rounded),
              value: _withIcons,
              onChanged: (v) => setState(() => _withIcons = v),
              items: const [
                HSelectItem(
                  value: 'email',
                  label: 'Email',
                  icon: Symbols.mail_rounded,
                ),
                HSelectItem(
                  value: 'phone',
                  label: 'Phone',
                  icon: Symbols.call_rounded,
                ),
                HSelectItem(
                  value: 'chat',
                  label: 'Chat',
                  icon: Symbols.chat_rounded,
                ),
              ],
            ),
            'Icons',
            'startContent on the field, icon or leading on items.',
          ),
        ),
        SliverToBoxAdapter(
          child: _card(
            HSelect<String>.multiple(
              label: 'Favorite animals',
              placeholder: 'Select animals',
              values: _multi,
              onChanged: (v) => setState(() {
                _multi
                  ..clear()
                  ..addAll(v);
              }),
              items: _animals,
            ),
            'Multiple selection',
            'The menu stays open while you toggle items.',
          ),
        ),
        SliverToBoxAdapter(
          child: _card(
            Column(
              spacing: 16,
              children: [
                HSelect<String>(
                  isDisabled: true,
                  label: 'Whole field disabled',
                  value: 'cat',
                  onChanged: (_) {},
                  items: _animals,
                ),
                HSelect<String>(
                  label: 'Single item disabled',
                  description: 'Hamster can not be picked.',
                  placeholder: 'Select an animal',
                  value: _basic,
                  onChanged: (v) => setState(() => _basic = v),
                  items: _animals,
                ),
              ],
            ),
            'Disabled',
            'The whole field can be disabled, or individual items can be disabled.',
          ),
        ),

        SliverToBoxAdapter(
          child: _card(
            Row(
              spacing: 12,
              children: [
                Expanded(
                  flex: 3,
                  child: HTextField(label: 'Name', hintText: 'Your name'),
                ),
                Expanded(
                  flex: 2,
                  child: HSelect<String>(
                    label: 'Animal',

                    placeholder: 'Select',
                    value: _row,
                    onChanged: (v) => setState(() => _row = v),
                    items: _animals,
                  ),
                ),
              ],
            ),
            'Inside a Row',
            'The field fills the available width, so use Expanded.',
          ),
        ),

        SliverToBoxAdapter(
          child: _card(
            PropTable(
              colors: colors,
              rows: const [
                (
                  'Enter / Space / Arrow Down / Arrow Up',
                  '',
                  'Open the menu (when it is closed).',
                ),
                ('Arrow Down / Arrow Up', '', 'Move the highlight.'),
                ('Home / End', '', 'Jump to the first or last option.'),
                ('Enter / Space', '', 'Select the highlighted option.'),
                ('Escape', '', 'Close the menu.'),
                ('Tab', '', 'Close the menu and move focus on.'),
              ],
            ),
            'Keyboard',
            'Keyboard shortcuts for the field and the menu.',
          ),
        ),
        SliverToBoxAdapter(
          child: _card(
            PropTable(
              colors: colors,
              rows: const [
                ('items', 'List<HSelectItem<T>>', 'The options. Required.'),
                ('value', 'T?', 'Selected value (HSelect.new).'),
                (
                  'values',
                  'Set<T>',
                  'Selected values (HSelect.multiple). Required there.',
                ),
                (
                  'onChanged',
                  'ValueChanged<T> / ValueChanged<Set<T>>',
                  'Called with the new selection. Null disables the field.',
                ),
                ('label', 'String?', 'Field label.'),
                ('placeholder', 'String?', 'Shown while nothing is selected.'),
                ('description', 'String?', 'Helper text under the field.'),
                (
                  'errorText',
                  'String?',
                  'Makes the field invalid and shows this message.',
                ),
                (
                  'variant',
                  'HSelectVariant',
                  'flat (default), faded, bordered or underlined.',
                ),
                (
                  'size',
                  'HSelectSize?',
                  'sm, md or lg. Null adapts to the device.',
                ),
                (
                  'labelPlacement',
                  'HSelectLabelPlacement',
                  'inside (default) or outside.',
                ),
                (
                  'radius',
                  'double?',
                  'Corner radius. Defaults by size (8, 12, 14).',
                ),
                ('isRequired', 'bool', 'Adds a red * to the label.'),
                ('isDisabled', 'bool', 'Disables the field.'),
                ('startContent', 'Widget?', 'Widget before the value.'),
                ('width', 'double?', 'Fixed width. Defaults to fill.'),
                (
                  'maxMenuHeight',
                  'double',
                  'Height the list can grow to before it scrolls (256).',
                ),
              ],
            ),
            'HSelect properties',
            'HSelect.new for one value, HSelect.multiple for many.',
          ),
        ),
        SliverToBoxAdapter(
          child: _card(
            PropTable(
              colors: colors,
              rows: const [
                ('value', 'T', 'The value this option represents. Required.'),
                ('label', 'String', 'Text in the list and in the field.'),
                ('description', 'String?', 'Small text under the label.'),
                ('icon', 'IconData?', 'Shorthand for a leading icon.'),
                (
                  'leading',
                  'Widget?',
                  'Custom leading widget. Takes priority over icon.',
                ),
                ('enabled', 'bool', 'Set false to make it unselectable.'),
              ],
            ),
            'HSelectItem properties',
            'The options in the list. Use HSelectItem<T> for each.',
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: FlutterCodeView(
              source: sampleSelectCode,
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
            ),
          ),
        ),
      ],
    );
  }
}

String sampleSelectCode = '''
// Single selection
HSelect<String>(
  label: 'Favorite animal',
  placeholder: 'Select an animal',
  value: animal,
  onChanged: (v) => setState(() => animal = v),
  items: const [
    HSelectItem(value: 'cat', label: 'Cat', description: 'Independent'),
    HSelectItem(value: 'dog', label: 'Dog', description: 'Loyal'),
    HSelectItem(value: 'fish', label: 'Fish', enabled: false),
  ],
)

// Variant, size and label placement
HSelect<String>(
  variant: HSelectVariant.bordered,   // flat, faded, bordered, underlined
  size: HSelectSize.lg,               // sm, md, lg (null = adaptive)
  labelPlacement: HSelectLabelPlacement.outside,
  label: 'Favorite animal',
  value: animal,
  onChanged: (v) => setState(() => animal = v),
  items: animals,
)

// Description, required and error
HSelect<String>(
  label: 'Favorite animal',
  isRequired: true,
  description: 'Choose the animal you like the most.',
  errorText: animal == null ? 'Please select an animal' : null,
  value: animal,
  onChanged: (v) => setState(() => animal = v),
  items: animals,
)

// Icons
HSelect<String>(
  label: 'Contact method',
  startContent: Icon(Symbols.contact_page_rounded),
  value: method,
  onChanged: (v) => setState(() => method = v),
  items: const [
    HSelectItem(value: 'email', label: 'Email', icon: Symbols.mail_rounded),
    HSelectItem(value: 'phone', label: 'Phone', icon: Symbols.call_rounded),
  ],
)

// Multiple selection
HSelect<String>.multiple(
  label: 'Favorite animals',
  values: selected,                   // Set<String>
  onChanged: (v) => setState(() => selected = v),
  items: animals,
)

// The field fills the available width. In a Row, use Expanded (or width:).
Row(
  children: [
    Expanded(child: HTextField(label: 'Name')),
    Expanded(child: HSelect<String>(/* ... */)),
  ],
)
''';
