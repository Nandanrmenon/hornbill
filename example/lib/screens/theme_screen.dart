import 'package:flutter_highlight/themes/codepen-embed.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: 'Hornbill Colour Schemes'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 24.0,
              top: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .start,
              spacing: 8.0,
              children: [
                Text(
                  '`HTheme` accepts an `HColourScheme`, which controls the primary/secondary/tertiary accent colours while keeping surfaces and backgrounds neutral (untinted). You can use a built-in preset, or supply your own colour.',
                ),

                // Using a preset
                SizedBox(height: 8.0),
                Text(
                  'Using a preset',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                CodeBlock(
                  code:
                      'final theme = HTheme(colourScheme: HColourScheme.blue).lightTheme();',
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  language: 'dart',
                  theme: codepenEmbedTheme,
                ),
                Text(
                  'Available presets: `purple` (default), `red`, `orange`, `amber`, `yellow`, `green`, `teal`, `cyan`, `blue`, `indigo`, `pink`, `brown`, `grey`.',
                ),

                // Custom Color
                SizedBox(height: 8.0),
                Text(
                  'Using a custom `Color`',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                CodeBlock(
                  code: '''
final theme = HTheme(
  colourScheme: HColourScheme.custom(const Color(0xFF00FF00)),
).lightTheme();''',
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  language: 'dart',
                  theme: codepenEmbedTheme,
                ),

                // Using a custom hex string
                SizedBox(height: 8.0),
                Text(
                  'Using a custom hex string',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                CodeBlock(
                  code: '''
final theme = HTheme(
  colourScheme: HColourScheme.fromHex('#FF5733'),
).lightTheme();

// The leading '#' is optional, and 8-digit ARGB hex is also supported:
HColourScheme.fromHex('FF5733');
HColourScheme.fromHex('#FFFF5733');''',
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  language: 'dart',
                  theme: codepenEmbedTheme,
                ),

                // Full example
                SizedBox(height: 8.0),
                Text(
                  'Full example',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                CodeBlock(
                  code: '''
import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: HTheme(colourScheme: HColourScheme.blue).lightTheme(),
      darkTheme: HTheme(colourScheme: HColourScheme.blue).darkTheme(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}''',
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  language: 'dart',
                  theme: codepenEmbedTheme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
