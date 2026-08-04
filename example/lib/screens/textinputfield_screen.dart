import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';
import 'package:material_symbols_icons/symbols.dart';

class TextinputfieldScreen extends StatefulWidget {
  const TextinputfieldScreen({super.key});

  @override
  State<TextinputfieldScreen> createState() => _TextinputfieldScreenState();
}

class _TextinputfieldScreenState extends State<TextinputfieldScreen> {
  @override
  Widget build(BuildContext context) {
    return HornbillScaffold(
      appBar: SliverAppBar(title: Text('Text Input Field')),
      slivers: [
        SliverToBoxAdapter(child: MListHeader(title: 'Text Input Field')),
        SliverToBoxAdapter(
          child: HornbillCard(
            margin: EdgeInsets.all(16.0),
            child: Column(
              spacing: 16.0,
              children: [
                HornbillTextField(
                  label: 'Label',
                  hintText: 'Hint Text',
                  onFieldSubmitted: (p0) {},
                ),
                HornbillTextField(
                  label: 'Label with obscure text',
                  hintText: 'This one has obscure text',
                  obscureText: true,
                  onFieldSubmitted: (p0) {},
                ),
                HornbillTextField(
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
