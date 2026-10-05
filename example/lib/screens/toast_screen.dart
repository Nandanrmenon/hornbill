import 'package:flutter_highlight/themes/codepen-embed.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

class ToastScreen extends StatelessWidget {
  const ToastScreen({super.key});

  Widget _wrap(List<Widget> children) => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Wrap(spacing: 8.0, runSpacing: 8.0, children: children),
  );

  String _title(String s) => s[0].toUpperCase() + s.substring(1);

  HButtonColor _buttonColor(HToastType t) => switch (t) {
    HToastType.info => HButtonColor.primary,
    HToastType.success => HButtonColor.success,
    HToastType.warning => HButtonColor.warning,
    HToastType.error => HButtonColor.danger,
  };

  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: const Text('Toast')),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Types ----
              HListHeader(
                title: 'Types',
                subtitle:
                    'Top center on large screens, bottom full-width on mobile.',
              ),
              _wrap([
                for (final t in HToastType.values)
                  HButton(
                    variant: HButtonVariant.flat,
                    color: _buttonColor(t),
                    label: Text(_title(t.name)),
                    onPressed: () => HToast.show(
                      context,
                      title: 'This is a toast title!',
                      description: 'And this is the description.',
                      type: t,
                    ),
                  ),
              ]),

              // ---- Position ----
              HListHeader(
                title: 'Position',
                subtitle:
                    'Overrides the adaptive default on every screen size.',
              ),
              _wrap([
                for (final p in HToastPosition.values)
                  HButton(
                    variant: HButtonVariant.light,
                    color: HButtonColor.primary,
                    size: HButtonSize.sm,
                    label: Text(p.name),
                    onPressed: () =>
                        HToast.show(context, title: p.name, position: p),
                  ),
              ]),

              // ---- Actions ----
              HListHeader(title: 'Actions & persistence'),
              _wrap([
                HButton(
                  variant: HButtonVariant.faded,
                  label: const Text('With action'),
                  onPressed: () => HToast.show(
                    context,
                    title: 'Message deleted',
                    actionLabel: 'Undo',
                    onAction: () => HToast.show(
                      context,
                      title: 'Restored',
                      type: HToastType.success,
                    ),
                  ),
                ),
                HButton(
                  variant: HButtonVariant.faded,
                  label: const Text('Persistent'),
                  onPressed: () => HToast.show(
                    context,
                    title: 'Stays until dismissed',
                    description: 'Swipe it away or tap the close button.',
                    type: HToastType.warning,
                    duration: null,
                  ),
                ),
                HButton(
                  variant: HButtonVariant.faded,
                  label: const Text('Loading → done'),
                  onPressed: () async {
                    final handle = HToast.show(
                      context,
                      title: 'Uploading…',
                      duration: null,
                      dismissible: false,
                    );
                    await Future.delayed(const Duration(seconds: 2));
                    handle.dismiss();
                    if (context.mounted) {
                      HToast.show(
                        context,
                        title: 'Upload complete',
                        type: HToastType.success,
                      );
                    }
                  },
                ),
                HButton(
                  variant: HButtonVariant.light,
                  color: HButtonColor.danger,
                  label: const Text('Dismiss all'),
                  onPressed: HToast.dismissAll,
                ),
              ]),

              // ---- Usage ----
              HListHeader(title: 'Usage'),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CodeBlock.asset(
                  assetPath: 'assets/code/toast_example.dart.txt',
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  language: 'dart',
                  theme: codepenEmbedTheme,
                  showLineNumbers: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
