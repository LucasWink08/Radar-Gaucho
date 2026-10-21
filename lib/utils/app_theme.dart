

import 'package:flutter/material.dart';

class AppTheme {

  static const Color vermelho    = Color(0xFF8B1A1A);
  static const Color dourado     = Color(0xFFC49A2A);
  static const Color marrom      = Color(0xFF5C3A1E);
  static const Color bege        = Color(0xFFF5ECD7);
  static const Color verdeEscuro = Color(0xFF1B4332);


  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 163, 157, 157),
        primary:   vermelho,
        secondary: dourado,
        surface:   bege,
      ),
      scaffoldBackgroundColor: bege,


      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 180, 179, 179),
        foregroundColor: Colors.white,
        centerTitle:     true,
        elevation:       4,
        titleTextStyle: TextStyle(
          fontSize:      20,
          fontWeight:    FontWeight.bold,
          color:         Colors.white,
          letterSpacing: 1.1,
 
        ),
      ),

      cardTheme: CardThemeData(
        color:     Colors.white,
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          side:    const BorderSide(color: vermelho, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: Colors.white,
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: dourado)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: dourado)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: vermelho, width: 2)),
        labelStyle:      const TextStyle(color: marrom),
        prefixIconColor: vermelho,
      ),

      
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: marrom),
        titleLarge:     TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: marrom),
        bodyLarge:      TextStyle(fontSize: 16, color: marrom),
        bodyMedium:     TextStyle(fontSize: 14, color: marrom),
  
      ),

 
      chipTheme: ChipThemeData(
        backgroundColor: bege,
        selectedColor:   vermelho,
        side:            const BorderSide(color: dourado),
        labelStyle:      const TextStyle(color: marrom),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),


      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: dourado,
        foregroundColor: Colors.white,
      ),

    );
  }
}