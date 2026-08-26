import 'package:google_fonts/google_fonts.dart';
import 'package:hornbill/hornbill.dart';
import 'package:hornbill_example/app.dart';
import 'package:hornbill_example/theme_controller.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Owns the colour scheme currently applied to [HTheme]. Passed down to
  /// [ThemeScreen] so the user can change it and see the whole app
  /// re-theme live.
  final HThemeController _themeController = HThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return MaterialApp(
          theme: HTheme(
            colourScheme: _themeController.colourScheme,
            appBarFontFamily: GoogleFonts.googleSansFlex().fontFamily,
          ).lightTheme(),
          darkTheme: HTheme(
            colourScheme: _themeController.colourScheme,
            appBarFontFamily: GoogleFonts.googleSansFlex().fontFamily,
          ).darkTheme(),
          themeMode: ThemeMode.system,
          home: HornbilExampleApp(themeController: _themeController),
        );
      },
    );
  }
}
