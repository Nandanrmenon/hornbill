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
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return HScaffold(
      appBar: HAppBar(title: 'Buttons'),
      slivers: [
        SliverToBoxAdapter(child: HListHeader(title: 'Text')),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  spacing: 16.0,
                  children: [
                    HButton.text(label: 'Text', onPressed: () {}),
                    HButton.text(
                      label: 'Text',
                      onPressed: () {},
                      showIcon: true,
                      icon: Symbols.add_rounded,
                    ),
                    HButton.outlined(label: 'Outlined', onPressed: () {}),
                    HButton.outlined(
                      label: 'Outlined',
                      onPressed: () {},
                      showIcon: true,
                      icon: Symbols.add_rounded,
                    ),
                    HButton.tonal(label: 'Tonal', onPressed: () {}),
                    HButton.tonal(
                      label: 'Tonal',
                      onPressed: () {},
                      showIcon: true,
                      icon: Symbols.add_rounded,
                    ),
                    HButton.filled(label: 'Filled', onPressed: () {}),
                    HButton.filled(
                      label: 'Filled',
                      onPressed: () {},
                      showIcon: true,
                      icon: Symbols.add_rounded,
                    ),
                  ],
                ),
                HListHeader(title: ' Usage'),
                FlutterCodeView(
                  source: sampleButtonCode,
                  themeType: isDark ? ThemeType.vs2015 : ThemeType.githubGist,
                  language: Languages.dart,
                  autoDetection: true,
                  borderColor: Theme.of(context).colorScheme.outlineVariant,
                  paddingBorder: EdgeInsets.all(1),
                  borderRadiusCodeView: BorderRadius.circular(8),
                  borderRadius: BorderRadius.circular(8),
                  showLineNumbers: true,
                  fontSize: 14,
                  selectionColor: Theme.of(
                    context,
                  ).colorScheme.tertiary.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),

        // Icons
        SliverToBoxAdapter(child: HListHeader(title: 'Filled')),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
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
                HIconButton.text(
                  icon: Symbols.android_rounded,
                  onPressed: () {},
                  tooltip: 'Button',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String sampleButtonCode = '''
return HScaffold(
  slivers: [
    SliverToBoxAdapter(
      child: Row(
        spacing: 16.0,
        children: [
          HButton.text(label: 'Text', onPressed: () {}),
          HButton.text(
            label: 'Text',
            onPressed: () {},
            showIcon: true,
            icon: Symbols.add_rounded,
          ),
          HButton.outlined(label: 'Outlined', onPressed: () {}),
          HButton.outlined(
            label: 'Outlined',
            onPressed: () {},
            showIcon: true,
            icon: Symbols.add_rounded,
          ),
          HButton.tonal(label: 'Tonal', onPressed: () {}),
          HButton.tonal(
            label: 'Tonal',
            onPressed: () {},
            showIcon: true,
            icon: Symbols.add_rounded,
          ),
          HButton.filled(label: 'Filled', onPressed: () {}),
          HButton.filled(
            label: 'Filled',
            onPressed: () {},
            showIcon: true,
            icon: Symbols.add_rounded,
          ),
        ],
      ),
    ),
  ],
);''';
