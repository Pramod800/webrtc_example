import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    visualDensity: VisualDensity.standard,
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
    scaffoldBackgroundColor: Colors.white,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
  );
}
