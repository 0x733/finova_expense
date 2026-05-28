import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinovaColors extends ThemeExtension<FinovaColors> {
  const FinovaColors({
    required this.balanceGradientStart,
    required this.balanceGradientEnd,
    required this.glassSurface,
    required this.success,
    required this.warning,
  });

  final Color balanceGradientStart;
  final Color balanceGradientEnd;
  final Color glassSurface;
  final Color success;
  final Color warning;

  @override
  ThemeExtension<FinovaColors> copyWith({
    Color? balanceGradientStart,
    Color? balanceGradientEnd,
    Color? glassSurface,
    Color? success,
    Color? warning,
  }) {
    return FinovaColors(
      balanceGradientStart: balanceGradientStart ?? this.balanceGradientStart,
      balanceGradientEnd: balanceGradientEnd ?? this.balanceGradientEnd,
      glassSurface: glassSurface ?? this.glassSurface,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  ThemeExtension<FinovaColors> lerp(covariant ThemeExtension<FinovaColors>? other, double t) {
    if (other is! FinovaColors) return this;
    return FinovaColors(
      balanceGradientStart: Color.lerp(balanceGradientStart, other.balanceGradientStart, t)!,
      balanceGradientEnd: Color.lerp(balanceGradientEnd, other.balanceGradientEnd, t)!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

ThemeData buildLightTheme(ColorScheme? dynamicScheme) {
  final scheme = dynamicScheme ?? ColorScheme.fromSeed(seedColor: const Color(0xFF1E40FF));
  return _buildTheme(scheme.copyWith(surface: const Color(0xFFF5F7FC)));
}

ThemeData buildDarkTheme(ColorScheme? dynamicScheme) {
  final scheme = dynamicScheme ?? ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: const Color(0xFF1E40FF));
  return _buildTheme(scheme.copyWith(surface: const Color(0xFF0D1222)));
}

ThemeData _buildTheme(ColorScheme scheme) {
  final baseText = GoogleFonts.interTextTheme().apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: baseText,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),
    extensions: [
      FinovaColors(
        balanceGradientStart: const Color(0xFF1D4ED8),
        balanceGradientEnd: const Color(0xFF10B981),
        glassSurface: scheme.surface.withValues(alpha: 0.7),
        success: const Color(0xFF10B981),
        warning: const Color(0xFFF59E0B),
      ),
    ],
  );
}

extension FinovaThemeX on BuildContext {
  FinovaColors get finovaColors => Theme.of(this).extension<FinovaColors>()!;

  ImageFilter get glassBlur => ImageFilter.blur(sigmaX: 12, sigmaY: 12);
}
