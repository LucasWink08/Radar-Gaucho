import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'utils/app_theme.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/session_manager.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }


  runApp(const RadarGauchoApp());
}

class RadarGauchoApp extends StatelessWidget {
  const RadarGauchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar Gaúcho',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _verificandoSessao;

  @override
  void initState() {
    super.initState();

    _verificandoSessao = Future.wait([
      SessionManager.isLoggedIn(),
      Future.delayed(const Duration(milliseconds: 700)),
    ]).then((resultados) => resultados[0] as bool);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _verificandoSessao,
      builder: (context, snapshot) {

        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }

        final logado = snapshot.data ?? false;
        return logado ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
