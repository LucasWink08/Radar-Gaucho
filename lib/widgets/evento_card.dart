
import 'package:flutter/material.dart';

import '../models/evento.dart';
import '../utils/app_theme.dart';

String formatData(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString().padLeft(4, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '$dd/$mm/$yyyy às $hh:$min';
}


class EventoCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback? onTap;
  final VoidCallback? onReservar;

  const EventoCard({
    super.key,
    required this.evento,
    this.onTap,
    this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    final fmtData = formatData(evento.data);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Faixa de cor no topo: verde quando tem mesa, cinza quando esgotado
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: evento.temMesa
                      ? [AppTheme.vermelho, AppTheme.dourado]
                      : [Colors.grey.shade400, Colors.grey.shade300],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(evento.nome,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      const SizedBox(width: 8),
                      _Badge(temMesa: evento.temMesa, qtd: evento.mesasDisponiveis),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InfoLinha(Icons.calendar_today, fmtData),
                  const SizedBox(height: 4),
                  _InfoLinha(Icons.location_on, '${evento.local} · ${evento.cidade}'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R\$ ${evento.preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold,
                          color: AppTheme.vermelho,
                        ),
                      ),
                      if (evento.temMesa && onReservar != null)
                        ElevatedButton.icon(
                          onPressed: onReservar,
                          icon: const Icon(Icons.table_restaurant, size: 16),
                          label: const Text('Reservar'),
                        )
                      else if (!evento.temMesa)
                        const Chip(
                          label: Text('Esgotado'),
                          backgroundColor: Color(0xFFE0E0E0),
                        ),
                    ],
                  ),

                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLinha extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _InfoLinha(this.icon, this.texto);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.dourado),
        const SizedBox(width: 6),
        Expanded(
          child: Text(texto,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final bool temMesa;
  final int qtd;
  const _Badge({required this.temMesa, required this.qtd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: temMesa ? AppTheme.verdeEscuro : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        temMesa ? '$qtd mesas' : 'Esgotado',
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}