import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import '../services/database_helper.dart';
import '../utils/app_theme.dart';
import '../widgets/user_card.dart';
import '../widgets/user_form_dialog.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  List<User> _usuarios = [];
  List<User> _usuariosFiltrados = [];
  bool _carregando = true;
  final TextEditingController _buscaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buscaCtrl.addListener(_filtrarUsuarios);
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuarios() async {
    setState(() => _carregando = true);
    try {
      final usuarios = await DatabaseHelper.instance.retrieveUsers();
      if (!mounted) return;
      setState(() {
        _usuarios = usuarios;
        _usuariosFiltrados = usuarios;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar usuários: $e'),
          backgroundColor: AppTheme.vermelho,
        ),
      );
    }
  }

  void _filtrarUsuarios() {
    final busca = _buscaCtrl.text.toLowerCase();
    setState(() {
      _usuariosFiltrados = _usuarios
          .where((u) =>
              u.name.toLowerCase().contains(busca) ||
              u.email.toLowerCase().contains(busca))
          .toList();
    });
  }

  Future<void> _novoUsuario() async {
    final resultado = await showDialog<User>(
      context: context,
      builder: (_) => const _NovoUsuarioDialog(),
    );

    if (resultado == null) return;

    try {
      await DatabaseHelper.instance.insertUser(resultado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário criado com sucesso!'),
          backgroundColor: AppTheme.verdeEscuro,
        ),
      );
      _carregarUsuarios();
    } on DatabaseException catch (e) {
      if (!mounted) return;
      final mensagem = e.isUniqueConstraintError()
          ? 'Este e-mail já está em uso.'
          : 'Erro ao criar usuário.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: AppTheme.vermelho,
        ),
      );
    }
  }

  Future<void> _editarUsuario(User usuario) async {
    final atualizado = await showUserFormDialog(context, user: usuario);
    if (atualizado == null) return;

    try {
      await DatabaseHelper.instance.updateUser(atualizado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário atualizado com sucesso!'),
          backgroundColor: AppTheme.verdeEscuro,
        ),
      );
      _carregarUsuarios();
    } on DatabaseException catch (e) {
      if (!mounted) return;
      final mensagem = e.isUniqueConstraintError()
          ? 'Este e-mail já está em uso.'
          : 'Erro ao atualizar usuário.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: AppTheme.vermelho,
        ),
      );
    }
  }

  Future<void> _excluirUsuario(User usuario) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir usuário?'),
        content: Text(
            '${usuario.name} (${usuario.email})\n\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    try {
      await DatabaseHelper.instance.deleteUser(usuario.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário excluído com sucesso!'),
          backgroundColor: AppTheme.verdeEscuro,
        ),
      );
      _carregarUsuarios();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir usuário: $e'),
          backgroundColor: AppTheme.vermelho,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        elevation: 4,
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.vermelho),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _buscaCtrl,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou e-mail...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _buscaCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _buscaCtrl.clear();
                                _filtrarUsuarios();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _usuariosFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 72,
                                color: AppTheme.dourado,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _usuarios.isEmpty
                                    ? 'Nenhum usuário cadastrado'
                                    : 'Nenhum usuário encontrado',
                                style: const TextStyle(
                                  color: AppTheme.marrom,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _usuariosFiltrados.length,
                          itemBuilder: (ctx, i) {
                            final usuario = _usuariosFiltrados[i];
                            return UserCard(
                              user: usuario,
                              onEdit: () => _editarUsuario(usuario),
                              onDelete: () => _excluirUsuario(usuario),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoUsuario,
        icon: const Icon(Icons.add),
        label: const Text('Novo Usuário'),
        backgroundColor: AppTheme.dourado,
        foregroundColor: AppTheme.marrom,
      ),
    );
  }
}

class _NovoUsuarioDialog extends StatefulWidget {
  const _NovoUsuarioDialog();

  @override
  State<_NovoUsuarioDialog> createState() => _NovoUsuarioDialogState();
}

class _NovoUsuarioDialogState extends State<_NovoUsuarioDialog> {
  final _form = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarSenhaCtrl = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarSenhaCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_form.currentState!.validate()) return;

    final novoUsuario = User(
      name: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim().toLowerCase(),
      password: _senhaCtrl.text,
    );

    Navigator.pop(context, novoUsuario);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Usuário'),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _senhaCtrl,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      _senhaVisivel ? Icons.visibility_off : Icons.visibility),
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
            const SizedBox(height: 12),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.vermelho),
          child: const Text('Criar'),
        ),
      ],
    );
  }
}
