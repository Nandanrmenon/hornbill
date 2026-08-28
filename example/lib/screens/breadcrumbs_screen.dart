import 'package:flutter_code_view/flutter_code_view.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class BreadcrumbsScreen extends StatefulWidget {
  const BreadcrumbsScreen({super.key});

  @override
  State<BreadcrumbsScreen> createState() => _BreadcrumbsScreenState();
}

class _BreadcrumbsScreenState extends State<BreadcrumbsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return HScaffold(
      appBar: HAppBar(title: 'Breadcrumbs'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                HListHeader(title: 'Example'),
                Row(
                  spacing: 16.0,
                  children: [
                    HBreadcrumb(
                      items: [
                        HBreadcrumbItem(
                          icon: Symbols.home,
                          label: 'Home',
                          onTap: () {},
                        ),
                        HBreadcrumbItem(label: 'Page 1', onTap: () {}),
                        HBreadcrumbItem(label: 'Page 3', onTap: () {}),
                        HBreadcrumbItem(label: 'Page 2', onTap: () {}),
                      ],
                    ),
                  ],
                ),
                HListHeader(title: ' Usage'),
                FlutterCodeView(
                  source: sampleButtonCode,
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

String sampleButtonCode = '''
 HBreadcrumb(
   items: [
     HBreadcrumbItem(label: 'Home', onTap: () => go('/')),
     HBreadcrumbItem(label: 'Settings', onTap: () => go('/settings')),
     HBreadcrumbItem(label: 'Profile'), // last = current page
   ],
   maxItems: 4,
)
''';
