import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

class CheckboxScreen extends StatefulWidget {
  const CheckboxScreen({super.key});

  @override
  State<CheckboxScreen> createState() => _CheckboxScreenState();
}

class _CheckboxScreenState extends State<CheckboxScreen> {
  bool _checked = false;
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: 'Buttons'),
      slivers: [
        SliverToBoxAdapter(
          child: HListHeader(
            title: 'Show HDialog with title, content, and actions',
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: HCheckBox(
              value: _checked,
              onChanged: (v) => setState(() => _checked = v),
            ),
          ),
        ),
      ],
    );
  }
}
