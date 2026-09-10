import 'package:flutter_code_view/flutter_code_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key, required this.onExplore});

  final VoidCallback onExplore;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final Uri _hornbillPackageUrl = Uri.parse(
    'https://pub.dev/packages/hornbill',
  );
  final Uri _hornbillCodeUrl = Uri.parse(
    'https://gitlab.knoxxbox.in/knoxxbox/hornbill',
  );

  int _selectedIndex = 0;

  Widget _phoneContent(ThemeData theme) {
    return Expanded(
      child: HScaffold(
        appBar: HAppBar(title: Text('Hi there!!!')),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 24.0,
                children: [
                  Column(
                    spacing: 8.0,
                    children: [
                      Text(
                        'A practical Flutter component library for expressive, accessible interfaces.',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        'Explore live examples, inspect the implementation, and find the right building block for your next screen.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Column(
                    spacing: 8.0,
                    children: [
                      _Feature(
                        icon: Symbols.palette_rounded,
                        title: 'Themeable',
                        description:
                            'Colour schemes that adapt across the whole app.',
                      ),
                      _Feature(
                        icon: Symbols.devices,
                        title: 'Responsive',
                        description:
                            'Layouts designed for touch and larger screens.',
                      ),
                      _Feature(
                        icon: Symbols.code_rounded,
                        title: 'Ready to use',
                        description:
                            'Focused examples with copyable Flutter code.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        bottomNavigationBar: HNavigationBar(
          items: [
            HNavigationBarItem(icon: Symbols.home_rounded, label: 'Home'),
            HNavigationBarItem(icon: Symbols.search_rounded, label: 'Search'),
            HNavigationBarItem(
              icon: Symbols.person_rounded,
              selectedIcon: Symbols.person_search,
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return HScaffold(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 48, 48, 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  Icon(Symbols.flare, size: 48, color: colours.primary),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4.0,
                    children: [
                      Text(
                        'Hornbill UI',
                        style: TextStyle(
                          fontFamily: GoogleFonts.googleSansFlex().fontFamily,
                          fontSize: 64,
                          fontVariations: [
                            FontVariation('ital', 0),
                            FontVariation('slnt', 0),
                            FontVariation('wdth', 100),
                            FontVariation('wght', 900),
                            FontVariation('GRAD', 0),
                            FontVariation('ROND', 100),
                          ],
                        ),
                      ),
                      Text(
                        'Flutter component library for expressive, accessible interfaces for both mobile and desktop.',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Material(
            color: colours.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 48.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: .start,
                spacing: 24.0,
                children: [
                  Column(
                    spacing: 8.0,
                    children: [
                      Text(
                        'A practical Flutter component library for expressive, accessible interfaces.',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        'Explore live examples, inspect the implementation, and find the right building block for your next screen.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8.0,
                    children: [
                      HButton.filled(
                        showIcon: true,
                        iconPosition: HButtonIconPosition.right,
                        onPressed: widget.onExplore,
                        icon: Symbols.arrow_forward_rounded,
                        label: Text('Explore components'),
                      ),
                      HButton.tonal(
                        showIcon: true,
                        iconPosition: HButtonIconPosition.right,
                        onPressed: () async {
                          if (!await launchUrl(_hornbillPackageUrl)) {
                            throw Exception(
                              'Could not launch $_hornbillPackageUrl',
                            );
                          }
                        },
                        icon: Symbols.download,
                        label: Text('Install from pub.dev'),
                      ),
                      HButton.outlined(
                        showIcon: true,
                        iconPosition: HButtonIconPosition.right,
                        onPressed: () async {
                          if (!await launchUrl(_hornbillCodeUrl)) {
                            throw Exception(
                              'Could not launch $_hornbillCodeUrl',
                            );
                          }
                        },
                        icon: Symbols.code_rounded,
                        label: Text('View Source Code'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Container(
                        width: 450,
                        height: 850,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colours.outlineVariant,
                            width: 4,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Material(
                              color: colours.surfaceContainerLow,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '12:30',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Spacer(),
                                    Icon(Symbols.wifi, size: 14),
                                    Icon(
                                      Symbols.battery_3_bar_rounded,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _phoneContent(theme),
                            Container(
                              color: colours.surfaceContainerLow,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(Symbols.arrow_back_2_rounded, fill: 1),
                                    Icon(Symbols.circle, size: 16, fill: 1),
                                    Icon(
                                      Symbols.square_rounded,
                                      size: 16,
                                      fill: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 32, 48, 72),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  Column(
                    spacing: 4.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Get started', style: theme.textTheme.headlineSmall),
                      Text(
                        'Hornbill UI is available on pub.dev. Add it to your project and start building.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  FlutterCodeView(
                    source: installCode,
                    themeType: isDark ? ThemeType.vs2015 : ThemeType.githubGist,
                    language: Languages.bash,
                    autoDetection: true,
                    borderColor: Theme.of(context).colorScheme.outlineVariant,
                    paddingBorder: EdgeInsets.all(1),
                    borderRadiusCodeView: BorderRadius.circular(8),
                    borderRadius: BorderRadius.circular(8),
                    showLineNumbers: false,
                    width: double.infinity,
                    fontSize: 16,
                    selectionColor: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.colorScheme;
    return HCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Material(
            color: colours.primaryContainer,
            borderRadius: BorderRadius.circular(99),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String installCode = '''
\$ flutter pub add hornbill''';
