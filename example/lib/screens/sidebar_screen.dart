import 'package:flutter_code_view/flutter_code_view.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class SidebarScreen extends StatefulWidget {
  const SidebarScreen({super.key});

  @override
  State<SidebarScreen> createState() => _SidebarScreenState();
}

class _SidebarScreenState extends State<SidebarScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return HScaffold(
      appBar: HAppBar(title: 'Sidebar'),
      slivers: [
        SliverFillRemaining(
          child: HCard(
            margin: EdgeInsetsGeometry.all(16),
            padding: const EdgeInsets.all(0),
            child: Row(
              crossAxisAlignment: .start,
              spacing: 16.0,
              children: [
                HSideBar(
                  items: [
                    HSideBarItem(
                      icon: Symbols.home,
                      label: 'Home',
                      onTap: () {},
                    ),
                    HSideBarItem(
                      icon: Symbols.folder,
                      label: 'Folder',
                      onTap: () {},
                      initiallyExpanded: true,
                      children: [
                        HSideBarItem(
                          icon: Symbols.list,
                          label: 'Item 1',
                          onTap: () {},
                        ),
                        HSideBarItem(
                          icon: Symbols.list,
                          label: 'Item 2',
                          onTap: () {},
                        ),
                      ],
                    ),
                    HSideBarItem(
                      icon: Symbols.folder,
                      label: 'Folder',
                      onTap: () {},
                      children: [
                        HSideBarItem(
                          icon: Symbols.list,
                          label: 'Item 1',
                          onTap: () {},
                        ),
                        HSideBarItem(
                          icon: Symbols.list,
                          label: 'Item 2',
                          onTap: () {},
                        ),
                      ],
                    ),
                    HSideBarItem(
                      icon: Symbols.settings,
                      label: 'Settings',
                      onTap: () {},
                    ),
                    HSideBarItem(
                      icon: Symbols.info,
                      label: 'About',
                      onTap: () {},
                    ),
                  ],
                  footer: HSideBarAccountTile(
                    title: 'John Doe',
                    subtitle: 'john.doe@example.com',
                    onLogout: () {},
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        HListHeader(title: 'Usage'),
                        FlutterCodeView(
                          source: sampleCode,
                          themeType: isDark
                              ? ThemeType.vs2015
                              : ThemeType.githubGist,
                          language: Languages.dart,
                          autoDetection: true,
                          borderColor: Theme.of(
                            context,
                          ).colorScheme.outlineVariant,
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
                SizedBox(width: 8.0),
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
  slivers: [],
  sidebar: HSideBar(
    items: [
      HSideBarItem(icon: Symbols.home, label: 'Home', onTap: () {}),
      HSideBarItem(
        icon: Symbols.folder,
        label: 'Folder',
        onTap: () {},
        initiallyExpanded: true,
        children: [
          HSideBarItem(icon: Symbols.list, label: 'Item 1', onTap: () {}),
          HSideBarItem(icon: Symbols.list, label: 'Item 2', onTap: () {}),
        ],
      ),
      HSideBarItem(
        icon: Symbols.folder,
        label: 'Folder',
        onTap: () {},
        children: [
          HSideBarItem(icon: Symbols.list, label: 'Item 1', onTap: () {}),
          HSideBarItem(icon: Symbols.list, label: 'Item 2', onTap: () {}),
        ],
      ),
      HSideBarItem(icon: Symbols.settings, label: 'Settings', onTap: () {}),
      HSideBarItem(icon: Symbols.info, label: 'About', onTap: () {}),
    ],
    footer: HSideBarAccountTile(
      title: 'John Doe',
      subtitle: 'john.doe@example.com',
      onLogout: () {},
    ),
  ),
);''';
