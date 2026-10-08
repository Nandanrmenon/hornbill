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
  final scaffoldKey = GlobalKey<HScaffoldState>();
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
        appBar: const HAppBar(title: Text('Hi there!!!')),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
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
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: context.hColors.foreground,
                        ),
                      ),
                      Text(
                        'Explore live examples, inspect the implementation, and find the right building block for your next screen.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.hColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const Column(
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
          items: const [
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

  List<Widget> _buildButtons() {
    return [
      HButton(
        color: .primary,
        onPressed: widget.onExplore,
        icon: Symbols.widgets_rounded,
        label: const Text('Explore components'),
      ),
      HButton(
        variant: .flat,
        color: .primary,
        onPressed: () async {
          if (!await launchUrl(_hornbillPackageUrl)) {
            throw Exception('Could not launch $_hornbillPackageUrl');
          }
        },
        icon: Symbols.download,
        label: const Text('Install from pub.dev'),
      ),
      HButton(
        onPressed: () async {
          if (!await launchUrl(_hornbillCodeUrl)) {
            throw Exception('Could not launch $_hornbillCodeUrl');
          }
        },
        variant: .light,
        color: .primary,
        icon: Symbols.code_rounded,
        label: const Text('View Source Code'),
      ),
    ];
  }

  Widget _buildPhone(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          width: 400,
          height: 850,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            border: Border.all(
              color: context.hColors.border,
              width: 4,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Material(
                color: context.hColors.background,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('12:30', style: TextStyle(fontSize: 14)),
                      Spacer(),
                      Icon(Symbols.wifi, size: 14),
                      Icon(Symbols.battery_3_bar_rounded, size: 14),
                    ],
                  ),
                ),
              ),
              _phoneContent(theme),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 128,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.hColors.foreground,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.sizeOf(context).width >= 960;
    return HScaffold(
      key: scaffoldKey,
      slivers: [
        SliverToBoxAdapter(
          child: Material(
            color: context.hColors.primary.soft,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 48, 48, 32),
                  child: Row(
                    spacing: isLargeScreen ? 24.0 : 8.0,
                    children: [
                      Icon(
                        Symbols.flare,
                        size: 48,
                        color: context.hColors.primary.base,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: .start,
                        children: [
                          Text(
                            'Hornbill UI',
                            style: TextStyle(
                              fontFamily:
                                  GoogleFonts.googleSansFlex().fontFamily,
                              color: context.hColors.primary.onSoft,
                              fontSize: isLargeScreen ? 64 : 48,
                              fontVariations: const [
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
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: context.hColors.primary.onSoft,
                              fontSize: isLargeScreen ? 24 : 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Material(
            color: context.hColors.backgroundSubtle,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48.0,
                    vertical: 32.0,
                  ),
                  child: isLargeScreen
                      ? Row(
                          spacing: 24.0,
                          children: [
                            _buildPhone(theme),
                            Expanded(
                              // <-- Wrap this Column in Expanded so it gets bounded horizontal space
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 24.0,
                                children: [
                                  Column(
                                    spacing: 8.0,
                                    children: [
                                      // Removed `Flexible` here since the parent Column is now bounded
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
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: _buildButtons(),
                                  ),
                                  Divider(
                                    color: context.hColors.border,
                                    thickness: 1,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 24,
                                    children: [
                                      Column(
                                        spacing: 4.0,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Get started',
                                            style:
                                                theme.textTheme.headlineSmall,
                                          ),
                                          Text(
                                            'Hornbill UI is available on pub.dev. Add it to your project and start building.',
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                        ],
                                      ),
                                      FlutterCodeView(
                                        source: installCode,
                                        themeType: isDark
                                            ? ThemeType.vs2015
                                            : ThemeType.githubGist,
                                        language: Languages.bash,
                                        autoDetection: true,
                                        borderColor: Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                        paddingBorder: const EdgeInsets.all(1),
                                        borderRadiusCodeView:
                                            BorderRadius.circular(8),
                                        borderRadius: BorderRadius.circular(8),
                                        showLineNumbers: false,
                                        width: double.infinity,
                                        fontSize: 16,
                                        selectionColor: Theme.of(context)
                                            .colorScheme
                                            .tertiary
                                            .withOpacity(0.3), // Fixed
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Fixed
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
                            _buildPhone(theme),
                            Column(
                              spacing: 8.0,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _buildButtons(),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
        if (!isLargeScreen)
          SliverToBoxAdapter(
            child: Material(
              color: context.hColors.backgroundMuted,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(48, 32, 48, 72),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24,
                      children: [
                        Column(
                          spacing: 4.0,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Get started',
                              style: theme.textTheme.headlineSmall,
                            ),
                            Text(
                              'Hornbill UI is available on pub.dev. Add it to your project and start building.',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        FlutterCodeView(
                          source: installCode,
                          themeType: isDark
                              ? ThemeType.vs2015
                              : ThemeType.githubGist,
                          language: Languages.bash,
                          autoDetection: true,
                          borderColor: Theme.of(
                            context,
                          ).colorScheme.outlineVariant,
                          paddingBorder: const EdgeInsets.all(1),
                          borderRadiusCodeView: BorderRadius.circular(8),
                          borderRadius: BorderRadius.circular(8),
                          showLineNumbers: false,
                          width: double.infinity,
                          fontSize: 16,
                          selectionColor: Theme.of(
                            context,
                          ).colorScheme.tertiary.withOpacity(0.3), // Fixed
                        ),
                      ],
                    ),
                  ),
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
    return HFilledCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          HAvatar(
            backgroundColor: context.hColors.neutral[300],
            foregroundColor: context.hColors.neutral[900],
            child: Icon(icon, fill: 1),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.hColors.foreground,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.hColors.mutedForeground,
                  ),
                ),
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
