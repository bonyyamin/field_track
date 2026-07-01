import 'package:flutter/material.dart';

/// Centralized text styles (Inter is set globally in ThemeData)
abstract final class AppTextStyles {
  static const TextStyle headingLarge = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 24,
  );

  static const TextStyle headingMedium = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 22,
  );

  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 21,
  );

  static const TextStyle cardTitle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13,
  );

  static const TextStyle subtitle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
  );

  static const TextStyle body = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.5,
  );

  static const TextStyle inputText = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12.5,
  );

  static const TextStyle button = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15.5,
  );

  static const TextStyle navbar = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 10.5,
  );

  static const TextStyle status = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );
}
