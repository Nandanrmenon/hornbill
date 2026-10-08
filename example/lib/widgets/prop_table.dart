import 'package:flutter/material.dart';
import 'package:hornbill/hornbill.dart';

class PropTable extends StatelessWidget {
  const PropTable({super.key, required this.colors, required this.rows});

  final HColors colors;

  /// (name, type, description)
  final List<(String, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    const mono = 'monospace';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: i == 0
                  ? null
                  : Border(top: BorderSide(color: colors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SelectableText(
                      rows[i].$1,
                      style: TextStyle(
                        fontFamily: mono,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                    ),
                    if (rows[i].$2.isNotEmpty)
                      SelectableText(
                        rows[i].$2,
                        style: TextStyle(
                          fontFamily: mono,
                          fontSize: 12,
                          color: colors.primary.base,
                        ),
                      ),
                  ],
                ),
                SelectableText(
                  rows[i].$3,
                  style: TextStyle(fontSize: 13, color: colors.mutedForeground),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
