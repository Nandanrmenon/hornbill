import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

class ProgressIndicatorScreen extends StatefulWidget {
  const ProgressIndicatorScreen({super.key});

  @override
  State<ProgressIndicatorScreen> createState() =>
      _ProgressIndicatorScreenState();
}

class _ProgressIndicatorScreenState extends State<ProgressIndicatorScreen> {
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: 'Progress Indicator'),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 200),
              child: Column(
                spacing: 16.0,
                children: [
                  HProgressIndicator(),
                  HProgressIndicator(
                    progressColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  HProgressIndicator(
                    progressColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  HProgressIndicator(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                    ),
                  ),
                  HProgressIndicator(value: 0.5, showLabel: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
