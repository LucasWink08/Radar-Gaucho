import 'package:flutter/material.dart';

class AppTheme {
  // Paleta inspirada nas cores do chimarrão, couro e pampa
  static const Color vermelho = Color(0xFF8B1A1A);   // vermelho vinho gaúcho
  static const Color dourado = Color(0xFFC49A2A);    // dourado do poncho
  static const Color marrom = Color(0xFF5C3A1E);     // couro
  static const Color bege = Color(0xFFF5ECD7);       // pampa seco
  static const Color verdeEscuro = Color(0xFF1B4332); // erva-mate
  static const Color cinzaClaro = Color(0xFFF2F2F2);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: vermelho,
        primary: vermelho,
        secondary: dourado,
        surface: bege,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: bege,
      appBarTheme: const AppBarTheme(
        backgroundColor: vermelho,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: dourado, width: 0.8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vermelho,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: vermelho,
          side: const BorderSide(color: vermelho, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: dourado),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: vermelho, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: dourado),
        ),
        labelStyle: const TextStyle(color: marrom),
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIconColor: vermelho,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: vermelho,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Merriweather',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: marrom,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: marrom,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: marrom,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: marrom,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: vermelho,
        selectedItemColor: dourado,
        unselectedItemColor: Colors.white60,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bege,
        selectedColor: vermelho,
        labelStyle: const TextStyle(color: marrom),
        side: const BorderSide(color: dourado),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: dourado,
        thickness: 0.8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: dourado,
        foregroundColor: Colors.white,
      ),
    );
  }
}