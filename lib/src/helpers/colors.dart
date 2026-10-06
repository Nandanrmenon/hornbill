import 'package:material_ui/material_ui.dart';

// =============================================================================
// HColors: Hornbill's own colour system.
//
// Widgets read colours with `context.hColors` (or `HColors.of(context)`)
// instead of `Theme.of(context).colorScheme`. HTheme generates an HColors from
// an [HColourScheme] seed for light and dark, and registers it on the
// ThemeData as a ThemeExtension.
//
// Hornbill never creates or reads a Material ColorScheme.
// =============================================================================

/// Preset accent colours for the Hornbill theme.
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

  static const purple = HColourScheme._(Color(0xFF591DC1)); // default
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
  static const grey = HColourScheme._(Color.fromARGB(255, 25, 25, 25));
}

/// One accent colour and everything needed to use it accessibly.
@immutable
class HColorRole {
  const HColorRole({
    required this.base,
    required this.onBase,
    required this.soft,
    required this.onSoft,
    required this.shades,
  });

  /// The main colour (solid buttons, switches, focus, icons).
  final Color base;

  /// Text/icon colour to put on top of [base].
  final Color onBase;

  /// A gentle tinted background (chips, flat buttons, selected rows).
  final Color soft;

  /// Text/icon colour to put on top of [soft].
  final Color onSoft;

  /// Full 50 to 900 scale generated from [base].
  final Map<int, Color> shades;

  /// `role.shade(300)`, etc. Valid steps: 50, 100, 200 ... 900.
  Color shade(int step) => shades[step]!;

  static const _lightness = {
    50: 0.96,
    100: 0.91,
    200: 0.82,
    300: 0.72,
    400: 0.62,
    500: 0.52,
    600: 0.42,
    700: 0.32,
    800: 0.22,
    900: 0.14,
  };

  /// Builds a role from a single colour.
  factory HColorRole.fromColor(
    Color base, {
    required Brightness brightness,
    required Color background,
  }) {
    final hsl = HSLColor.fromColor(base);
    final shades = {
      for (final e in _lightness.entries)
        e.key: hsl
            .withLightness(e.value)
            // Very light/dark steps look better slightly desaturated.
            .withSaturation(
              (e.key <= 100 || e.key >= 800)
                  ? hsl.saturation * 0.9
                  : hsl.saturation,
            )
            .toColor(),
    };
    final dark = brightness == Brightness.dark;
    return HColorRole(
      base: base,
      onBase: _onColor(base),
      soft: Color.alphaBlend(
        base.withValues(alpha: dark ? 0.22 : 0.14),
        background,
      ),
      onSoft: dark ? shades[300]! : shades[700]!,
      shades: shades,
    );
  }

  static Color _onColor(Color c) => c.computeLuminance() > 0.45
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);

  static HColorRole lerp(HColorRole a, HColorRole b, double t) => HColorRole(
    base: Color.lerp(a.base, b.base, t)!,
    onBase: Color.lerp(a.onBase, b.onBase, t)!,
    soft: Color.lerp(a.soft, b.soft, t)!,
    onSoft: Color.lerp(a.onSoft, b.onSoft, t)!,
    shades: {
      for (final k in a.shades.keys)
        k: Color.lerp(a.shades[k], b.shades[k], t)!,
    },
  );
}

/// All colour tokens for one brightness.
@immutable
class HColors extends ThemeExtension<HColors> {
  const HColors({
    required this.brightness,
    required this.background,
    required this.backgroundSubtle,
    required this.backgroundMuted,
    required this.backgroundStrong,
    required this.foreground,
    required this.content1,
    required this.content2,
    required this.content3,
    required this.content4,
    required this.border,
    required this.borderStrong,
    required this.mutedForeground,
    required this.overlay,
    required this.shadow,
    required this.neutral,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Brightness brightness;

  /// App/page background.
  final Color background;

  /// Tiny steps away from [background], for striping rows, sidebars, input
  /// wells and other barely-there separation. They move toward [foreground],
  /// so they get slightly darker in light mode and slightly lighter in dark
  /// mode. Roughly 2%, 4% and 7% (light) / 4%, 7% and 11% (dark).
  final Color backgroundSubtle, backgroundMuted, backgroundStrong;

  /// [background] nudged toward [foreground] by [amount] (0 to 1), for when
  /// the three presets above aren't the right step. `backgroundAt(0.03)`.
  Color backgroundAt(double amount) =>
      Color.lerp(background, foreground, amount.clamp(0.0, 1.0))!;

  /// Default text/icon colour.
  final Color foreground;

  /// Layered surfaces, from closest to the background (1) to most raised (4):
  /// cards -> inputs/hover -> menus -> highest.
  final Color content1, content2, content3, content4;

  /// Subtle dividers and outlines.
  final Color border;

  /// Stronger outlines.
  final Color borderStrong;

  /// Secondary text.
  final Color mutedForeground;

  /// Modal barrier colour.
  final Color overlay;
  final Color shadow;

  /// Grey scale (50 to 900). Flips automatically in dark mode, so 50 is always
  /// the "lightest-feeling" surface and 900 the strongest text.
  final Map<int, Color> neutral;

  final HColorRole primary, secondary, tertiary;
  final HColorRole success, warning, danger;

  bool get isDark => brightness == Brightness.dark;

  // ---- Lookup ---------------------------------------------------------------

  static HColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<HColors>() ??
        HColors.fromScheme(HColourScheme.purple, theme.brightness);
  }

  // ---- Generation -----------------------------------------------------------

  static const _neutralLight = {
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF4F4F5),
    200: Color(0xFFE4E4E7),
    300: Color(0xFFD4D4D8),
    400: Color(0xFFA1A1AA),
    500: Color(0xFF71717A),
    600: Color(0xFF52525B),
    700: Color(0xFF3F3F46),
    800: Color(0xFF27272A),
    900: Color(0xFF18181B),
  };

  static const _neutralDark = {
    50: Color(0xFF18181B),
    100: Color(0xFF27272A),
    200: Color(0xFF3F3F46),
    300: Color(0xFF52525B),
    400: Color(0xFF71717A),
    500: Color(0xFFA1A1AA),
    600: Color(0xFFD4D4D8),
    700: Color(0xFFE4E4E7),
    800: Color(0xFFF4F4F5),
    900: Color(0xFFFAFAFA),
  };

  // Status colours are intentionally fixed; they mean the same thing in
  // every theme.
  static const _success = Color(0xFF17C964);
  static const _warning = Color(0xFFF5A524);
  static const _danger = Color(0xFFF31260);

  /// Generates the full token set from an accent [scheme].
  factory HColors.fromScheme(HColourScheme scheme, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final neutral = dark ? _neutralDark : _neutralLight;
    final background = dark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

    // Accent seeds are tuned for light mode. In dark mode, lift lightness so
    // they stay readable on dark surfaces.
    Color tune(HSLColor c) =>
        (dark ? c.withLightness(c.lightness < 0.66 ? 0.66 : c.lightness) : c)
            .toColor();

    final seed = HSLColor.fromColor(scheme.seedColor);
    final primary = dark ? tune(seed) : scheme.seedColor;
    final secondary = tune(seed.withSaturation(seed.saturation * 0.45));
    final tertiary = tune(
      seed.withHue((seed.hue + 60) % 360).withSaturation(seed.saturation * 0.8),
    );

    HColorRole role(Color c) =>
        HColorRole.fromColor(c, brightness: brightness, background: background);

    final foreground = dark ? const Color(0xFFECEDEE) : const Color(0xFF11181C);
    Color backgroundStep(double light, double darkAmount) =>
        Color.lerp(background, foreground, dark ? darkAmount : light)!;

    return HColors(
      brightness: brightness,
      background: background,
      backgroundSubtle: backgroundStep(0.02, 0.04),
      backgroundMuted: backgroundStep(0.04, 0.07),
      backgroundStrong: backgroundStep(0.07, 0.11),
      foreground: foreground,
      content1: neutral[50]!,
      content2: neutral[100]!,
      content3: neutral[200]!,
      content4: neutral[300]!,
      border: neutral[200]!,
      borderStrong: neutral[300]!,
      mutedForeground: neutral[500]!,
      overlay: const Color(0x80000000),
      shadow: const Color(0xFF000000),
      neutral: neutral,
      primary: role(primary),
      secondary: role(secondary),
      tertiary: role(tertiary),
      success: role(_success),
      warning: role(_warning),
      danger: role(_danger),
    );
  }

  // ---- ThemeExtension -------------------------------------------------------

  @override
  HColors copyWith({
    Brightness? brightness,
    Color? background,
    Color? backgroundSubtle,
    Color? backgroundMuted,
    Color? backgroundStrong,
    Color? foreground,
    Color? content1,
    Color? content2,
    Color? content3,
    Color? content4,
    Color? border,
    Color? borderStrong,
    Color? mutedForeground,
    Color? overlay,
    Color? shadow,
    Map<int, Color>? neutral,
    HColorRole? primary,
    HColorRole? secondary,
    HColorRole? tertiary,
    HColorRole? success,
    HColorRole? warning,
    HColorRole? danger,
  }) => HColors(
    brightness: brightness ?? this.brightness,
    background: background ?? this.background,
    backgroundSubtle: backgroundSubtle ?? this.backgroundSubtle,
    backgroundMuted: backgroundMuted ?? this.backgroundMuted,
    backgroundStrong: backgroundStrong ?? this.backgroundStrong,
    foreground: foreground ?? this.foreground,
    content1: content1 ?? this.content1,
    content2: content2 ?? this.content2,
    content3: content3 ?? this.content3,
    content4: content4 ?? this.content4,
    border: border ?? this.border,
    borderStrong: borderStrong ?? this.borderStrong,
    mutedForeground: mutedForeground ?? this.mutedForeground,
    overlay: overlay ?? this.overlay,
    shadow: shadow ?? this.shadow,
    neutral: neutral ?? this.neutral,
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    tertiary: tertiary ?? this.tertiary,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
  );

  @override
  HColors lerp(ThemeExtension<HColors>? other, double t) {
    if (other is! HColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return HColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: c(background, other.background),
      backgroundSubtle: c(backgroundSubtle, other.backgroundSubtle),
      backgroundMuted: c(backgroundMuted, other.backgroundMuted),
      backgroundStrong: c(backgroundStrong, other.backgroundStrong),
      foreground: c(foreground, other.foreground),
      content1: c(content1, other.content1),
      content2: c(content2, other.content2),
      content3: c(content3, other.content3),
      content4: c(content4, other.content4),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      mutedForeground: c(mutedForeground, other.mutedForeground),
      overlay: c(overlay, other.overlay),
      shadow: c(shadow, other.shadow),
      neutral: {
        for (final k in neutral.keys) k: c(neutral[k]!, other.neutral[k]!),
      },
      primary: HColorRole.lerp(primary, other.primary, t),
      secondary: HColorRole.lerp(secondary, other.secondary, t),
      tertiary: HColorRole.lerp(tertiary, other.tertiary, t),
      success: HColorRole.lerp(success, other.success, t),
      warning: HColorRole.lerp(warning, other.warning, t),
      danger: HColorRole.lerp(danger, other.danger, t),
    );
  }
}

/// `context.hColors` shorthand.
extension HColorsContext on BuildContext {
  HColors get hColors => HColors.of(this);
}
