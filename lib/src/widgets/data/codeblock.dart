// pubspec.yaml
// dependencies:
//   flutter_highlight: ^0.7.0

import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

/// Where a [CodeBlock]'s source should be read from.
enum _CodeSource { direct, asset, file }

/// Displays a block of code with syntax highlighting, optional line
/// numbers, a language label, and a button to copy the code to the
/// clipboard. Code can be passed directly as a string, loaded from a
/// Flutter asset, or read from a file on disk.
class CodeBlock extends StatefulWidget {
  /// Raw code string. Used when constructed via the default constructor.
  final String? code;

  /// Asset path (declared in pubspec.yaml) to load code from.
  final String? assetPath;

  /// Filesystem path to load code from. Not supported on web.
  final String? filePath;

  final _CodeSource _source;

  /// Language used for syntax highlighting (e.g. 'dart', 'json', 'yaml').
  /// See https://pub.dev/packages/flutter_highlight for supported names.
  final String language;

  /// Highlight.js theme map, e.g. `atomOneDarkTheme`, `githubTheme`.
  /// Import the desired theme from `flutter_highlight/themes/*.dart`.
  final Map<String, TextStyle> theme;

  /// Whether to show line numbers on the left.
  final bool showLineNumbers;

  /// Background color of the code block. Defaults to the theme's
  /// 'root' background color when null.
  final Color? backgroundColor;

  /// Header bar color (holds the language label + copy button).
  final Color headerColor;

  /// Corner radius of the block.
  final double borderRadius;

  /// Font size of the code text.
  final double fontSize;

  /// Optional max height; if set, the code becomes vertically scrollable.
  final double? maxHeight;

  /// Displays [code] directly.
  const CodeBlock({
    super.key,
    required String this.code,
    this.language = 'plaintext',
    this.theme = atomOneDarkTheme,
    this.showLineNumbers = true,
    this.backgroundColor,
    this.headerColor = const Color(0xFF2D2D2D),
    this.borderRadius = 8.0,
    this.fontSize = 14.0,
    this.maxHeight,
  }) : assetPath = null,
       filePath = null,
       _source = _CodeSource.direct;

  /// Loads code from a Flutter asset (must be declared in pubspec.yaml).
  const CodeBlock.asset({
    super.key,
    required String this.assetPath,
    this.language = 'plaintext',
    this.theme = atomOneDarkTheme,
    this.showLineNumbers = true,
    this.backgroundColor,
    this.headerColor = const Color(0xFF2D2D2D),
    this.borderRadius = 8.0,
    this.fontSize = 14.0,
    this.maxHeight,
  }) : code = null,
       filePath = null,
       _source = _CodeSource.asset;

  /// Loads code from a file on disk. Not supported on web (dart:io).
  const CodeBlock.file({
    super.key,
    required String this.filePath,
    this.language = 'plaintext',
    this.theme = atomOneDarkTheme,
    this.showLineNumbers = true,
    this.backgroundColor,
    this.headerColor = const Color(0xFF2D2D2D),
    this.borderRadius = 8.0,
    this.fontSize = 14.0,
    this.maxHeight,
  }) : code = null,
       assetPath = null,
       _source = _CodeSource.file;

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;
  late Future<String> _codeFuture;

  @override
  void initState() {
    super.initState();
    _codeFuture = _loadCode();
  }

  @override
  void didUpdateWidget(covariant CodeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code ||
        oldWidget.assetPath != widget.assetPath ||
        oldWidget.filePath != widget.filePath) {
      _codeFuture = _loadCode();
    }
  }

  Future<String> _loadCode() {
    switch (widget._source) {
      case _CodeSource.direct:
        return Future.value(widget.code ?? '');
      case _CodeSource.asset:
        return rootBundle.loadString(widget.assetPath!);
      case _CodeSource.file:
        if (kIsWeb) {
          return Future.error(
            'CodeBlock.file is not supported on web. Use CodeBlock.asset '
            'or pass the code string directly instead.',
          );
        }
        return File(widget.filePath!).readAsString();
    }
  }

  Future<void> _copyToClipboard(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    setState(() => _copied = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _codeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildShell(
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildShell(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load code: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        final code = snapshot.data ?? '';
        return _buildShell(code: code, child: _buildBody(code));
      },
    );
  }

  Widget _buildShell({required Widget child, String? code}) {
    // final bgColor =
    //     widget.backgroundColor ??
    //     widget.theme['root']?.backgroundColor ??
    //     const Color(0xFF282C34);
    final bgColor =
        widget.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainer;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        color: bgColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildHeader(code), child],
        ),
      ),
    );
  }

  Widget _buildHeader(String? code) {
    final labelColor =
        widget.theme['root']?.color?.withValues(alpha: 0.7) ?? Colors.white70;

    return Container(
      color: widget.headerColor,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            widget.language,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.0,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: code == null ? null : () => _copyToClipboard(code),
            borderRadius: BorderRadius.circular(4.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _copied ? Icons.check : Icons.copy,
                    size: 16.0,
                    color: _copied ? Colors.greenAccent : labelColor,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    _copied ? 'Copied' : 'Copy',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: _copied ? Colors.greenAccent : labelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String code) {
    final lines = code.split('\n');
    // final baseColor = widget.theme['root']?.color ?? const Color(0xFFABB2BF);
    final baseColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final lineNumberStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: widget.fontSize,
      color: baseColor.withValues(alpha: 0.35),
      height: 1.4,
    );
    final content = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLineNumbers)
            // Excluded from selection so only the code gets selected/copied.
            SelectionContainer.disabled(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    lines.length,
                    (i) => Text('${i + 1}', style: lineNumberStyle),
                  ),
                ),
              ),
            ),
          Expanded(
            child: SelectionArea(
              child: HighlightView(
                code,
                language: widget.language,
                theme: widget.theme,
                padding: const EdgeInsets.all(12.0),
                textStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: widget.fontSize,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return widget.maxHeight != null
        ? ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight!),
            child: SingleChildScrollView(child: content),
          )
        : content;
  }
}

/// --- Example usage ---
///
/// // Direct string, with a different theme:
/// CodeBlock(
///   language: 'dart',
///   theme: githubTheme, // import 'package:flutter_highlight/themes/github.dart'
///   code: '''
/// void main() {
///   print('Hello, world!');
/// }
/// ''',
/// )
///
/// // From a bundled asset (declare the path under `assets:` in pubspec.yaml):
/// CodeBlock.asset(
///   assetPath: 'assets/code/example.dart',
///   language: 'dart',
/// )
///
/// // From a file on disk (not supported on web):
/// CodeBlock.file(
///   filePath: '/path/to/example.py',
///   language: 'python',
/// )
