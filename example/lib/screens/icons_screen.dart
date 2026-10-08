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
  double _gridExtent = 96.0; // Default grid cell max extent
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
    final isLargeScreen = MediaQuery.sizeOf(context).width >= 600;

    // Build the controls widgets for reusability in Row or Column
    final searchField = HTextField(
      label: 'Search Icons',
      hintText: 'Type to search icons...',
      onChanged: _onSearchChanged,
    );

    final styleSelect = HSelect<SymbolStyle>(
      label: 'Style',
      value: _currentStyle,
      items: const [
        HSelectItem(
          value: SymbolStyle.outlined,
          label: 'Outlined',
        ),
        HSelectItem(
          value: SymbolStyle.rounded,
          label: 'Rounded',
        ),
        HSelectItem(
          value: SymbolStyle.sharp,
          label: 'Sharp',
        ),
      ],
      onChanged: (newStyle) {
        setState(() {
          _currentStyle = newStyle;
        });
      },
    );

    final gridSizeSelect = HSelect<double>(
      label: 'Grid Size',
      value: _gridExtent,
      items: const [
        HSelectItem(
          value: 80.0,
          label: 'Compact',
        ),
        HSelectItem(
          value: 96.0,
          label: 'Default',
        ),
        HSelectItem(
          value: 120.0,
          label: 'Large',
        ),
      ],
      onChanged: (newSize) {
        setState(() {
          _gridExtent = newSize;
        });
      },
    );

    return HScaffold(
      appBar: HAppBar(title: Text('Icons')),
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

                isLargeScreen
                    ? Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: searchField,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: styleSelect,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: gridSizeSelect,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          searchField,
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: styleSelect),
                              const SizedBox(width: 8),
                              Expanded(child: gridSizeSelect),
                            ],
                          ),
                        ],
                      ),
                const SizedBox(height: 8),
                HListTile(
                  dense: true,
                  title: Text(
                    '${_showOnlyFilled ? "Filled" : "Outlined"} ${_filteredEntries.length} symbols',
                  ),
                  subtitle: Text('Toggle to show only filled symbols'),
                  onTap: () {
                    setState(() {
                      _showOnlyFilled = !_showOnlyFilled;
                    });
                  },
                  suffix: HSwitch(
                    value: _showOnlyFilled,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyFilled = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lazy-loading sliver grid via SliverChildBuilderDelegate
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _gridExtent,
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

              // Dynamically scale icon size based on current grid extent
              final double iconSize = switch (_gridExtent) {
                80.0 => 24.0,
                96.0 => 28.0,
                120.0 => 36.0,
                _ => 28.0,
              };

              return HFilledCard(
                padding: const EdgeInsetsGeometry.all(0),
                child: InkWell(
                  onTap: () async {
                    final snippet = 'Symbols.$iconName';

                    // Copy to clipboard
                    await Clipboard.setData(ClipboardData(text: snippet));

                    // Show notification
                    if (context.mounted) {
                      HToast.show(
                        title: 'Copied',
                        context,
                        description: 'Copied "$snippet" to clipboard',
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(iconData, size: iconSize, fill: _showOnlyFilled ? 1 : 0),
                      const SizedBox(height: 12),
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