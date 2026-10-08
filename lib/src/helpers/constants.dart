const kBorderRadiusNone = 0.0;
const kBorderRadiusSmall = 8.0;
const kBorderRadiusMedium = 12.0;
const kBorderRadius = 16.0;
const kBorderRadiusRounded = 99.0;

/// Corner radius presets.
enum HRadius {
  sharp(kBorderRadiusNone),
  sm(kBorderRadiusSmall),
  md(kBorderRadiusMedium),
  lg(kBorderRadius),
  rounded(kBorderRadiusRounded);

  const HRadius(this.value);
  final double value;
}
