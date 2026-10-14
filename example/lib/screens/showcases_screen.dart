import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class ShowcasesScreen extends StatelessWidget {
  const ShowcasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.sizeOf(context).width >= 960;
    return HScaffold(
      appBar: HAppBar(
        title: Text('Showcases'),
        actions: [
          HButton(
            variant: .light,
            color: .primary,
            icon: Symbols.home_rounded,
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            label: isLargeScreen ? Text('Home') : null,
          ),
          SizedBox(width: 4),
          HButton(
            variant: .light,
            color: .primary,
            icon: Symbols.widgets_rounded,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/components/themes'),
            label: isLargeScreen ? Text('Components') : null,
          ),
          SizedBox(width: 4),
          HButton(
            variant: .flat,
            color: .primary,
            icon: Symbols.gallery_thumbnail,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/showcases'),
            label: isLargeScreen ? Text('Showcases') : null,
          ),
          SizedBox(width: 8),
        ],
      ),
      // sidebar: HSideBar(
      //   collapsible: false,
      //   header: const Padding(
      //     padding: EdgeInsets.all(16),
      //     child: Text('Hornbill UI'),
      //   ),
      //   items: [
      //     HSideBarItem(
      //       icon: Symbols.home_rounded,
      //       label: 'Home',
      //       onTap: () => Navigator.pushReplacementNamed(context, '/'),
      //     ),
      //     HSideBarItem(
      //       label: 'Components',
      //       icon: Symbols.widgets_rounded,
      //       onTap: () =>
      //           Navigator.pushReplacementNamed(context, '/components/themes'),
      //     ),
      //     HSideBarItem(
      //       label: 'Showcases',
      //       icon: Symbols.party_mode,
      //       selected: true,
      //       onTap: () => Navigator.pushReplacementNamed(context, '/showcases'),
      //     ),
      //   ],
      // ),
      slivers: [
        SliverToBoxAdapter(
          child: Material(
            borderRadius: .only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: context.hColors.tertiary.soft,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 64, 48, 64),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(
                        Symbols.gallery_thumbnail,
                        size: 256,
                        color: context.hColors.tertiary.onSoft,
                      ),
                      Text(
                        'Build complete experiences with Hornbill',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'These small demo apps combine Hornbill components into realistic screens.',
                        style: TextStyle(
                          color: context.hColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900),
              child: GridView(
                padding: .symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 440,
                  mainAxisExtent: 220,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                children: [
                  _ShowcaseCard(
                    icon: Symbols.dashboard_rounded,
                    title: 'Analytics dashboard',
                    description:
                        'A responsive dashboard with metrics, activity, and quick actions.',
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      '/showcases/dashboard',
                    ),
                  ),
                  _ShowcaseCard(
                    icon: Symbols.manage_accounts_rounded,
                    title: 'Account settings',
                    description:
                        'A profile and preferences screen using forms, cards, and navigation.',
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      '/showcases/settings',
                    ),
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

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HFilledCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Icon(icon, size: 32, color: context.hColors.primary.base),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Expanded(
            child: Text(
              description,
              style: TextStyle(color: context.hColors.mutedForeground),
            ),
          ),
          Row(
            children: [
              Text(
                'Open showcase',
                style: TextStyle(
                  color: context.hColors.primary.base,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Symbols.arrow_forward_rounded,
                size: 18,
                color: context.hColors.primary.base,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
