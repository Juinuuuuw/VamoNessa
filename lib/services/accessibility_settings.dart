import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilitySettings {
  static const String _textScaleKey = 'text_scale_factor';
  static const String _highContrastKey = 'high_contrast_mode';

  static final ValueNotifier<double> textScaleNotifier = ValueNotifier<double>(1.0);
  static final ValueNotifier<bool> highContrastNotifier = ValueNotifier<bool>(false);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedScale = prefs.getDouble(_textScaleKey) ?? 1.0;
    final savedHighContrast = prefs.getBool(_highContrastKey) ?? false;
    textScaleNotifier.value = savedScale;
    highContrastNotifier.value = savedHighContrast;
  }

  static Future<void> setTextScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, scale);
    textScaleNotifier.value = scale;
  }

  static Future<void> setHighContrast(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, enabled);
    highContrastNotifier.value = enabled;
  }

  // Helper para verificar se o alto contraste está ativo
  static bool isHighContrast(BuildContext context) {
    return highContrastNotifier.value;
  }
}