import 'package:flutter_code_view/flutter_code_view.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

class CheckboxScreen extends StatefulWidget {
  const CheckboxScreen({super.key});

  @override
  State<CheckboxScreen> createState() => _CheckboxScreenState();
}

class _CheckboxScreenState extends State<CheckboxScreen> {
  // Basic
  bool _basic = false;

  // Sizes
  bool _sm = true;
  bool _md = true;
  bool _lg = true;

  // Line through
  bool _todo = false;

  // Select all
  final Map<String, bool> _toppings = {
    'Cheese': true,
    'Mushrooms': false,
    'Olives': false,
  };

  bool get _allSelected => _toppings.values.every((v) => v);
  bool get _someSelected => _toppings.values.any((v) => v);

  void _toggleAll() {
    // Indeterminate or unchecked -> select everything; all selected -> clear.
    final next = !_allSelected;
    setState(() => _toppings.updateAll((_, _) => next));
  }

  Widget _padded(Widget child) =>
      Padding(padding: const EdgeInsets.all(16.0), child: child);

  @override
  Widget build(BuildContext context) {
    final colors = HColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HScaffold(
      appBar: HAppBar(title: const Text('Checkbox')),
      slivers: [
        // ---- Basic ----
        SliverToBoxAdapter(child: HListHeader(title: 'Basic')),
        SliverToBoxAdapter(
          child: _padded(
            HCheckBox(
              value: _basic,
              label: const Text('Check me!'),
              onChanged: (v) => setState(() => _basic = v),
            ),
          ),
        ),

        // ---- Sizes ----
        SliverToBoxAdapter(child: HListHeader(title: 'Sizes')),
        SliverToBoxAdapter(
          child: _padded(
            Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                HCheckBox(
                  value: _sm,
                  size: HCheckBoxSize.sm,
                  label: const Text('Small'),
                  onChanged: (v) => setState(() => _sm = v),
                ),
                HCheckBox(
                  value: _md,
                  size: HCheckBoxSize.md,
                  label: const Text('Medium'),
                  onChanged: (v) => setState(() => _md = v),
                ),
                HCheckBox(
                  value: _lg,
                  size: HCheckBoxSize.lg,
                  label: const Text('Large'),
                  onChanged: (v) => setState(() => _lg = v),
                ),
              ],
            ),
          ),
        ),

        // ---- Line through ----
        SliverToBoxAdapter(child: HListHeader(title: 'Line through')),
        SliverToBoxAdapter(
          child: _padded(
            HCheckBox(
              value: _todo,
              lineThrough: true,
              label: const Text('Buy groceries'),
              onChanged: (v) => setState(() => _todo = v),
            ),
          ),
        ),

        // ---- Select all / indeterminate ----
        SliverToBoxAdapter(
          child: HListHeader(
            title: 'Select all',
            subtitle: 'The parent shows a dash when only some are checked.',
          ),
        ),
        SliverToBoxAdapter(
          child: _padded(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                HCheckBox(
                  value: _allSelected,
                  isIndeterminate: _someSelected && !_allSelected,
                  label: const Text('All toppings'),
                  onChanged: (_) => _toggleAll(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      for (final entry in _toppings.entries)
                        HCheckBox(
                          value: entry.value,
                          label: Text(entry.key),
                          onChanged: (v) =>
                              setState(() => _toppings[entry.key] = v),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---- Disabled ----
        SliverToBoxAdapter(child: HListHeader(title: 'Disabled')),
        SliverToBoxAdapter(
          child: _padded(
            const Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                HCheckBox(
                  value: false,
                  onChanged: null,
                  label: Text('Unchecked'),
                ),
                HCheckBox(value: true, onChanged: null, label: Text('Checked')),
              ],
            ),
          ),
        ),

        // ---- Usage ----
        SliverToBoxAdapter(child: HListHeader(title: 'Usage')),
        SliverToBoxAdapter(
          child: _padded(
            FlutterCodeView(
              source: sampleCheckboxCode,
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

String sampleCheckboxCode = '''
// Basic
HCheckBox(
  value: checked,
  label: Text('Check me!'),
  onChanged: (v) => setState(() => checked = v),
)

// Sizes: sm (16px), md (20px, default), lg (24px)
HCheckBox(
  value: checked,
  size: HCheckBoxSize.lg,
  label: Text('Large'),
  onChanged: (v) => setState(() => checked = v),
)

// Strike the label through when checked
HCheckBox(
  value: done,
  lineThrough: true,
  label: Text('Buy groceries'),
  onChanged: (v) => setState(() => done = v),
)

// Select all (indeterminate)
HCheckBox(
  value: allSelected,
  isIndeterminate: someSelected && !allSelected,
  label: Text('All toppings'),
  onChanged: (_) => toggleAll(),
)

// Disabled: pass null
HCheckBox(value: true, onChanged: null, label: Text('Checked'))
''';
