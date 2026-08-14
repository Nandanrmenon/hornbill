import 'package:material_ui/material_ui.dart';
import 'package:flutter_highlight/themes/codepen-embed.dart';
import 'package:hornbill/hornbill.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool switchValue = false;
  @override
  Widget build(BuildContext context) {
    return HornbillScaffold(
      appBar: SliverAppBar.large(title: Text('Switch')),
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
                  child: HornbillSwitch(
                    showCheckIcon: true,
                    value: switchValue,
                    onChanged: (value) {
                      setState(() {
                        switchValue = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                HListHeader(title: 'Usage'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CodeBlock.asset(
                    assetPath: 'assets/code/switch_example.dart.txt',
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer,
                    language: 'dart',
                    theme: codepenEmbedTheme,
                    showLineNumbers: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
