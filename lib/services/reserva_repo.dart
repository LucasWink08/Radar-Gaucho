// ═══════════════════════════════════════════════════════════════════
//  lib/services/reserva_repo.dart
//  Repositório de reservas: camada fina entre as telas e o
//  DatabaseHelper (DAO). Substitui a antiga lista em memória por
//  chamadas assíncronas ao SQLite.
//  Depende: models/reserva.dart, services/database_helper.dart
// ═══════════════════════════════════════════════════════════════════

import '../models/reserva.dart';
import 'database_helper.dart';

class ReservaRepo {
  static final _db = DatabaseHelper.instance;

  /// Todas as reservas de todos os usuários (usado no dashboard "Status").
  static Future<List<Reserva>> todas() => _db.retrieveReservas();

  /// Apenas as reservas do usuário informado ("Minhas Reservas").
  static Future<List<Reserva>> doUsuario(int userId) =>
      _db.retrieveReservasByUser(userId);

  /// Cria uma nova reserva. Retorna o id gerado pelo SQLite.
  static Future<int> salvar(Reserva reserva) => _db.insertReserva(reserva);

  /// Cancela (Update de status — a reserva continua existindo).
  static Future<void> cancelar(int id) => _db.cancelarReserva(id);

  /// Exclui a reserva definitivamente (Delete).
  static Future<void> excluir(int id) => _db.deleteReserva(id);

  /// Próximo número de mesa livre para o evento informado.
  static Future<int> proximaMesa(String eventoId) =>
      _db.proximaMesaDisponivel(eventoId);

  /// Quantas reservas confirmadas um evento já tem.
  static Future<int> qtdReservasConfirmadas(String eventoId) =>
      _db.contarReservasConfirmadas(eventoId);
}
