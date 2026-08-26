import 'package:flutter_highlight/themes/codepen-embed.dart';
import 'package:hornbill/hornbill.dart';
import 'package:hornbill_example/theme_controller.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key, required this.themeController});

  /// The app-wide controller this screen reads/writes to drive the live
  /// colour-scheme picker below. See [HThemeController].
  final HThemeController themeController;

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
              bottom: 8.0,
              top: 8.0,
            ),
            child: Column(
              spacing: 16.0,
              children: [
                HListHeader(
                  title: 'Try it out',
                  subtitle: 'Tap a swatch to re-theme this whole app, live.',
                ),
                _ColourSchemePicker(controller: widget.themeController),
                _ExampleWidgets(),
              ],
            ),
          ),
        ),
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

                // Changing the scheme at runtime
                SizedBox(height: 8.0),
                Text(
                  'Changing the scheme at runtime',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '`HTheme` and `HColourScheme` are plain, immutable value objects - there\'s no hidden global state to mutate. To re-theme live (like the picker above does), keep the current `HColourScheme` in some state you own (a `ChangeNotifier`, `ValueNotifier`, `setState`, your state-management solution of choice, etc.), and construct a fresh `HTheme` from it whenever `MaterialApp` rebuilds.',
                ),
                CodeBlock(
                  code: '''
// Anything that can hold a value and notify listeners works. This
// example uses a plain ChangeNotifier.
class ThemeController extends ChangeNotifier {
  HColourScheme colourScheme = HColourScheme.purple;

  void setColourScheme(HColourScheme scheme) {
    colourScheme = scheme;
    notifyListeners();
  }
}

// Rebuild MaterialApp's theme whenever the controller changes.
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => MaterialApp(
        theme: HTheme(colourScheme: controller.colourScheme).lightTheme(),
        darkTheme: HTheme(colourScheme: controller.colourScheme).darkTheme(),
        home: const HomePage(),
      ),
    );
  }
}''',
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  language: 'dart',
                  theme: codepenEmbedTheme,
                  showLineNumbers: true,
                ),
                Text(
                  'This is exactly how the swatch picker above is wired up - see `theme_controller.dart` and `main.dart` in this example app for the full, working version.',
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

/// A row of tappable colour swatches, one per [HColourScheme] preset.
/// Tapping one updates [controller], which re-themes the whole app.
class _ColourSchemePicker extends StatelessWidget {
  const _ColourSchemePicker({required this.controller});

  final HThemeController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              for (final option in kHColourSchemeOptions)
                _ColourSwatch(
                  option: option,
                  selected: option.scheme == controller.colourScheme,
                  onTap: () => controller.setColourScheme(option.scheme),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ExampleWidgets extends StatefulWidget {
  const _ExampleWidgets({super.key});

  @override
  State<_ExampleWidgets> createState() => _ExampleWidgetsState();
}

class _ExampleWidgetsState extends State<_ExampleWidgets> {
  bool switchValue = false;
  @override
  Widget build(BuildContext context) {
    return HCard(
      child: Column(
        crossAxisAlignment: .start,
        spacing: 16.0,
        children: [
          Text(
            'This is a card. It uses the current colour scheme\'s surface color.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Row(
            spacing: 8.0,
            children: [
              HButton.filled(onPressed: () {}, label: 'Button'),
              HButton.outlined(onPressed: () {}, label: 'Button'),
              HButton.tonal(onPressed: () {}, label: 'Button'),
              HButton.text(onPressed: () {}, label: 'Button'),
              HIconButton.filled(onPressed: () {}, icon: Symbols.favorite),
              HIconButton.outlined(onPressed: () {}, icon: Symbols.favorite),
              HIconButton.tonal(onPressed: () {}, icon: Symbols.favorite),
              HIconButton.text(onPressed: () {}, icon: Symbols.favorite),
            ],
          ),
          HTextField(label: 'Text field'),
          Row(
            spacing: 4.0,
            children: [
              HSwitch(
                value: switchValue,
                onChanged: (value) {
                  setState(() {
                    switchValue = value;
                  });
                },
              ),
              Flexible(child: HProgressIndicator(value: 0.9)),
            ],
          ),
          Row(
            spacing: 4.0,
            children: [
              HChip(label: 'Chip', type: ChipType.primary),
              HChip(label: 'Chip', type: ChipType.primaryContainer),
              HChip(label: 'Chip', type: ChipType.secondary),
              HChip(label: 'Chip', type: ChipType.surfaceContainerHighest),
              HChip(label: 'Chip', type: ChipType.tertiary),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColourSwatch extends StatelessWidget {
  const _ColourSwatch({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final HColourSchemeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return Tooltip(
      message: option.label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: selected ? 60 : 40,
          height: 40,
          decoration: BoxDecoration(
            color: option.scheme.seedColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? option.scheme.seedColor : outline,
              width: selected ? 2 : 1,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          alignment: Alignment.center,
          child: selected
              ? Icon(Symbols.check_rounded, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}
