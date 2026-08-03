import 'package:flutter/material.dart';

class HornbillScaffold extends StatelessWidget {
  final Widget? appBar; // pass a SliverAppBar (or null)
  final List<Widget> slivers; // body content as slivers
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;

  const HornbillScaffold({
    super.key,
    this.appBar,
    required this.slivers,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: CustomScrollView(slivers: [?appBar, ...slivers]),
    );
  }
}
