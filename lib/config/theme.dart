import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData themeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(240, 248, 255, 1)),
    useMaterial3: true,
    textTheme: GoogleFonts.outfitTextTheme(),
  );
}
