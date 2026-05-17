

import 'package:flutter/material.dart';
import '../models/banda.dart';
import '../utils/app_theme.dart';

class BandaCard extends StatefulWidget {
  final Banda banda;
  final VoidCallback? onVerDetalhes;

  const BandaCard({super.key, required this.banda, this.onVerDetalhes});

  @override
  State<BandaCard> createState() => _BandaCardState();
}

class _BandaCardState extends State<BandaCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => setState(() => _expandido = !_expandido),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Hero: a tag 'banda-avatar-${id}' conecta este avatar
                  // com o CircleAvatar maior em DetalheBandaScreen,
                  // criando animação de transição suave entre as telas.
                  Hero(
                    tag: 'banda-avatar-${widget.banda.id}',
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.vermelho,
                      child: Text(
                        widget.banda.nome[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.banda.nome,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.location_on,
                              size: 13, color: AppTheme.dourado),
                          const SizedBox(width: 4),
                          Text(widget.banda.origem,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[600])),
                        ]),
                        const SizedBox(height: 6),
                        // Wrap + Chip: exibe múltiplos gêneros sem transbordar
                        Wrap(
                          spacing: 5,
                          children: widget.banda.generos
                              .map((g) => Chip(
                                    label: Text(g.label,
                                        style: const TextStyle(fontSize: 11)),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  // AnimatedRotation: seta gira 180° ao expandir
                  AnimatedRotation(
                    turns: _expandido ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppTheme.dourado),
                  ),
                ],
              ),

              // AnimatedContainer: expande suavemente para mostrar a bio
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                height: _expandido ? null : 0,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Divider(color: AppTheme.dourado, thickness: 0.6),
                    const SizedBox(height: 8),
                    Text(widget.banda.bio,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.6)),
                    const SizedBox(height: 6),
                    Text('${widget.banda.anosCarreira} anos de carreira',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.dourado,
                            fontWeight: FontWeight.w500)),

                    // COMMIT [FUTURO]: exibir links de redes sociais aqui
                    // quando o campo redesSociais for adicionado ao model Banda

                    if (widget.onVerDetalhes != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: widget.onVerDetalhes,
                          icon: const Icon(Icons.open_in_new, size: 15),
                          label: const Text('Ver detalhes'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}