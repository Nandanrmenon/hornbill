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
                  errorText: 'Optional',
                ),
                HTextField(
                  label: 'Label with obscure text',
                  hintText: 'This one has obscure text',
                  obscureText: true,
                  onFieldSubmitted: (p0) {},
                ),
                HTextField(
                  icon: Icon(Symbols.person),
                  label: 'Label w/ trailing widget',
                  hintText: 'Hint Text',
                  trailingWidget: IconButton(
                    onPressed: () {},
                    icon: Icon(Symbols.date_range),
                  ),
                  onFieldSubmitted: (p0) {},
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: HTextField(
                        label: 'Label w/ trailing widget',
                        hintText: 'Hint Text',
                        trailingWidget: IconButton(
                          onPressed: () {},
                          icon: Icon(Symbols.date_range),
                        ),
                        onFieldSubmitted: (p0) {},
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: HDropDownField(
                        // icon: Icon(Symbols.person),
                        label: 'Label',
                        hintText: 'Hint Text',
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            value: 'Option 1',
                            label: 'Option 1',
                          ),
                          DropdownMenuEntry(
                            value: 'Option 2',
                            label: 'Option 2',
                          ),
                          DropdownMenuEntry(
                            value: 'Option 3',
                            label: 'Option 3',
                          ),
                        ],
                        initialSelection: 'Option 1',
                        onSelected: (value) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
