

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/evento.dart';
import '../models/reserva.dart';
import '../utils/app_theme.dart';

// COMMIT [FUTURO]: adicionar import do campo email no TextFormField
// e passar para o Reserva quando o campo for adicionado ao model

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

  // COMMIT [FUTURO]: adicionar _emailCtrl quando o campo email for adicionado ao model

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _foneCtrl.dispose();
    // COMMIT [FUTURO]: _emailCtrl.dispose();
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
    await Future.delayed(const Duration(milliseconds: 800));

    final reserva = Reserva(
      id:              'r${DateTime.now().millisecondsSinceEpoch}',
      eventoId:        widget.evento.id,
      nomeEvento:      widget.evento.nome,
      nomeResponsavel: _nomeCtrl.text.trim(),
      cpf:             _cpfCtrl.text.trim(),
      telefone:        _foneCtrl.text.trim(),
      numeroPessoas:   _pessoas,
      numeroMesa:      ReservaRepo.proximaMesa(widget.evento.id),
      criadaEm:        DateTime.now(),
      // COMMIT [FUTURO]: email: _emailCtrl.text.trim(),
    );

    ReservaRepo.salvar(reserva);
    setState(() => _salvando = false);
    if (!mounted) return;

    // COMMIT [FUTURO]: substituir SnackBar por navegação para uma
    // ConfirmacaoReservaScreen dedicada, passando a reserva como parâmetro
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppTheme.verdeEscuro,
      content: Text(
        '✓ Mesa ${reserva.numeroMesa} reservada! '
        'Código: ${reserva.id.substring(1, 9).toUpperCase()}',
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

              // ── Resumo do evento
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.vermelho.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppTheme.dourado.withOpacity(0.5)),
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

              // ── Nome 
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome completo *',
                    prefixIcon: Icon(Icons.person)),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o nome';
                  if (v.trim().split(' ').length < 2)
                    return 'Informe nome e sobrenome';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── CPF 
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
                  if (v.replaceAll(RegExp(r'\D'), '').length != 11)
                    return 'CPF inválido';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Telefone
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
                  if (v.replaceAll(RegExp(r'\D'), '').length < 10)
                    return 'Telefone inválido';
                  return null;
                },
              ),

              // COMMIT [FUTURO]: adicionar campo e-mail aqui
             

              // ── Contador de pessoas
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
                            ? () => setState(() => _pessoas--)
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
                            ? () => setState(() => _pessoas++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline, size: 30),
                        color: AppTheme.vermelho,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Termos 
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

              // ── Botão
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Confirmar Reserva'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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