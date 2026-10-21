

import '../models/reserva.dart';
import 'database_helper.dart';

class ReservaRepo {
  static final _db = DatabaseHelper.instance;

  static Future<List<Reserva>> todas() => _db.retrieveReservas();

  static Future<List<Reserva>> doUsuario(int userId) =>
      _db.retrieveReservasByUser(userId);


  static Future<int> salvar(Reserva reserva) => _db.insertReserva(reserva);


  static Future<void> cancelar(int id) => _db.cancelarReserva(id);

 
  static Future<void> excluir(int id) => _db.deleteReserva(id);

  static Future<int> proximaMesa(String eventoId) =>
      _db.proximaMesaDisponivel(eventoId);

 
  static Future<int> qtdReservasConfirmadas(String eventoId) =>
      _db.contarReservasConfirmadas(eventoId);
}
