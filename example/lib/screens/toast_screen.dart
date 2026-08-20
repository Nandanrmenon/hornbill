import 'package:flutter_highlight/themes/codepen-embed.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

class ToastScreen extends StatefulWidget {
  const ToastScreen({super.key});

  @override
  State<ToastScreen> createState() => _ToastScreenState();
}

class _ToastScreenState extends State<ToastScreen> {
  bool switchValue = false;
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: 'Toast'),
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
                    spacing: 8.0,
                    children: [
                      HButton.filled(
                        label: 'Success',
                        onPressed: () {
                          HToast.show(
                            context,
                            message: 'This is a toast message!',
                            type: HToastType.success,
                          );
                        },
                      ),
                      HButton.filled(
                        label: 'Info',
                        onPressed: () {
                          HToast.show(
                            context,
                            message: 'This is a toast message!',
                            type: HToastType.info,
                          );
                        },
                      ),
                      HButton.filled(
                        label: 'Warning',
                        onPressed: () {
                          HToast.show(
                            context,
                            message: 'This is a toast message!',
                            type: HToastType.warning,
                          );
                        },
                      ),
                      HButton.filled(
                        label: 'Error',
                        onPressed: () {
                          HToast.show(
                            context,
                            message: 'This is a toast message!',
                            type: HToastType.error,
                          );
                        },
                      ),
                    ],
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
