import 'package:flutter/material.dart';

class HornbillScaffold extends StatefulWidget {
  final Widget? appBar; // pass a SliverAppBar (or null)
  final List<Widget> slivers; // body content as slivers
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final Widget? sidebar; // optional sidebar widget

  const HornbillScaffold({
    super.key,
    this.appBar,
    required this.slivers,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.sidebar,
  });

  @override
  State<HornbillScaffold> createState() => _HornbillScaffoldState();
}

class _HornbillScaffoldState extends State<HornbillScaffold> {
  bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600; // Adjust the threshold as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      drawer: widget.drawer,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Row(
        children: [
          if (isDesktop(context) && widget.sidebar != null) ?widget.sidebar,
          Expanded(
            child: CustomScrollView(
              slivers: [?widget.appBar, ...widget.slivers],
            ),
          ),
        ],
      ),
    );
  }
}
