import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for FieldTrack application powered by Google Fonts (Inter).
abstract final class AppTextStyles {
  // "Welcome back", "Create your account" — big hero title
  static TextStyle headingLarge = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 24,
  );

  // AppBar titles: "Locations", "My tasks", "Sync", "Profile"
  static TextStyle headingMedium = GoogleFonts.inter(
    fontWeight: FontWeight.w800,
    fontSize: 22,
  );

  // "FieldTrack" logo wordmark / secondary section titles
  static TextStyle title = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 21,
  );

  // List/card titles: location name, todo title
  static TextStyle cardTitle = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  // List/card second line: coordinates, todo description
  static TextStyle cardSubtitle = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 13,
  );

  // Under-heading subtitle: "Monday, Jun 15", "Sign in to start your shift"
  static TextStyle subtitle = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
  );

  // Menu rows, profile fields, generic body copy
  static TextStyle body = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 14.5,
  );

  // Text typed inside TextFormFields
  static TextStyle inputText = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 15,
  );

  // Labels above fields: "Full name", "Location name", "Latitude"
  static TextStyle fieldLabel = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 12.5,
  );

  // Button text: "Sign in", "Save location", "Sync now"
  static TextStyle button = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 15.5,
  );

  // Bottom nav bar labels
  static TextStyle navbar = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 10.5,
  );

  // Chips: "Pending", "Active", "Completed", "Inactive"
  static TextStyle status = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );

  // Links: "Forgot password?", "Register", "Sign in"
  static TextStyle link = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 13.5,
  );

  // Emphasized values: "180 m" radius, "1 of 5 done", "3 changes pending"
  static TextStyle emphasis = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 13.5,
  );

  // ── Convenience Aliases ──
  static TextStyle get h1 => headingMedium;
  static TextStyle get h2 => title;
  static TextStyle get h3 => cardTitle;
  static TextStyle get h4 => cardTitle;
  static TextStyle get bodyMedium => body;
  static TextStyle get bodySmall => cardSubtitle;
  static TextStyle get caption => status;
}