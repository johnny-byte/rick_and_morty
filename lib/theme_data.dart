import 'package:flutter/material.dart';

class BrandTheme {
  static ThemeData defaultTheme = ThemeData(
    //TODO
    // colorScheme: ColorScheme(background: Color.fromARGB(255, 32, 35, 41),primary:
    //   Color.fromARGB(255, 60, 62, 68),),
    iconTheme: const IconThemeData(size: 10),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.white, fontSize: 20),
      bodySmall:
          TextStyle(color: Color.fromARGB(255, 158, 158, 158), fontSize: 16),
    ),
  );
}
