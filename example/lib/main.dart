import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hornbill/hornbill.dart';
import 'package:hornbill_example/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: HornbillTheme(
        appBarFontFamily: GoogleFonts.googleSansFlex().fontFamily,
      ).lightTheme(),
      darkTheme: HornbillTheme(
        appBarFontFamily: GoogleFonts.googleSansFlex().fontFamily,
      ).darkTheme(),
      themeMode: ThemeMode.system,
      home: const HornbilExampleApp(),
    );
  }
}
