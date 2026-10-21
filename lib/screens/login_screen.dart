

import 'package:flutter/material.dart';

import '../services/database_helper.dart';
import '../services/session_manager.dart';
import '../utils/app_theme.dart';
import 'cadastro_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _senhaVisivel = false;
  bool _entrando = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _entrando = true);

    try {
      final email = _emailCtrl.text.trim().toLowerCase();
      final usuario =
          await DatabaseHelper.instance.loginUser(email, _senhaCtrl.text);

      if (!mounted) return;

      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('E-mail ou senha inválidos.'),
          backgroundColor: AppTheme.vermelho,
        ));
        return;
      }

      await SessionManager.saveSession(
          userId: usuario.id!, userEmail: usuario.email);
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {

      debugPrint('Erro ao fazer login: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Não foi possível entrar: $e'),
        backgroundColor: AppTheme.vermelho,
      ));
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.celebration,
                      size: 64, color: AppTheme.vermelho),
                  const SizedBox(height: 12),
                  Text(
                    'Radar Gaúcho',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Entre para reservar sua mesa',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe o e-mail';
                      }
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  
                  TextFormField(
                    controller: _senhaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_senhaVisivel
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _senhaVisivel = !_senhaVisivel),
                      ),
                    ),
                    obscureText: !_senhaVisivel,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      return null;
                    },
                    onFieldSubmitted: (_) => _entrar(),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _entrando ? null : _entrar,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _entrando
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(key: ValueKey('entrar'), 'Entrar'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _entrando
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CadastroScreen()),
                            ),
                    child: const Text('Não tem conta? Cadastre-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
