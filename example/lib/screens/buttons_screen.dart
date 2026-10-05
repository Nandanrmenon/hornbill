import 'package:flutter_code_view/flutter_code_view.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class ButtonsScreen extends StatefulWidget {
  const ButtonsScreen({super.key});

  @override
  State<ButtonsScreen> createState() => _ButtonsScreenState();
}

class _ButtonsScreenState extends State<ButtonsScreen> {
  bool _loading = false;

  String _title(String s) => s[0].toUpperCase() + s.substring(1);

  Widget _wrap(List<Widget> children) => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HScaffold(
      appBar: HAppBar(title: const Text('Buttons')),
      slivers: [
        // ---- Variants ----
        SliverToBoxAdapter(child: HListHeader(title: 'Variants')),
        SliverToBoxAdapter(
          child: _wrap([
            for (final v in HButtonVariant.values)
              HButton(
                variant: v,
                label: Text(_title(v.name)),
                onPressed: () {},
              ),
          ]),
        ),

        // ---- Colors ----
        SliverToBoxAdapter(child: HListHeader(title: 'Colors')),
        SliverToBoxAdapter(
          child: _wrap([
            for (final c in HButtonColor.values)
              HButton(
                color: c,
                label: Text(
                  c == HButtonColor.defaultColor ? 'Default' : _title(c.name),
                ),
                onPressed: () {},
              ),
          ]),
        ),
        SliverToBoxAdapter(
          child: _wrap([
            for (final c in HButtonColor.values)
              HButton(
                variant: HButtonVariant.flat,
                color: c,
                label: Text(
                  c == HButtonColor.defaultColor ? 'Default' : _title(c.name),
                ),
                onPressed: () {},
              ),
          ]),
        ),

        // ---- Sizes ----
        SliverToBoxAdapter(child: HListHeader(title: 'Sizes')),
        SliverToBoxAdapter(
          child: _wrap([
            for (final s in HButtonSize.values)
              HButton(
                color: HButtonColor.primary,
                size: s,
                label: Text(_title(s.name)),
                onPressed: () {},
              ),
          ]),
        ),

        // ---- Icons ----
        SliverToBoxAdapter(child: HListHeader(title: 'Icons')),
        SliverToBoxAdapter(
          child: _wrap([
            HButton(
              color: HButtonColor.primary,
              icon: Symbols.add_rounded,
              label: const Text('Start icon'),
              onPressed: () {},
            ),
            HButton(
              variant: HButtonVariant.bordered,
              color: HButtonColor.secondary,
              icon: Symbols.arrow_forward_rounded,
              iconPosition: HButtonIconPosition.right,
              label: const Text('End icon'),
              onPressed: () {},
            ),
            HButton(
              variant: HButtonVariant.flat,
              color: HButtonColor.danger,
              icon: Symbols.delete_rounded,
              onPressed: () {},
            ),
            HButton(
              variant: HButtonVariant.shadow,
              color: HButtonColor.success,
              icon: Symbols.check_rounded,
              onPressed: () {},
            ),
          ]),
        ),

        // ---- States ----
        SliverToBoxAdapter(child: HListHeader(title: 'States')),
        SliverToBoxAdapter(
          child: _wrap([
            HButton(
              color: HButtonColor.primary,
              isLoading: _loading,
              label: Text(_loading ? 'Loading' : 'Tap to load'),
              onPressed: () async {
                setState(() => _loading = true);
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) setState(() => _loading = false);
              },
            ),
            HButton(
              color: HButtonColor.primary,
              label: const Text('Disabled'),
              onPressed: null,
            ),
            HButton(
              variant: HButtonVariant.bordered,
              color: HButtonColor.primary,
              label: const Text('Disabled'),
              onPressed: null,
            ),
          ]),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: HButton(
              fullWidth: true,
              color: HButtonColor.primary,
              label: const Text('Full width'),
              onPressed: () {},
            ),
          ),
        ),

        // ---- Usage ----
        SliverToBoxAdapter(child: HListHeader(title: 'Usage')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FlutterCodeView(
              source: sampleButtonCode,
              themeType: isDark ? ThemeType.vs2015 : ThemeType.githubGist,
              language: Languages.dart,
              autoDetection: true,
              borderColor: Theme.of(context).colorScheme.outlineVariant,
              paddingBorder: const EdgeInsets.all(1),
              borderRadiusCodeView: BorderRadius.circular(8),
              borderRadius: BorderRadius.circular(8),
              showLineNumbers: true,
              fontSize: 14,
              selectionColor: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.3),
            ),
          ),
        ),

        // ---- Icon buttons ----
        SliverToBoxAdapter(child: HListHeader(title: 'Icon buttons')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              spacing: 16.0,
              children: [
                HIconButton.filled(
                  icon: Symbols.android_rounded,
                  onPressed: () {},
                  tooltip: 'Button',
                ),
                HIconButton.outlined(
                  icon: Symbols.android_rounded,
                  onPressed: () {},
                  tooltip: 'Button',
                ),
                HIconButton.tonal(
                  icon: Symbols.android_rounded,
                  onPressed: () {},
                  tooltip: 'Button',
                ),
                HIconButton.plain(
                  icon: Symbols.android_rounded,
                  onPressed: () {},
                  tooltip: 'Button',
                ),
              ],
            ),
          ),
        ),
      ],
      floatingActionButton: HButton(
        variant: HButtonVariant.shadow,
        color: HButtonColor.primary,
        label: const Text('Next'),
        icon: Symbols.arrow_forward_rounded,
        iconPosition: HButtonIconPosition.right,
        onPressed: () {
          Navigator.pushNamed(context, '/components/inputs');
        },
      ),
    );
  }
}

String sampleButtonCode = '''
// Variant + color + size
HButton(
  label: Text('Save'),
  variant: HButtonVariant.solid,   // solid, bordered, light, flat,
                                   // faded, shadow, ghost
  color: HButtonColor.primary,     // defaultColor, primary, secondary,
                                   // success, warning, danger
  size: HButtonSize.md,            // sm, md, lg
  onPressed: () {},
)

// With an icon
HButton(
  label: Text('Next'),
  icon: Symbols.arrow_forward_rounded,
  iconPosition: HButtonIconPosition.right,
  variant: HButtonVariant.flat,
  color: HButtonColor.secondary,
  onPressed: () {},
)

// Icon only (no label)
HButton(
  icon: Symbols.delete_rounded,
  variant: HButtonVariant.flat,
  color: HButtonColor.danger,
  onPressed: () {},
)

// Loading / full width / disabled
HButton(label: Text('Submit'), isLoading: true, onPressed: () {});
HButton(label: Text('Continue'), fullWidth: true, onPressed: () {});
HButton(label: Text('Disabled'), onPressed: null);
''';
