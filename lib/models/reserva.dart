
// COMMIT [FUTURO]: adicionar campo 'email' para envio de comprovante
// final String email;

enum StatusReserva { confirmada, cancelada }

extension StatusReservaExt on StatusReserva {
  String get label => switch (this) {
    StatusReserva.confirmada => 'Confirmada',
    StatusReserva.cancelada  => 'Cancelada',
  };
}

class Reserva {
  final String id;
  final String eventoId;
  final String nomeEvento;      // salvo no ato para exibir sem precisar buscar o evento
  final String nomeResponsavel;
  final String cpf;
  final String telefone;
  final int numeroPessoas;
  final int numeroMesa;
  final DateTime criadaEm;
  final StatusReserva status;

  // COMMIT [FUTURO]: adicionar 'email' no construtor após adicionar o campo acima

  const Reserva({
    required this.id,
    required this.eventoId,
    required this.nomeEvento,
    required this.nomeResponsavel,
    required this.cpf,
    required this.telefone,
    required this.numeroPessoas,
    required this.numeroMesa,
    required this.criadaEm,
    this.status = StatusReserva.confirmada,
  });

  Reserva copyWith({StatusReserva? status}) => Reserva(
    id: id, eventoId: eventoId, nomeEvento: nomeEvento,
    nomeResponsavel: nomeResponsavel, cpf: cpf, telefone: telefone,
    numeroPessoas: numeroPessoas, numeroMesa: numeroMesa, criadaEm: criadaEm,
    status: status ?? this.status,
  );
}

class ReservaRepo {
  // COMMIT [FUTURO]: trocar lista em memória por SharedPreferences ou SQLite:
  // 1. Adicionar shared_preferences: ^2.2.2 no pubspec.yaml
  // 2. Substituir _lista por leitura/escrita no disco
  // 3. Tornar salvar() e todas async
  static final List<Reserva> _lista = [];

  static List<Reserva> get todas => List.unmodifiable(_lista);

  static void salvar(Reserva r) => _lista.add(r);

  static void cancelar(String id) {
    final i = _lista.indexWhere((r) => r.id == id);
    if (i >= 0) _lista[i] = _lista[i].copyWith(status: StatusReserva.cancelada);
  }

  static int proximaMesa(String eventoId) {
    final ocupadas = _lista
        .where((r) => r.eventoId == eventoId && r.status == StatusReserva.confirmada)
        .map((r) => r.numeroMesa)
        .toSet();
    int m = 1;
    while (ocupadas.contains(m)) m++;
    return m;
  }

  static int qtdReservasConfirmadas(String eventoId) {
    return _lista
        .where((r) => r.eventoId == eventoId && r.status == StatusReserva.confirmada)
        .length;
  }

  static int qtdReservasCanceladas(String eventoId) {
    return _lista
        .where((r) => r.eventoId == eventoId && r.status == StatusReserva.cancelada)
        .length;
  }
}