import 'package:flutter/material.dart';

const secondary1 = Color(0xFFC2FF5F);
const secondary12 = Color(0xFF6ED939);
const secondary13 = Color(0xFF57E398);

const darkColorScheme = ColorScheme.dark(
  //brightness: Brightness.light,
  primary: Color(0xFFB2D18A),
  onPrimary: Color(0xFF1F3701),
  primaryContainer: Color(0xFFB2D18A), //floating button
  onPrimaryContainer: Color(0xFF1F3701),
  //
  secondary: Color(0xFF57E398),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFB2D18A), //nav選択時の色
  onSecondaryContainer: Color(0xFF1F3701),
  //
  surface: Color(0xFF051200),
  onSurface: Color(0xFFEDEDED),
  surfaceContainer: Color(0xFF20251D),
  surfaceDim: Color(0xFF131512),
  surfaceContainerLow: Color(0xFF272B25),
  onSurfaceVariant: Color(0xFF94958F), //onNav
  //onSurfaceVariant: Color(0xFFC2C3BF), //onCard
  //
  error: Colors.red,
  onError: Colors.white,
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF6750A4),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFEADDFF),
  onPrimaryContainer: Color(0xFF21005D),
  secondary: Color(0xFF625B71),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFE8DEF8),
  onSecondaryContainer: Color(0xFF1D192B),
  background: Color(0xFFFFFBFE),
  onBackground: Color(0xFF1C1B1F),
  surface: Colors.white,
  onSurface: Color(0xFF1C1B1F),
  error: Colors.red,
  onError: Colors.white,
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
);
