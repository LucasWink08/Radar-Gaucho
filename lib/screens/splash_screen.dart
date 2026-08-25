

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bege,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.verdeEscuro, AppTheme.marrom],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.celebration,
                size: 56,
                color: AppTheme.dourado,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Radar Gaúcho',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Bailes, bandas e reservas em um só lugar',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.marrom, fontSize: 13),
            ),

            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppTheme.vermelho),
          ],
        ),
      ),
    );
  }
}
