

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../models/user.dart';
import '../services/database_helper.dart';
import '../utils/app_theme.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _form = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarSenhaCtrl = TextEditingController();
  bool _senhaVisivel = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _prepararBanco();
  }

  Future<void> _prepararBanco() async {
    try {
      await DatabaseHelper.instance.ensureInitialized();
    } catch (e) {
      debugPrint('Erro ao preparar banco: $e');
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarSenhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _salvando = true);

    final novoUsuario = User(
      name: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim().toLowerCase(),
      password: _senhaCtrl.text,
    );

    try {
        await DatabaseHelper.instance
          .insertUser(novoUsuario)
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cadastro realizado! Faça login para continuar.'),
        backgroundColor: AppTheme.verdeEscuro,
      ));
      Navigator.pop(context);
    } on DatabaseException catch (e) {
      // isUniqueConstraintError(): true quando o erro veio da coluna
      // 'email TEXT UNIQUE' — ou seja, já existe esse e-mail cadastrado.
      final mensagem = e.isUniqueConstraintError()
          ? 'Este e-mail já está cadastrado.'
          : 'Não foi possível concluir o cadastro.';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(mensagem),
        backgroundColor: AppTheme.vermelho,
      ));
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('O banco demorou demais para responder. Tente novamente.'),
        backgroundColor: AppTheme.vermelho,
      ));
    } catch (e) {
      // Qualquer erro que NÃO seja do SQLite (ex.: banco de dados não
      // inicializado corretamente na plataforma atual) caía fora do
      // "on DatabaseException" acima e não mostrava nada na tela —
      // por isso parecia que o botão "não fazia nada".
      debugPrint('Erro ao cadastrar: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Não foi possível concluir o cadastro: $e'),
        backgroundColor: AppTheme.vermelho,
      ));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Nome ─────────────────────────────────────────────
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o nome';
                  if (v.trim().split(' ').length < 2) {
                    return 'Informe nome e sobrenome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── E-mail ───────────────────────────────────────────
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Senha ────────────────────────────────────────────
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
                  if (v.length < 6) {
                    return 'A senha deve ter ao menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Confirmar senha ──────────────────────────────────
              TextFormField(
                controller: _confirmarSenhaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Confirmar senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: !_senhaVisivel,
                validator: (v) {
                  if (v != _senhaCtrl.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Botão (animado, mesmo padrão do resto do app) ────
              ElevatedButton(
                onPressed: _salvando ? null : _cadastrar,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _salvando
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(key: ValueKey('cadastrar'), 'Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
