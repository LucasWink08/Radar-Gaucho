
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';


Future<User?> showUserFormDialog(BuildContext context, {required User user}) {
  return showDialog<User>(
    context: context,
    builder: (_) => _UserFormDialog(user: user),
  );
}

class _UserFormDialog extends StatefulWidget {
  final User user;
  const _UserFormDialog({required this.user});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _senhaCtrl;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
  
    _senhaCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_form.currentState!.validate()) return;

    final atualizado = widget.user.copyWith(
      name: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim().toLowerCase(),
  
      password: _senhaCtrl.text.isEmpty ? widget.user.password : _senhaCtrl.text,
    );
    Navigator.pop(context, atualizado);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar usuário'),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person)),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                if (!v.contains('@') || !v.contains('.')) return 'E-mail inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _senhaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nova senha',
                hintText: 'Deixe em branco para manter a atual',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (v) {
                if (v != null && v.isNotEmpty && v.length < 6) {
                  return 'A senha deve ter ao menos 6 caracteres';
                }
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
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
