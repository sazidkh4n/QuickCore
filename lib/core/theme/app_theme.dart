import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final light = FlexThemeData.light(
    scheme: FlexScheme.indigo,
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
  );

  static final dark = FlexThemeData.dark(
    scheme: FlexScheme.deepBlue,
    useMaterial3: true,
    darkIsTrueBlack: false,
    fontFamily: GoogleFonts.inter().fontFamily,
  );
} 