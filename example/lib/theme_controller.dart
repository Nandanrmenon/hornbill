import 'package:hornbill/hornbill.dart';
import 'package:material_ui/material_ui.dart';

/// A named [HColourScheme] preset, used to drive the colour-scheme picker
/// in the example app.
class HColourSchemeOption {
  const HColourSchemeOption(this.label, this.scheme);

  final String label;
  final HColourScheme scheme;
}

/// All built-in [HColourScheme] presets, paired with a display label.
///
/// This list is only used to populate the picker in the example app -
/// consumers of the `hornbill` package can just reference `HColourScheme.*`
/// directly.
const List<HColourSchemeOption> kHColourSchemeOptions = [
  HColourSchemeOption('Purple', HColourScheme.purple),
  HColourSchemeOption('Red', HColourScheme.red),
  HColourSchemeOption('Orange', HColourScheme.orange),
  HColourSchemeOption('Amber', HColourScheme.amber),
  HColourSchemeOption('Yellow', HColourScheme.yellow),
  HColourSchemeOption('Green', HColourScheme.green),
  HColourSchemeOption('Teal', HColourScheme.teal),
  HColourSchemeOption('Cyan', HColourScheme.cyan),
  HColourSchemeOption('Blue', HColourScheme.blue),
  HColourSchemeOption('Indigo', HColourScheme.indigo),
  HColourSchemeOption('Pink', HColourScheme.pink),
  HColourSchemeOption('Brown', HColourScheme.brown),
  HColourSchemeOption('Grey', HColourScheme.grey),
];

/// Holds the [HColourScheme] currently applied to the example app and
/// notifies listeners (namely [MyApp]) whenever it changes, so the whole
/// app can rebuild its [HTheme] and re-theme live.
///
/// This is intentionally tiny - it exists to demonstrate that `HTheme` is
/// just a plain, immutable value object. Swapping the colour scheme at
/// runtime is as simple as constructing a new `HTheme` with a different
/// `colourScheme` and feeding it to `MaterialApp`.
class HThemeController extends ChangeNotifier {
  HThemeController({HColourScheme initial = HColourScheme.purple})
    : _colourScheme = initial;

  HColourScheme _colourScheme;

  /// The colour scheme that should currently be applied to [HTheme].
  HColourScheme get colourScheme => _colourScheme;

  /// Updates the colour scheme and notifies listeners so they can rebuild
  /// with a fresh [HTheme].
  void setColourScheme(HColourScheme scheme) {
    if (_colourScheme == scheme) return;
    _colourScheme = scheme;
    notifyListeners();
  }
}
