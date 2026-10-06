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
      appBar: HAppBar(title: Text('Progress Indicator')),
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
                    progressColor: HColors.of(context).tertiary.base,
                  ),
                  HProgressIndicator(
                    backgroundColor: HColors.of(context).primary.base,
                  ),
                  HProgressIndicator(
                    gradient: LinearGradient(
                      colors: [
                        HColors.of(context).primary.base,
                        HColors.of(context).secondary.base,
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
