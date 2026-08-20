import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class TextinputfieldScreen extends StatefulWidget {
  const TextinputfieldScreen({super.key});

  @override
  State<TextinputfieldScreen> createState() => _TextinputfieldScreenState();
}

class _TextinputfieldScreenState extends State<TextinputfieldScreen> {
  @override
  Widget build(BuildContext context) {
    return HScaffold(
      appBar: HAppBar(title: 'Text Input Field'),
      slivers: [
        SliverToBoxAdapter(child: HListHeader(title: 'Text Input Field')),
        SliverToBoxAdapter(
          child: HCard(
            margin: EdgeInsets.all(16.0),
            child: Column(
              spacing: 16.0,
              children: [
                HTextField(
                  label: 'Label',
                  hintText: 'Hint Text',
                  onFieldSubmitted: (p0) {},
                ),
                HTextField(
                  label: 'Label with obscure text',
                  hintText: 'This one has obscure text',
                  obscureText: true,
                  onFieldSubmitted: (p0) {},
                ),
                HTextField(
                  label: 'Label w/ trailing widget',
                  hintText: 'Hint Text',
                  trailingWidget: IconButton(
                    onPressed: () {},
                    icon: Icon(Symbols.date_range),
                  ),
                  onFieldSubmitted: (p0) {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
