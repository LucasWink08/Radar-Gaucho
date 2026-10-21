import 'package:flutter/material.dart';

import '../models/reserva.dart';
import '../services/reserva_repo.dart';
import '../utils/app_theme.dart';

class StatusReservasScreen extends StatefulWidget {
  const StatusReservasScreen({super.key});

  @override
  State<StatusReservasScreen> createState() => _StatusReservasScreenState();
}

class _StatusReservasScreenState extends State<StatusReservasScreen> {
  List<Reserva> _reservas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final reservas = await ReservaRepo.todas();
    if (!mounted) return;
    setState(() {
      _reservas = reservas;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservas = _reservas;

 
    final confirmadas = reservas.where((r) => r.status == StatusReserva.confirmada).length;
    final canceladas = reservas.where((r) => r.status == StatusReserva.cancelada).length;
    final total = reservas.length;

    final double percentConfirmadas = total == 0 ? 0 : confirmadas / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status das Reservas'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _carregando
            ? const Center(
                key: ValueKey('loading'),
                child: CircularProgressIndicator(color: AppTheme.vermelho),
              )
            : total == 0
            ? Center(
                key: const ValueKey('empty'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_empty_outlined, size: 72, color: AppTheme.dourado),
                    const SizedBox(height: 12),
                    const Text('Nenhuma reserva ainda.',
                        style: TextStyle(fontSize: 16, color: AppTheme.marrom)),
                    const SizedBox(height: 4),
                    Text('Faça uma reserva em “Eventos” para ver o status aqui.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              )
            : Padding(
                key: const ValueKey('list'),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Resumo',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),

                            AnimatedContainer(
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeInOut,
                              height: 14,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.bege,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.dourado.withValues(alpha: 0.8)),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: percentConfirmadas,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.verdeEscuro, AppTheme.dourado],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Confirmadas: $confirmadas',
                                    style: const TextStyle(color: AppTheme.verdeEscuro, fontWeight: FontWeight.bold)),
                                Text('Canceladas: $canceladas',
                                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: AnimatedList(
                        key: const ValueKey('anim-list'),
                        initialItemCount: reservas.length,
                        itemBuilder: (context, index, animation) {
                          final r = reservas[index];
                          return FadeTransition(
                            opacity: animation,
                            child: _ReservaTile(reserva: r),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.dourado, width: 1.3),
                          foregroundColor: AppTheme.marrom,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        label: const Text('Voltar'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ReservaTile extends StatelessWidget {
  final Reserva reserva;

  const _ReservaTile({required this.reserva});

  String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString().padLeft(4, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    final cancelada = reserva.status == StatusReserva.cancelada;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cancelada ? Colors.grey : AppTheme.vermelho,
          child: Text(
            '${reserva.numeroMesa}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          reserva.nomeEvento,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.marrom),
        ),
        subtitle: Text(
          '${reserva.nomeResponsavel} · ${reserva.numeroPessoas} pessoa(s)\n${_fmt(reserva.criadaEm)}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Chip(
          label: Text(
            cancelada ? 'Cancelada' : 'Confirmada',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          backgroundColor: cancelada ? Colors.grey : AppTheme.dourado,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

