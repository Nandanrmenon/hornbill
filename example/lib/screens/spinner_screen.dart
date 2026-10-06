import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

class SpinnerScreen extends StatefulWidget {
  const SpinnerScreen({super.key});

  @override
  State<SpinnerScreen> createState() => _SpinnerScreenState();
}

class _SpinnerScreenState extends State<SpinnerScreen> {
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: Text('Spinner')),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 200),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 16.0,
                  children: [
                    HSpinner(),
                    HSpinner(color: HColors.of(context).tertiary.base),
                    HSpinner(strokeWidth: 4.0),
                    HSpinner(
                      color: HColors.of(context).primary.base,
                      strokeWidth: 1.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
