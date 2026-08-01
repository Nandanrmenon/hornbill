import 'package:flutter/material.dart';
import 'package:hornbill/src/helpers/constants.dart';

class HornbillUiTheme {
  const HornbillUiTheme({this.seedColor = const Color(0xFF33C11D)});

  final Color seedColor;

  ThemeData lightTheme() => _buildTheme(Brightness.light);

  ThemeData darkTheme() => _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ).copyWith(primary: seedColor, secondary: seedColor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      splashFactory: NoSplash.splashFactory,
      pageTransitionsTheme: pageTransitionTheme(),
      appBarTheme: appBarTheme(colorScheme),
      cardTheme: cardTheme(colorScheme),
      filledButtonTheme: filledButtonTheme(colorScheme),
      outlinedButtonTheme: outlinedButtonTheme(colorScheme),
      iconButtonTheme: iconButtonTheme(colorScheme),
      segmentedButtonTheme: segmentedButtonTheme(colorScheme),
      switchTheme: switchTheme(colorScheme),
      menuTheme: menuTheme(colorScheme),
      navigationBarTheme: navigationBarTheme(colorScheme),
      navigationRailTheme: navigationRailTheme(colorScheme),
      popupMenuTheme: popupMenuTheme(colorScheme),
      dropdownMenuTheme: dropdownMenuTheme(colorScheme),
      inputDecorationTheme: inputDecorationTheme(colorScheme),
      bottomSheetTheme: bottomSheetTheme(colorScheme),
      dialogTheme: dialogTheme(colorScheme),
      checkboxTheme: checkboxTheme(colorScheme),
      progressIndicatorTheme: progressIndicatorTheme(),
      searchBarTheme: searchBarTheme(colorScheme),
      listTileTheme: listTileTheme(colorScheme),
    );
  }
}

PageTransitionsTheme pageTransitionTheme() {
  return PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    },
  );
}

AppBarTheme appBarTheme(ColorScheme scheme) {
  return AppBarTheme(
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'Google Sans Flex',
      fontSize: 20,
      fontVariations: [FontVariation('wght', 600), FontVariation('ROND', 100)],
      color: scheme.onSurface,
    ),
  );
}

CardThemeData cardTheme(ColorScheme scheme) {
  return CardThemeData(
    elevation: 0,
    color: scheme.surfaceContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(width: 2, color: scheme.outlineVariant, strokeAlign: 0),
    ),
  );
}

FilledButtonThemeData filledButtonTheme(ColorScheme scheme) {
  return FilledButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStatePropertyAll(0),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        );
      }),
    ),
  );
}

OutlinedButtonThemeData outlinedButtonTheme(ColorScheme scheme) {
  return OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        );
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          return scheme.surfaceContainerHighest;
        }
        return scheme.primaryContainer.withValues(
          alpha: 0.2,
        ); // Use the default background color
      }),
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        return BorderSide(width: 2, color: scheme.primaryFixedDim);
      }),
    ),
  );
}

IconButtonThemeData iconButtonTheme(ColorScheme scheme) {
  return IconButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        );
      }),
    ),
  );
}

SegmentedButtonThemeData segmentedButtonTheme(ColorScheme scheme) {
  return SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return scheme.tertiaryContainer;
        }
        return scheme
            .surfaceContainerHighest; // Use the default background color
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
          return scheme.onTertiaryContainer;
        }
        return scheme.onSurface; // Use the default icon color
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

SwitchThemeData switchTheme(ColorScheme scheme) {
  return SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return scheme.tertiaryFixed;
      }
      return null; // Use the default thumb color
    }),
    trackColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return scheme.tertiary;
      }
      return scheme.surfaceContainerHigh;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return scheme.tertiary;
      }
      return scheme.outlineVariant;
    }),
    trackOutlineWidth: WidgetStateProperty.resolveWith<double?>((
      Set<WidgetState> states,
    ) {
      return 0;
    }),
  );
}

MenuThemeData menuTheme(ColorScheme scheme) {
  return MenuThemeData(style: menuStyle(scheme));
}

MenuStyle menuStyle(ColorScheme scheme) {
  return MenuStyle(
    backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
    ),
  );
}

NavigationBarThemeData navigationBarTheme(ColorScheme scheme) {
  return NavigationBarThemeData(
    backgroundColor: scheme.surfaceContainerLowest,
    iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: scheme.primary);
      }
      return IconThemeData(color: scheme.onSurface);
    }),
    indicatorColor: Colors.transparent,
  );
}

NavigationRailThemeData navigationRailTheme(ColorScheme scheme) {
  return NavigationRailThemeData(
    backgroundColor: scheme.surfaceContainer,
    groupAlignment: 0.0,
    selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
    labelType: NavigationRailLabelType.selected,
    unselectedIconTheme: IconThemeData(color: scheme.onSurface),
    selectedLabelTextStyle: TextStyle(color: scheme.onPrimaryContainer),
    unselectedLabelTextStyle: TextStyle(color: scheme.onSurface),
  );
}

PopupMenuThemeData popupMenuTheme(ColorScheme scheme) {
  return PopupMenuThemeData(
    elevation: 1,
    color: scheme.surfaceContainerHighest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
    ),
  );
}

DropdownMenuThemeData dropdownMenuTheme(ColorScheme scheme) {
  return DropdownMenuThemeData(
    menuStyle: menuStyle(scheme),
    inputDecorationTheme: inputDecorationTheme(scheme),
  );
}

InputDecorationTheme inputDecorationTheme(ColorScheme scheme) {
  return InputDecorationTheme(
    filled: true,
    border: OutlineInputBorder(borderSide: BorderSide(width: 0)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: BorderSide(width: 1, color: scheme.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: BorderSide(color: scheme.primary, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: BorderSide(color: scheme.error, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: BorderSide(color: scheme.error, width: 1),
    ),
  );
}

BottomSheetThemeData bottomSheetTheme(ColorScheme scheme) {
  return BottomSheetThemeData(
    backgroundColor: scheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

DialogThemeData dialogTheme(ColorScheme scheme) {
  return DialogThemeData(
    backgroundColor: scheme.surfaceContainer,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  );
}

CheckboxThemeData checkboxTheme(ColorScheme scheme) {
  return CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return scheme.onPrimary;
      }
      return null; // Use the default check color
    }),
    fillColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return scheme.primary;
      }
      return null; // Use the default fill color
    }),
    side: BorderSide(color: scheme.onSurfaceVariant, width: 1.5),
  );
}

ProgressIndicatorThemeData progressIndicatorTheme() {
  return ProgressIndicatorThemeData(
    year2023: false,
    linearMinHeight: 10,
    borderRadius: BorderRadius.circular(99),
  );
}

SearchBarThemeData searchBarTheme(ColorScheme scheme) {
  return SearchBarThemeData(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusRounded),
        side: BorderSide(
          width: 1,
          color: scheme.outlineVariant,
          strokeAlign: 0,
        ),
      ),
    ),
    backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
  );
}

ListTileThemeData listTileTheme(ColorScheme scheme) {
  return ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
    ),
  );
}
