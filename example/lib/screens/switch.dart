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
      appBar: SliverAppBar.large(title: Text('Switch')),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: HornbillSwitch(
              showCheckIcon: true,
              value: switchValue,
              onChanged: (value) {
                setState(() {
                  switchValue = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
