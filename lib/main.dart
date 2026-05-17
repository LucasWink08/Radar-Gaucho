
import 'package:flutter/material.dart';

import 'utils/app_theme.dart';


import 'screens/home_screen.dart';

void main() {
  runApp(const RadarGauchoApp());
}

class RadarGauchoApp extends StatelessWidget {
  const RadarGauchoApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Radar Gaúcho',
      debugShowCheckedModeBanner: false,

       theme: AppTheme.light(),

      
      home: const HomeScreen(),
    );
  }
}