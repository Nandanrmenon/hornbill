import 'package:material_ui/material_ui.dart';
import 'package:hornbill/src/helpers/constants.dart';

/// Preset colour schemes for the Hornbill theme.
/// Use like `HColourScheme.red`, `HColourScheme.blue`, etc.
class HColourScheme {
  const HColourScheme._(this.seedColor);

  final Color seedColor;

  /// Build a custom scheme from a [Color].
  factory HColourScheme.custom(Color color) => HColourScheme._(color);

  /// Build a custom scheme from a hex string.
  ///
  /// Accepts formats like `"#RRGGBB"`, `"RRGGBB"`, `"#AARRGGBB"`,
  /// `"AARRGGBB"`, with or without the leading `#`.
  factory HColourScheme.fromHex(String hex) {
    var value = hex.trim().replaceFirst('#', '');
    if (value.length == 6) {
      value = 'FF$value'; // assume fully opaque if no alpha given
    }
    if (value.length != 8) {
      throw FormatException('Invalid hex colour: $hex');
    }
    final intValue = int.parse(value, radix: 16);
    return HColourScheme._(Color(intValue));
  }

  // --- Presets -------------------------------------------------------

  static const purple = HColourScheme._(Color(0xFF591DC1)); // original default
  static const red = HColourScheme._(Color(0xFFB3261E));
  static const orange = HColourScheme._(Color(0xFFE8710A));
  static const amber = HColourScheme._(Color(0xFFC77800));
  static const yellow = HColourScheme._(Color(0xFFAE9200));
  static const green = HColourScheme._(Color(0xFF2E7D32));
  static const teal = HColourScheme._(Color(0xFF00796B));
  static const cyan = HColourScheme._(Color(0xFF00838F));
  static const blue = HColourScheme._(Color(0xFF1565C0));
  static const indigo = HColourScheme._(Color(0xFF3F51B5));
  static const pink = HColourScheme._(Color(0xFFD81B60));
  static const brown = HColourScheme._(Color(0xFF6D4C41));
  static const grey = HColourScheme._(Color(0xFF616161));
}

class HTheme {
  const HTheme({
    this.colourScheme = HColourScheme.purple,
    this.dynamicSchemeVariant = DynamicSchemeVariant.tonalSpot,
    this.appBarFontFamily,
    this.fontFamily,
  });

  final HColourScheme colourScheme;
  final DynamicSchemeVariant dynamicSchemeVariant;
  final String? appBarFontFamily;
  final String? fontFamily;

  ThemeData lightTheme() => _buildTheme(Brightness.light);

  ThemeData darkTheme() => _buildTheme(Brightness.dark);

  /// True neutral seed (R=G=B → zero chroma), so surfaces/outlines never
  /// pick up a tint from the accent colour regardless of scheme variant.
  static const _neutralSeed = Color(0xFF767680);

  ColorScheme _buildColorScheme(Brightness brightness) {
    final tinted = ColorScheme.fromSeed(
      seedColor: colourScheme.seedColor,
      brightness: brightness,
      dynamicSchemeVariant: dynamicSchemeVariant,
    );

    final neutral = ColorScheme.fromSeed(
      seedColor: _neutralSeed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
    );

    // Keep primary/secondary/tertiary tones from the tinted scheme,
    // but pull every surface/outline tone from the untinted neutral one.
    return tinted.copyWith(
      surface: neutral.surface,
      onSurface: neutral.onSurface,
      onSurfaceVariant: neutral.onSurfaceVariant,
      surfaceDim: neutral.surfaceDim,
      surfaceBright: neutral.surfaceBright,
      surfaceContainerLowest: neutral.surfaceContainerLowest,
      surfaceContainerLow: neutral.surfaceContainerLow,
      surfaceContainer: neutral.surfaceContainer,
      surfaceContainerHigh: neutral.surfaceContainerHigh,
      surfaceContainerHighest: neutral.surfaceContainerHighest,
      outline: neutral.outline,
      outlineVariant: neutral.outlineVariant,
      shadow: neutral.shadow,
      scrim: neutral.scrim,
      inverseSurface: neutral.inverseSurface,
      onInverseSurface: neutral.onInverseSurface,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = _buildColorScheme(brightness);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      splashFactory: NoSplash.splashFactory,
      pageTransitionsTheme: pageTransitionTheme(),
      appBarTheme: appBarTheme(colorScheme, fontFamily: appBarFontFamily),
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

AppBarTheme appBarTheme(ColorScheme scheme, {String? fontFamily}) {
  return AppBarTheme(
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: scheme.surface,
    titleTextStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
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
          borderRadius: BorderRadius.circular(kBorderRadiusRounded),
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
