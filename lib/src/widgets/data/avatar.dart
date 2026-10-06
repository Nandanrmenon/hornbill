import 'package:flutter/widgets.dart';
import 'package:hornbill/hornbill.dart';

enum HAvatarSize { sm, md, lg }

enum HAvatarRadius { circle, rounded }

class HAvatar extends StatelessWidget {
  const HAvatar({
    super.key,
    this.image,
    this.name,
    this.child,
    this.size = HAvatarSize.md,
    this.radius = HAvatarRadius.circle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.status,
    this.statusColor,
    this.statusBorderColor,
    this.statusBorderWidth = 2,
  });

  final ImageProvider? image;

  /// Used to generate initials when no image is available.
  final String? name;

  /// Custom fallback widget.
  final Widget? child;

  final HAvatarSize size;
  final HAvatarRadius radius;

  final Color? backgroundColor;
  final Color? foregroundColor;

  final Color? borderColor;
  final double borderWidth;

  /// Displays a small status indicator.
  final bool? status;
  final Color? statusColor;
  final Color? statusBorderColor;
  final double statusBorderWidth;

  double get _size {
    switch (size) {
      case HAvatarSize.sm:
        return 32;
      case HAvatarSize.md:
        return 40;
      case HAvatarSize.lg:
        return 48;
    }
  }

  double get _fontSize {
    switch (size) {
      case HAvatarSize.sm:
        return 12;
      case HAvatarSize.md:
        return 14;
      case HAvatarSize.lg:
        return 16;
    }
  }

  double get _radius {
    if (radius == HAvatarRadius.circle) {
      return _size / 2;
    }

    switch (size) {
      case HAvatarSize.sm:
        return 8;
      case HAvatarSize.md:
        return 10;
      case HAvatarSize.lg:
        return 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hbColors = HColors.of(context);
    final avatar = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: backgroundColor ?? hbColors.tertiary.soft,
        shape: radius == HAvatarRadius.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: radius == HAvatarRadius.rounded
            ? BorderRadius.circular(_radius)
            : null,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? hbColors.border,
                width: borderWidth,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: image != null
          ? Image(
              image: image!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _Fallback(
                  name: name,
                  fontSize: _fontSize,
                  foregroundColor: foregroundColor,
                  child: child,
                );
              },
            )
          : _Fallback(
              name: name,
              fontSize: _fontSize,
              foregroundColor: foregroundColor,
              child: child,
            ),
    );

    if (status == null) {
      return avatar;
    }

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,

          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: _size * 0.28,
              height: _size * 0.28,
              decoration: BoxDecoration(
                color: status!
                    ? (statusColor ?? hbColors.success.base)
                    : const Color(0xFFA1A1AA),
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusBorderColor ?? hbColors.border,
                  width: statusBorderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.name,
    required this.child,
    required this.fontSize,
    required this.foregroundColor,
  });

  final String? name;
  final Widget? child;
  final double fontSize;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Center(child: child);
    }

    final initials = _getInitials(name);

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: foregroundColor ?? HColors.of(context).tertiary.onSoft,
        ),
      ),
    );
  }

  String _getInitials(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '?';
    }

    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}
