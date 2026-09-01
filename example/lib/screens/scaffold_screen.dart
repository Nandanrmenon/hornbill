import 'package:flutter_code_view/flutter_code_view.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class ScaffoldScreen extends StatefulWidget {
  const ScaffoldScreen({super.key});

  @override
  State<ScaffoldScreen> createState() => _ScaffoldScreenState();
}

class _ScaffoldScreenState extends State<ScaffoldScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return HScaffold(
      appBar: HAppBar(
        title: 'Scaffold',
        searchEnabled: true,
        onSearchChanged: (value) {
          // Handle search query changes here
        },
        showBackButton: true,
        onBackPressed: () =>
            HToast.show(context, message: 'Back button pressed'),
        actions: [
          HAppBarAction(label: 'Action 1', icon: Symbols.abc, onPressed: () {}),
        ],
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .start,
              children: [
                Text(
                  'HScaffold is a widget that provides a basic structure for your app\'s UI. It includes an app bar, a body, and a bottom navigation bar. You can use it to create a consistent layout across your app.',
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
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
  appBar: HAppBar(title: 'Title'),
  slivers: [
    /// Sliver Widgets go here. For example, a [SliverList] or [SliverGrid].
  ],
  bottomNavigationBar: HNavigationBar(
    currentIndex: _index,
    onTap: (i) => setState(() => _index = i),
    items: const [
      HNavigationBarItem(
        icon: Symbols.home,
        selectedIcon: Symbols.home,
        label: 'Home',
      ),
      HNavigationBarItem(icon: Symbols.search, label: 'Search'),
      HNavigationBarItem(
        icon: Symbols.favorite_border,
        selectedIcon: Symbols.favorite,
        label: 'Favorites',
      ),
      HNavigationBarItem(
        icon: Symbols.person_outline,
        selectedIcon: Symbols.person,
        label: 'Profile',
      ),
    ],
  ),
);''';
