import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

class DialogScreen extends StatefulWidget {
  const DialogScreen({super.key});

  @override
  State<DialogScreen> createState() => _DialogScreenState();
}

class _DialogScreenState extends State<DialogScreen> {
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: Text('Buttons')),
      slivers: [
        SliverToBoxAdapter(
          child: HListHeader(
            title: 'Show HDialog (auto: bottom on mobile, center on desktop)',
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                HButton.filled(
                  label: Text('Open Me!'),
                  onPressed: () => showHDialog(
                    context,
                    builder: (context) => HDialog(
                      actions: [
                        HButton.tonal(
                          label: Text('Close'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                      child: Text('Hello from HDialog'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: HListHeader(title: 'Show HDialog (custom position)'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              spacing: 4.0,
              children: [
                HButton.tonal(
                  label: Text('Bottom'),
                  onPressed: () => showHDialog(
                    context,
                    builder: (context) => HDialog(
                      position: HDialogPosition.bottom,
                      actions: [
                        HButton.tonal(
                          label: Text('Close'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                      child: Text('Hello from HDialog'),
                    ),
                  ),
                ),
                HButton.tonal(
                  label: Text('Center'),
                  onPressed: () => showHDialog(
                    context,
                    builder: (context) => HDialog(
                      position: HDialogPosition.center,
                      actions: [
                        HButton.tonal(
                          label: Text('Close'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                      child: Text('Hello from HDialog'),
                    ),
                  ),
                ),
                HButton.tonal(
                  label: Text('Top'),
                  onPressed: () => showHDialog(
                    context,
                    builder: (context) => HDialog(
                      position: HDialogPosition.top,
                      actions: [
                        HButton.tonal(
                          label: Text('Close'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                      child: Text('Hello from HDialog'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: HListHeader(
            title: 'Show HDialog with title, content, and actions',
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              spacing: 4.0,
              children: [
                HButton.tonal(
                  label: Text('Open Me!'),
                  onPressed: () => showHDialog(
                    context,
                    builder: (context) => HDialog(
                      actions: [
                        HButton.filled(
                          label: Text('Save'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        HButton.tonal(
                          label: Text('Close'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                      title: Text('Title'),
                      content: [
                        Text(
                          'This is a dialog with title, content, and actions.',
                        ),
                        HTextField(
                          controller: TextEditingController(),
                          label: 'Old Password',
                        ),
                        HTextField(
                          controller: TextEditingController(),
                          label: 'New Password',
                          obscureText: true,
                        ),
                        HTextField(
                          controller: TextEditingController(),
                          label: 'Confirm Password',
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
