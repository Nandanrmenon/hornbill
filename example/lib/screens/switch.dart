import 'package:flutter_code_view/flutter_code_view.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool switchValue = false;
  bool switchValue2 = true;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return HScaffold(
      appBar: HAppBar(title: 'Switch'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .start,
              children: [
                HListHeader(title: 'Preview'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    spacing: 4.0,
                    children: [
                      HSwitch(
                        showCheckIcon: true,
                        value: switchValue,
                        onChanged: (value) {
                          setState(() {
                            switchValue = value;
                          });
                        },
                      ),
                      HSwitch(
                        value: switchValue2,
                        onChanged: (value) {
                          setState(() {
                            switchValue2 = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                HListHeader(title: 'Usage'),
                FlutterCodeView(
                  source: sampleCode,
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
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: CodeBlock.asset(
                //     assetPath: 'assets/code/switch_example.dart.txt',
                //     backgroundColor: Theme.of(
                //       context,
                //     ).colorScheme.surfaceContainer,
                //     language: 'dart',
                //     theme: codepenEmbedTheme,
                //     showLineNumbers: true,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String sampleCode = '''
return HScaffold(
  appBar: HAppBar(title: 'Switch'),
  slivers: [
    SliverToBoxAdapter(
      child: HSwitch(
        showCheckIcon: true,
        value: switchValue,
        onChanged: (value) {
          setState(() {
            switchValue = value;
          });
        },
      ),
    ),
  ],
);''';
