enum StatusReserva { confirmada, cancelada }

extension StatusReservaExt on StatusReserva {
  String get label => switch (this) {
    StatusReserva.confirmada => 'Confirmada',
    StatusReserva.cancelada  => 'Cancelada',
  };
}

class Reserva {
  final int? id;
  final int userId;
  final String codigo;
  final String eventoId;
  final String nomeEvento;
  final String nomeResponsavel;
  final String cpf;
  final String telefone;
  final int numeroPessoas;
  final int numeroMesa;
  final DateTime criadaEm;
  final StatusReserva status;

  const Reserva({
    this.id,
    required this.userId,
    required this.codigo,
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

  factory Reserva.fromMap(Map<String, dynamic> map) {
    return Reserva(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      codigo: map['codigo'] as String,
      eventoId: map['evento_id'] as String,
      nomeEvento: map['nome_evento'] as String,
      nomeResponsavel: map['nome_responsavel'] as String,
      cpf: map['cpf'] as String,
      telefone: map['telefone'] as String,
      numeroPessoas: map['numero_pessoas'] as int,
      numeroMesa: map['numero_mesa'] as int,
      criadaEm: DateTime.parse(map['criada_em'] as String),
      status: (map['status'] as String) == 'cancelada'
          ? StatusReserva.cancelada
          : StatusReserva.confirmada,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'codigo': codigo,
      'evento_id': eventoId,
      'nome_evento': nomeEvento,
      'nome_responsavel': nomeResponsavel,
      'cpf': cpf,
      'telefone': telefone,
      'numero_pessoas': numeroPessoas,
      'numero_mesa': numeroMesa,
      'criada_em': criadaEm.toIso8601String(),
      'status': status == StatusReserva.cancelada ? 'cancelada' : 'confirmada',
    };
    if (id != null) map['id'] = id;
    return map;
  }

  Reserva copyWith({StatusReserva? status}) => Reserva(
    id: id, userId: userId, codigo: codigo, eventoId: eventoId,
    nomeEvento: nomeEvento, nomeResponsavel: nomeResponsavel, cpf: cpf,
    telefone: telefone, numeroPessoas: numeroPessoas, numeroMesa: numeroMesa,
    criadaEm: criadaEm, status: status ?? this.status,
  );
}
