import 'package:flutter/cupertino.dart';
import 'package:hornbill/src/helpers/colors.dart';
import 'package:hornbill/src/helpers/constants.dart';
import 'package:material_ui/material_ui.dart';

export 'package:hornbill/src/helpers/colors.dart';
export 'package:hornbill/src/helpers/constants.dart';

class HTheme {
  const HTheme({
    this.colourScheme = HColourScheme.purple,
    this.appBarFontFamily,
    this.fontFamily,
    this.outlined = true,
  });

  final HColourScheme colourScheme;
  final String? appBarFontFamily;
  final String? fontFamily;
  final bool outlined;

  ThemeData lightTheme() => _buildTheme(Brightness.light);

  ThemeData darkTheme() => _buildTheme(Brightness.dark);

  /// The generated colour tokens for [brightness].
  HColors colors(Brightness brightness) =>
      HColors.fromScheme(colourScheme, brightness);

  ThemeData _buildTheme(Brightness brightness) {
    final c = colors(brightness);

    // No ColorScheme is passed. Every colour Hornbill uses comes from HColors
    // (registered below as a ThemeExtension) and is applied explicitly to the
    // component themes here.
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [
        HThemeExtension(outlined: outlined),
        c,
      ],
      fontFamily: fontFamily,
      splashFactory: NoSplash.splashFactory,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      cardColor: c.content1,
      primaryColor: c.primary.base,
      hoverColor: c.foreground.withValues(alpha: 0.06),
      focusColor: c.foreground.withValues(alpha: 0.10),
      iconTheme: IconThemeData(color: c.foreground),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary.base,
        selectionColor: c.primary.base.withValues(alpha: 0.3),
        selectionHandleColor: c.primary.base,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary.base,
        linearTrackColor: c.content3,
        circularTrackColor: c.content3,
      ),
      pageTransitionsTheme: pageTransitionTheme(),
      appBarTheme: appBarTheme(
        c,
        fontFamily: appBarFontFamily,
        outlined: outlined,
      ),
      cardTheme: cardTheme(c, outlined: outlined),
      filledButtonTheme: filledButtonTheme(c),
      outlinedButtonTheme: outlinedButtonTheme(c),
      iconButtonTheme: iconButtonTheme(c),
      segmentedButtonTheme: segmentedButtonTheme(c),
      switchTheme: switchTheme(c),
      menuTheme: menuTheme(c, outlined: outlined),
      navigationBarTheme: navigationBarTheme(c),
      navigationRailTheme: navigationRailTheme(c),
      popupMenuTheme: popupMenuTheme(c, outlined: outlined),
      dropdownMenuTheme: dropdownMenuTheme(c, outlined: outlined),
      inputDecorationTheme: inputDecorationTheme(c),
      bottomSheetTheme: bottomSheetTheme(c),
      dialogTheme: dialogTheme(c, outlined: outlined),
      checkboxTheme: checkboxTheme(c),
      searchBarTheme: searchBarTheme(c, outlined: outlined),
      listTileTheme: listTileTheme(c),
    );

    // Text colours.
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: c.foreground,
        displayColor: c.foreground,
      ),
    );
  }
}

class HThemeExtension extends ThemeExtension<HThemeExtension> {
  const HThemeExtension({this.outlined = true});

  final bool outlined;

  @override
  HThemeExtension copyWith({bool? outlined}) {
    return HThemeExtension(outlined: outlined ?? this.outlined);
  }

  @override
  HThemeExtension lerp(ThemeExtension<HThemeExtension>? other, double t) {
    final otherOutlined = other is HThemeExtension ? other.outlined : outlined;
    return HThemeExtension(outlined: t < 0.5 ? outlined : otherOutlined);
  }
}

bool hIsOutlined(BuildContext context) {
  final extension = Theme.of(context).extension<HThemeExtension>();
  if (extension is HThemeExtension) {
    return extension.outlined;
  }
  return true;
}

PageTransitionsTheme pageTransitionTheme() {
  return PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    },
  );
}

AppBarTheme appBarTheme(HColors c, {String? fontFamily, bool outlined = true}) {
  return AppBarTheme(
    centerTitle: false,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    backgroundColor: c.background,
    foregroundColor: c.foreground,
    iconTheme: IconThemeData(color: c.foreground),
    titleTextStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontVariations: [FontVariation('wght', 600), FontVariation('ROND', 100)],
      color: c.foreground,
    ),
  );
}

CardThemeData cardTheme(HColors c, {bool outlined = true}) {
  return CardThemeData(
    elevation: 0,
    color: c.content1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: outlined
          ? BorderSide(width: 2, color: c.border, strokeAlign: 0)
          : BorderSide.none,
    ),
  );
}

FilledButtonThemeData filledButtonTheme(HColors c) {
  return FilledButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStatePropertyAll(0),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        return states.contains(WidgetState.disabled)
            ? c.content3
            : c.primary.base;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        return states.contains(WidgetState.disabled)
            ? c.mutedForeground
            : c.primary.onBase;
      }),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        );
      }),
    ),
  );
}

OutlinedButtonThemeData outlinedButtonTheme(HColors c) {
  return OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        return states.contains(WidgetState.disabled)
            ? c.mutedForeground
            : c.primary.base;
      }),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        );
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          return c.content3;
        }
        return c.primary.soft.withValues(alpha: 0.2);
      }),
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        return BorderSide(width: 2, color: c.primary.shade(300));
      }),
    ),
  );
}

IconButtonThemeData iconButtonTheme(HColors c) {
  return IconButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusRounded),
        );
      }),
    ),
  );
}

SegmentedButtonThemeData segmentedButtonTheme(HColors c) {
  return SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return c.tertiary.soft;
        }
        return c.content3;
      }),
      padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry?>((states) {
        return const EdgeInsets.symmetric(
          horizontal: kBorderRadius,
          vertical: 8,
        );
      }),
      iconColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return c.tertiary.onSoft;
        }
        return c.foreground;
      }),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        );
      }),
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        return BorderSide.none;
      }),
    ),
  );
}

SwitchThemeData switchTheme(HColors c) {
  return SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return c.tertiary.onBase;
      }
      return null; // Use the default thumb color
    }),
    trackColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return c.tertiary.base;
      }
      return c.content2;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return c.tertiary.base;
      }
      return c.border;
    }),
    trackOutlineWidth: WidgetStateProperty.resolveWith<double?>((
      Set<WidgetState> states,
    ) {
      return 0;
    }),
  );
}

MenuThemeData menuTheme(HColors c, {bool outlined = true}) {
  return MenuThemeData(style: menuStyle(c, outlined: outlined));
}

MenuStyle menuStyle(HColors c, {bool outlined = true}) {
  return MenuStyle(
    backgroundColor: WidgetStatePropertyAll(c.content1),
    elevation: WidgetStatePropertyAll(0),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        side: outlined
            ? BorderSide(width: 2, color: c.border)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(kBorderRadiusMedium),
      ),
    ),
  );
}

DropdownMenuThemeData dropdownMenuTheme(HColors c, {bool outlined = true}) {
  return DropdownMenuThemeData(
    menuStyle: menuStyle(c, outlined: outlined),
    inputDecorationTheme: inputDecorationTheme(c),
  );
}

NavigationBarThemeData navigationBarTheme(HColors c) {
  return NavigationBarThemeData(
    backgroundColor: c.background,
    iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: c.primary.base);
      }
      return IconThemeData(color: c.foreground);
    }),
    indicatorColor: Colors.transparent,
  );
}

NavigationRailThemeData navigationRailTheme(HColors c) {
  return NavigationRailThemeData(
    backgroundColor: c.content1,
    groupAlignment: 0.0,
    selectedIconTheme: IconThemeData(color: c.primary.onSoft),
    labelType: NavigationRailLabelType.selected,
    unselectedIconTheme: IconThemeData(color: c.foreground),
    selectedLabelTextStyle: TextStyle(color: c.primary.onSoft),
    unselectedLabelTextStyle: TextStyle(color: c.foreground),
  );
}

PopupMenuThemeData popupMenuTheme(HColors c, {bool outlined = true}) {
  return PopupMenuThemeData(
    elevation: 1,
    color: c.content3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      side: outlined ? BorderSide(color: c.border) : BorderSide.none,
    ),
  );
}

InputDecorationTheme inputDecorationTheme(HColors c) {
  return InputDecorationTheme(
    filled: true,
    fillColor: c.backgroundSubtle,
    floatingLabelStyle: TextStyle(color: c.primary.base),
    border: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: c.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusMedium),
      borderSide: BorderSide(width: 2, color: c.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusMedium),
      borderSide: BorderSide(color: c.primary.base, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusMedium),
      borderSide: BorderSide(color: c.danger.base, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusMedium),
      borderSide: BorderSide(color: c.danger.base, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusMedium),
      borderSide: BorderSide(width: 2, color: c.content2),
    ),
  );
}

BottomSheetThemeData bottomSheetTheme(HColors c) {
  return BottomSheetThemeData(
    backgroundColor: c.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

DialogThemeData dialogTheme(HColors c, {bool outlined = true}) {
  return DialogThemeData(
    backgroundColor: c.content1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  );
}

CheckboxThemeData checkboxTheme(HColors c) {
  return CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return c.primary.onBase;
      }
      return null;
    }),
    fillColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return c.primary.base;
      }
      return null;
    }),
    side: BorderSide(color: c.mutedForeground, width: 1.5),
  );
}

SearchBarThemeData searchBarTheme(HColors c, {bool outlined = true}) {
  return SearchBarThemeData(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusRounded),
        side: outlined
            ? BorderSide(width: 1, color: c.border, strokeAlign: 0)
            : BorderSide.none,
      ),
    ),
    backgroundColor: WidgetStatePropertyAll(c.content1),
  );
}

ListTileThemeData listTileTheme(HColors c) {
  return ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
    ),
  );
}
