import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool switchValue = false;
  @override
  Widget build(BuildContext context) {
    return HornbillScaffold(
      appBar: SliverAppBar(title: Text('List View')),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                HListHeader(title: 'List View - Normal'),
                Switch(
                  value: switchValue,
                  onChanged: (value) {
                    setState(() {
                      switchValue = value;
                    });
                  },
                ),
                HornbillSwitch(
                  showCheckIcon: true,
                  value: switchValue,
                  onChanged: (value) {
                    setState(() {
                      switchValue = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
