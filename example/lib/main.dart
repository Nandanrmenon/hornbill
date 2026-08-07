import 'package:flutter/material.dart';
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
        // dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
        appBarFontFamily: GoogleFonts.bodoniModa().fontFamily,
      ).lightTheme(),
      darkTheme: HornbillTheme(
        // dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
        appBarFontFamily: GoogleFonts.bodoniModa().fontFamily,
      ).darkTheme(),
      home: const HornbilExampleApp(),
    );
  }
}
