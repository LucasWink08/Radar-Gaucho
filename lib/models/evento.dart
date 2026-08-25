// ═══════════════════════════════════════════════════════════════════
//  lib/models/evento.dart
//  COMMIT 3 — Criado aqui. Sem imports internos.
//  bandasIds é List<String> — NÃO importa banda.dart.
// ═══════════════════════════════════════════════════════════════════

// TODO [FUTURO]: adicionar campo 'imagemUrl' para exibir banner do evento
// final String imagemUrl;

// TODO [FUTURO]: adicionar campo 'endereco' com CEP para integrar mapa

class Evento {
  final String id;
  final String nome;
  final String descricao;
  final DateTime data;
  final String local;
  final String cidade;
  final double preco;
  final int totalMesas;
  final int mesasDisponiveis;
  final List<String> bandasIds; // IDs das bandas — buscar em BandasMock.porId()

  // TODO [FUTURO]: adicionar imagemUrl e endereco aqui

  const Evento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.data,
    required this.local,
    required this.cidade,
    required this.preco,
    required this.totalMesas,
    required this.mesasDisponiveis,
    required this.bandasIds,
  });

  bool get temMesa => mesasDisponiveis > 0;

  // TODO [FUTURO]: adicionar copyWith para atualizar mesasDisponiveis
  // após uma reserva ser confirmada em tempo real
}

class EventosMock {
  // TODO [FUTURO]: substituir por chamada à API:
  // static Future<List<Evento>> fetchEventos() async { ... }
  static final lista = [
    Evento(
      id: 'e1', nome: 'Noite do Vanerão',
      descricao: 'A maior noite de vanerão do Vale do Itajaí. Venha dançar com a família!',
      data: DateTime(2025, 8, 16, 20, 0),
      local: 'CTG Querência do Sul', cidade: 'Ituporanga - SC',
      preco: 45.00, totalMesas: 20, mesasDisponiveis: 7,
      bandasIds: ['b1', 'b2'],
    ),
    Evento(
      id: 'e2', nome: 'Baile de São João',
      descricao: 'Celebre o São João com música nativa, churrasco e chimarrão.',
      data: DateTime(2025, 6, 24, 19, 0),
      local: 'Salão Farroupilha', cidade: 'Blumenau - SC',
      preco: 60.00, totalMesas: 30, mesasDisponiveis: 0,
      bandasIds: ['b3'],
    ),
    Evento(
      id: 'e3', nome: 'Rodeio & Baile',
      descricao: 'Três dias de rodeio e baile com as maiores atrações do sul.',
      data: DateTime(2025, 10, 4, 18, 0),
      local: 'Arena Pinheiro', cidade: 'Lages - SC',
      preco: 80.00, totalMesas: 50, mesasDisponiveis: 22,
      bandasIds: ['b1', 'b3', 'b4'],
    ),
    Evento(
      id: 'e4', nome: 'Serenatinha Gaúcha',
      descricao: 'Evento intimista com músicos locais. Ideal para casais.',
      data: DateTime(2025, 7, 12, 19, 30),
      local: 'Pousada Araucária', cidade: 'Ituporanga - SC',
      preco: 25.00, totalMesas: 10, mesasDisponiveis: 3,
      bandasIds: ['b2'],
    ),
  ];
}