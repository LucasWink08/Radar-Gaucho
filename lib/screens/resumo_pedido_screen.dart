import 'package:flutter/material.dart';

import '../models/evento.dart';
import '../utils/app_theme.dart';

class ResumoPedidoScreen extends StatefulWidget {
  final Evento evento;
  final int pessoas;

  const ResumoPedidoScreen({super.key, required this.evento, required this.pessoas});

  @override
  State<ResumoPedidoScreen> createState() => _ResumoPedidoScreenState();
}

class _ResumoPedidoScreenState extends State<ResumoPedidoScreen> {
  late final ValueNotifier<double> _totalAtual;

  @override
  void initState() {
    super.initState();
    _totalAtual = ValueNotifier<double>(0);

    // Animação simples do valor total: 0 -> total calculado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final total = widget.evento.preco * widget.pessoas;
      _totalAtual.value = total;
    });
  }

  @override
  void dispose() {
    _totalAtual.dispose();
    super.dispose();
  }

  double get _total => widget.evento.preco * widget.pessoas;

  double get _taxaServico => (_total * 0.08).clamp(0, double.infinity);
  double get _desconto => (widget.pessoas >= 6 ? _total * 0.05 : 0);
  double get _subtotal => _total - _desconto;
  double get _totalFinal => _subtotal + _taxaServico;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo do Pedido'),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com gradiente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.verdeEscuro, AppTheme.marrom],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.evento.nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.pessoas} pessoa(s) · R\$ ${widget.evento.preco.toStringAsFixed(2)}/pessoa',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card de totais
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _RowValor(label: 'Total', valor: 'R\$ ${widget.pessoas == 0 ? 0 : widget.evento.preco.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    // Total animado com TweenAnimationBuilder
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _total),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return _ValorGrande(
                          label: 'Total (calculado)',
                          valor: 'R\$ ${value.toStringAsFixed(2)}',
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _DividerDourado(),
                    const SizedBox(height: 10),
                    _RowValor(label: 'Desconto', valor: '- R\$ ${_desconto.toStringAsFixed(2)}', valorCor: AppTheme.vermelho),
                    const SizedBox(height: 6),
                    _RowValor(label: 'Taxa (8%)', valor: '+ R\$ ${_taxaServico.toStringAsFixed(2)}', valorCor: AppTheme.dourado),
                    const SizedBox(height: 6),
                    _DividerDourado(),
                    const SizedBox(height: 10),
                    _ValorGrande(label: 'Total final', valor: 'R\$ ${_totalFinal.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mensagem
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bege,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dourado.withValues(alpha: 0.8)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.local_offer_outlined, color: AppTheme.vermelho),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.pessoas >= 6
                          ? 'Desconto aplicado automaticamente para grupos com 6+ pessoas.'
                          : 'Sem desconto para este grupo. Experimente aumentar o número de pessoas! ',
                      style: TextStyle(color: AppTheme.marrom.withValues(alpha: 0.95)),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vermelho,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar e voltar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowValor extends StatelessWidget {
  final String label;
  final String valor;
  final Color valorCor;

  const _RowValor({required this.label, required this.valor, this.valorCor = AppTheme.marrom});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppTheme.marrom.withValues(alpha: 0.95), fontWeight: FontWeight.w600)),
        Text(valor, style: TextStyle(color: valorCor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _DividerDourado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppTheme.dourado.withValues(alpha: 0.9),
      thickness: 1,
    );
  }
}

class _ValorGrande extends StatelessWidget {
  final String label;
  final String valor;

  const _ValorGrande({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.marrom.withValues(alpha: 0.95), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.vermelho,
          ),
        ),
      ],
    );
  }
}

