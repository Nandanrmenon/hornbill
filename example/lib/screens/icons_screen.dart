import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/get.dart'; // Required for dynamic map access
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class IconsScreen extends StatefulWidget {
  const IconsScreen({super.key});

  @override
  State<IconsScreen> createState() => _IconsScreenState();
}

class _IconsScreenState extends State<IconsScreen> {
  String _searchQuery = '';
  SymbolStyle _currentStyle = SymbolStyle.outlined;
  Timer? _debounce;
  bool _showOnlyFilled = false;

  // Cached list to prevent filtering the massive map on every single keystroke
  late List<MapEntry<String, dynamic>> _filteredEntries;

  @override
  void initState() {
    super.initState();
    _filteredEntries = SymbolsGet.map.entries.toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Debounced search to prevent heavy UI lag while typing fast
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query.trim().toLowerCase();
        _filteredEntries = SymbolsGet.map.entries.where((entry) {
          return entry.key.contains(_searchQuery);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyTextStyle = Theme.of(context).textTheme.bodyMedium!;
    final colorScheme = Theme.of(context).colorScheme;

    return HScaffold(
      appBar: HAppBar(title: 'Icons'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        style: bodyTextStyle,
                        text: 'Hornbill strictly uses ',
                      ),
                      TextSpan(
                        style: bodyTextStyle.copyWith(
                          color: colorScheme.primary,
                        ),
                        text: 'Material Symbols',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final Uri url = Uri.parse(
                              'https://fonts.google.com/icons',
                            );
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                      ),
                      TextSpan(
                        style: bodyTextStyle,
                        text: ' for icons. We use ',
                      ),
                      TextSpan(
                        style: bodyTextStyle.copyWith(
                          color: colorScheme.primary,
                        ),
                        text: 'material_symbols_icons',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final Uri url = Uri.parse(
                              'https://pub.dev/packages/material_symbols_icons',
                            );
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                      ),
                      TextSpan(
                        style: bodyTextStyle,
                        text:
                            ' package which available on pub.dev. However you can use any icon you want, as long as it is a Flutter [IconData] object. Alternative to Material Symbols, you can use ',
                      ),
                      TextSpan(
                        style: bodyTextStyle.copyWith(
                          color: colorScheme.primary,
                        ),
                        text: 'Material Icons',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final Uri url = Uri.parse(
                              'https://fonts.google.com/icons?icon.set=Material%20Icons',
                            );
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Controls Bar: Search Field & Style Selector
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: HTextField(
                        label: 'Search Icons',
                        hintText: 'Type to search icons...',
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8,
                      children: [
                        const Text('Filled'),
                        HSwitch(
                          value: _showOnlyFilled,
                          onChanged: (value) {
                            setState(() {
                              _showOnlyFilled = value;
                            });
                          },
                        ),
                        DropdownButton<SymbolStyle>(
                          value: _currentStyle,
                          items: const [
                            DropdownMenuItem(
                              value: SymbolStyle.outlined,
                              child: Text('Outlined'),
                            ),
                            DropdownMenuItem(
                              value: SymbolStyle.rounded,
                              child: Text('Rounded'),
                            ),
                            DropdownMenuItem(
                              value: SymbolStyle.sharp,
                              child: Text('Sharp'),
                            ),
                          ],
                          onChanged: (newStyle) {
                            if (newStyle != null) {
                              setState(() {
                                _currentStyle = newStyle;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                HListHeader(
                  title: 'Showing ${_filteredEntries.length} symbols',
                ),
              ],
            ),
          ),
        ),

        // Lazy-loading sliver grid via SliverChildBuilderDelegate
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 96,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final entry = _filteredEntries[index];
              final iconName = entry.key;

              // Fetch style-variant lazily per item rendering block
              IconData? iconData;
              if (_currentStyle == SymbolStyle.rounded) {
                iconData = SymbolsGet.get(iconName, SymbolStyle.rounded);
              } else if (_currentStyle == SymbolStyle.sharp) {
                iconData = SymbolsGet.get(iconName, SymbolStyle.sharp);
              } else {
                iconData = SymbolsGet.get(iconName, SymbolStyle.outlined);
              }

              return HCard(
                padding: const EdgeInsetsGeometry.all(0),
                child: InkWell(
                  onTap: () async {
                    final snippet = 'Symbols.$iconName';

                    // Copy to clipboard
                    await Clipboard.setData(ClipboardData(text: snippet));

                    // Show notification
                    if (context.mounted) {
                      HToast.show(
                        context,
                        message: 'Copied "$snippet" to clipboard',
                        type: HToastType.info,
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(iconData, size: 28, fill: _showOnlyFilled ? 1 : 0),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          iconName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: _filteredEntries.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
