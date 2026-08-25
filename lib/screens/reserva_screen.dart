
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/evento.dart';
import '../models/reserva.dart';
import '../services/reserva_repo.dart';
import '../services/session_manager.dart';
import '../utils/app_theme.dart';


class ReservaScreen extends StatefulWidget {
  final Evento evento;
  const ReservaScreen({super.key, required this.evento});

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  final _form     = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl  = TextEditingController();
  final _foneCtrl = TextEditingController();
  int  _pessoas   = 1;
  bool _termos    = false;
  bool _salvando  = false;

  String get _pessoasKey => 'radar_gaucho_pessoas_${widget.evento.id}';

  @override
  void initState() {
    super.initState();
    _carregarPessoasSalvas();
  }

  Future<void> _carregarPessoasSalvas() async {
    final prefs = await SharedPreferences.getInstance();
    final pessoasSalvas = prefs.getInt(_pessoasKey);
    if (!mounted || pessoasSalvas == null) return;
    setState(() => _pessoas = pessoasSalvas.clamp(1, 10));
  }

  Future<void> _salvarPessoasSelecionadas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pessoasKey, _pessoas);
  }

  Future<void> _limparPessoasSalvas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pessoasKey);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _foneCtrl.dispose();

    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    if (!_termos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Aceite os termos para continuar.'),
        backgroundColor: AppTheme.vermelho,
      ));
      return;
    }

    setState(() => _salvando = true);

    final userId = await SessionManager.getUserId();
    if (userId == null) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sessão expirada. Faça login novamente.'),
        backgroundColor: AppTheme.vermelho,
      ));
      return;
    }

    final numeroMesa = await ReservaRepo.proximaMesa(widget.evento.id);
    final codigo = 'r${DateTime.now().millisecondsSinceEpoch}';

    final reserva = Reserva(
      userId:          userId,
      codigo:          codigo,
      eventoId:        widget.evento.id,
      nomeEvento:      widget.evento.nome,
      nomeResponsavel: _nomeCtrl.text.trim(),
      cpf:             _cpfCtrl.text.trim(),
      telefone:        _foneCtrl.text.trim(),
      numeroPessoas:   _pessoas,
      numeroMesa:      numeroMesa,
      criadaEm:        DateTime.now(),
      // TODO [FUTURO]: email: _emailCtrl.text.trim(),
    );

    await ReservaRepo.salvar(reserva);
    await _limparPessoasSalvas();
    setState(() => _salvando = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppTheme.verdeEscuro,
      content: Text(
        '✓ Mesa $numeroMesa reservada! '
        'Código: ${codigo.substring(1, 9).toUpperCase()}',
      ),
      duration: const Duration(seconds: 4),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.evento.preco * _pessoas;

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.evento.nome, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

       
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.vermelho.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppTheme.dourado.withValues(alpha: 0.5)),
                ),
                child: Row(children: [
                  const Icon(Icons.table_restaurant,
                      color: AppTheme.vermelho, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.evento.nome,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(
                          '${widget.evento.mesasDisponiveis} mesas disponíveis',
                          style: const TextStyle(
                              color: AppTheme.verdeEscuro, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 20),
              Text('Dados do responsável',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 14),

              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome completo *',
                    prefixIcon: Icon(Icons.person)),
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

              // ── CPF ──────────────────────────────────────────────
              TextFormField(
                controller: _cpfCtrl,
                decoration: const InputDecoration(
                    labelText: 'CPF *',
                    prefixIcon: Icon(Icons.badge),
                    hintText: '000.000.000-00'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CpfMask(),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o CPF';
                  if (v.replaceAll(RegExp(r'\D'), '').length != 11) {
                    return 'CPF inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Telefone ─────────────────────────────────────────
              TextFormField(
                controller: _foneCtrl,
                decoration: const InputDecoration(
                    labelText: 'Telefone *',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '(00) 00000-0000'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _FoneMask(),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o telefone';
                  if (v.replaceAll(RegExp(r'\D'), '').length < 10) {
                    return 'Telefone inválido';
                  }
                  return null;
                },
              ),

              // TODO [FUTURO]: adicionar campo e-mail aqui
              // const SizedBox(height: 14),
              // TextFormField(
              //   controller: _emailCtrl,
              //   decoration: const InputDecoration(
              //       labelText: 'E-mail *', prefixIcon: Icon(Icons.email)),
              //   keyboardType: TextInputType.emailAddress,
              //   validator: (v) { ... },
              // ),

              // ── Contador de pessoas ──────────────────────────────
              const SizedBox(height: 20),
              Text('Pessoas na mesa',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _pessoas > 1
                            ? () {
                                setState(() => _pessoas--);
                                _salvarPessoasSelecionadas();
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline,
                            size: 30),
                        color: AppTheme.vermelho,
                      ),
                      const SizedBox(width: 20),
                      Text('$_pessoas',
                          style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.vermelho)),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: _pessoas < 10
                            ? () {
                                setState(() => _pessoas++);
                                _salvarPessoasSelecionadas();
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline, size: 30),
                        color: AppTheme.vermelho,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Termos ───────────────────────────────────────────
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _termos,
                onChanged: (v) => setState(() => _termos = v ?? false),
                activeColor: AppTheme.vermelho,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Li e aceito os termos de reserva.',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.marrom)),
              ),

              // ── Total ────────────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bege,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.dourado),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total estimado',
                        style: TextStyle(
                            color: AppTheme.marrom,
                            fontWeight: FontWeight.w500)),
                    Text('R\$ ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.vermelho)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Botão (animado) ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) {
                      return FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child),
                      );
                    },
                    child: _salvando
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            key: ValueKey('confirm'),
                            'Confirmar Reserva',
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Máscaras de input ────────────────────────────────────────────────────────

class _CpfMask extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll(RegExp(r'\D'), '');
    final b = StringBuffer();
    for (int i = 0; i < d.length && i < 11; i++) {
      if (i == 3 || i == 6) b.write('.');
      if (i == 9) b.write('-');
      b.write(d[i]);
    }
    final s = b.toString();
    return n.copyWith(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

class _FoneMask extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll(RegExp(r'\D'), '');
    final b = StringBuffer();
    for (int i = 0; i < d.length && i < 11; i++) {
      if (i == 0) b.write('(');
      if (i == 2) b.write(') ');
      if (i == 7) b.write('-');
      b.write(d[i]);
    }
    final s = b.toString();
    return n.copyWith(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}