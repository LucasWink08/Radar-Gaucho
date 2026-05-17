
import 'package:flutter/material.dart';
import '../models/banda.dart';
import '../utils/app_theme.dart';

class DetalheBandaScreen extends StatelessWidget {
  final Banda banda;
  const DetalheBandaScreen({super.key, required this.banda});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(banda.nome, overflow: TextOverflow.ellipsis),
          bottom: const TabBar(
            labelColor: AppTheme.dourado,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppTheme.dourado,
            tabs: [
              Tab(text: 'Sobre'),
              Tab(text: 'Gêneros'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AbaInfo(banda: banda),
            _AbaGeneros(banda: banda),
          ],
        ),
      ),
    );
  }
}


class _AbaInfo extends StatelessWidget {
  final Banda banda;
  const _AbaInfo({required this.banda});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero: conecta ao CircleAvatar do BandaCard
          Center(
            child: Hero(
              tag: 'banda-avatar-${banda.id}',
              child: CircleAvatar(
                radius: 56,
                backgroundColor: AppTheme.vermelho,
                child: Text(
                  banda.nome[0],
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(banda.nome,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center),
          ),
          Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_on, size: 14, color: AppTheme.dourado),
              const SizedBox(width: 4),
              Text(banda.origem,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[600])),
            ]),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.dourado.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.dourado),
              ),
              child: Text(
                '${banda.anosCarreira} anos de carreira',
                style: const TextStyle(
                  color: AppTheme.marrom,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Sobre a banda', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(banda.bio,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7)),
        ],
      ),
    );
  }
}



class _AbaGeneros extends StatelessWidget {
  final Banda banda;
  const _AbaGeneros({required this.banda});

  // Simulação de "peso" de cada gênero na carreira da banda
  static const _pesos = {
    GeneroBanda.vanerao:   0.9,
    GeneroBanda.xote:      0.7,
    GeneroBanda.milonga:   0.85,
    GeneroBanda.nativismo: 0.75,
    GeneroBanda.chamame:   0.8,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estilos musicais', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Toque em cada gênero para ver o peso no repertório.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ...banda.generos.map((g) {
            final pct = _pesos[g] ?? 0.5;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(g.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.marrom)),
                      Text('${(pct * 100).toInt()}%',
                          style: const TextStyle(
                              color: AppTheme.dourado,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 12,
                      backgroundColor: AppTheme.bege,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.vermelho),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}