import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class HornbillPageNavigation extends StatefulWidget {
  final int pageNr;
  final int totalPages;
  final int totalRecords;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onPageSelected;
  final Widget? leading;
  final Widget? trailing;

  /// How many pages to show as a solid run at the very start/end.
  final int boundaryCount;

  /// How many pages to show on each side of the current page
  /// when it's away from the edges.
  final int siblingCount;

  const HornbillPageNavigation({
    super.key,
    required this.pageNr,
    required this.totalPages,
    required this.totalRecords,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSelected,
    this.leading,
    this.trailing,
    this.boundaryCount = 3,
    this.siblingCount = 2,
  });

  @override
  State<HornbillPageNavigation> createState() => _HornbillPageNavigationState();
}

class _HornbillPageNavigationState extends State<HornbillPageNavigation> {
  Widget _buildPageButton(int pageIndex) {
    final isSelected = pageIndex == widget.pageNr;
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => widget.onPageSelected(pageIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 24.0 : 16.0,
            vertical: 8.0,
          ),
          child: Text('${pageIndex + 1}'),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Text('...'),
    );
  }

  /// Returns the list of page indices to render.
  /// `null` entries mean "render an ellipsis here".
  List<int?> _buildVisiblePages() {
    final totalPages = widget.totalPages;
    final lastIndex = totalPages - 1;
    final current = widget.pageNr;
    final boundaryCount = widget.boundaryCount;
    final siblingCount = widget.siblingCount;

    final pages = <int>{0, lastIndex};

    // Near the front: pull in a full run of `boundaryCount` pages at the start.
    if (current < boundaryCount + siblingCount) {
      for (var i = 0; i < boundaryCount && i <= lastIndex; i++) {
        pages.add(i);
      }
    }

    // Near the end: same thing, mirrored, at the tail.
    if (current > lastIndex - boundaryCount - siblingCount + 1) {
      for (var i = 0; i < boundaryCount && lastIndex - i >= 0; i++) {
        pages.add(lastIndex - i);
      }
    }

    // Always keep siblingCount pages on each side of the current page.
    for (var i = current - siblingCount; i <= current + siblingCount; i++) {
      if (i >= 0 && i <= lastIndex) pages.add(i);
    }

    final sorted = pages.toList()..sort();

    final result = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0) {
        final gap = sorted[i] - sorted[i - 1];
        if (gap == 2) {
          // Exactly one page is being skipped — just show it instead of "...".
          result.add(sorted[i] - 1);
        } else if (gap > 2) {
          result.add(null); // ellipsis
        }
      }
      result.add(sorted[i]);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalPages <= 0) {
      return const SizedBox.shrink();
    }

    final visiblePages = _buildVisiblePages();

    final pageButtons = Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: (widget.pageNr > 0)
              ? () => widget.onPageSelected(0)
              : null,
          icon: const Icon(Symbols.first_page),
        ),
        IconButton.filled(
          onPressed: (widget.pageNr > 0) ? widget.onPrevious : null,
          icon: const Icon(Symbols.chevron_left),
        ),
        Row(
          spacing: 2.0,
          children: [
            for (final pageIndex in visiblePages)
              pageIndex == null
                  ? _buildEllipsis()
                  : _buildPageButton(pageIndex),
          ],
        ),
        IconButton.filled(
          onPressed: (widget.pageNr + 1 < widget.totalPages)
              ? widget.onNext
              : null,
          icon: const Icon(Symbols.chevron_right),
        ),
        IconButton.filledTonal(
          onPressed: (widget.pageNr < widget.totalPages - 1)
              ? () => widget.onPageSelected(widget.totalPages - 1)
              : null,
          icon: const Icon(Symbols.last_page),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leading != null) widget.leading!,
          if (widget.leading != null) const Spacer(),
          pageButtons,
          if (widget.trailing != null) const Spacer(),
          if (widget.trailing != null) widget.trailing!,
        ],
      ),
    );
  }
}
