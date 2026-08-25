import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/reserva.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;
  static const _webUsersKey = 'radar_gaucho_users';
  static const _webReservasKey = 'radar_gaucho_reservas';

  Future<SharedPreferences> get _webPrefs => SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _readWebList(String key) async {
    final prefs = await _webPrefs;
    final value = prefs.getString(key);
    if (value == null) return [];
    return (jsonDecode(value) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> _writeWebList(
    String key,
    List<Map<String, dynamic>> values,
  ) async {
    final prefs = await _webPrefs;
    await prefs.setString(key, jsonEncode(values));
  }

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'radar_gaucho.db'),
  
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute(
          '''CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              name TEXT NOT NULL,
              email TEXT UNIQUE NOT NULL, 
              password TEXT NOT NULL)''',
        );

        await database.execute(
          '''CREATE TABLE reservas(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              codigo TEXT NOT NULL,
              evento_id TEXT NOT NULL,
              nome_evento TEXT NOT NULL,
              nome_responsavel TEXT NOT NULL,
              cpf TEXT NOT NULL,
              telefone TEXT NOT NULL,
              numero_pessoas INTEGER NOT NULL,
              numero_mesa INTEGER NOT NULL,
              criada_em TEXT NOT NULL,
              status TEXT NOT NULL,
              FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)''',
        );
      },
      version: 1,
    );
  }

  Future<Database> get database async {
    _database ??= await initializeDB();
    return _database!;
  }

  Future<void> ensureInitialized() async {
    if (kIsWeb) return;
    await database.timeout(const Duration(seconds: 15));
  }

  Future<int> insertUser(User user) async {
    if (kIsWeb) {
      final users = await _readWebList(_webUsersKey);
      final id = users.isEmpty
          ? 1
          : (users.map((item) => item['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
      users.add(user.copyWith(id: id).toMap());
      await _writeWebList(_webUsersKey, users);
      return id;
    }
    final Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> retrieveUsers() async {
    if (kIsWeb) {
      final users = await _readWebList(_webUsersKey);
      return users.map(User.fromMap).toList();
    }
    final Database db = await database;
    final List<Map<String, Object?>> queryResult = await db.query('users');
    return queryResult.map((e) => User.fromMap(e)).toList();
  }

  Future<List<User>> getUsers() async {
    return retrieveUsers();
  }

  Future<User?> getUserById(int id) async {
    if (kIsWeb) {
      final users = await retrieveUsers();
      for (final user in users) {
        if (user.id == id) return user;
      }
      return null;
    }
    final db = await database;
    final resultado =
        await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (resultado.isEmpty) return null;
    return User.fromMap(resultado.first);
  }

  Future<User?> loginUser(String email, String password) async {
    if (kIsWeb) {
      final users = await retrieveUsers();
      for (final user in users) {
        if (user.email == email && user.password == password) return user;
      }
      return null;
    }
    final db = await database;
    final resultado = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (resultado.isEmpty) return null;
    return User.fromMap(resultado.first);
  }

  Future<int> updateUser(User user) async {
    if (kIsWeb) {
      final users = await _readWebList(_webUsersKey);
      final index = users.indexWhere((item) => item['id'] == user.id);
      if (index == -1) return 0;
      users[index] = user.toMap();
      await _writeWebList(_webUsersKey, users);
      return 1;
    }
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(int id) async {
    if (kIsWeb) {
      final users = await _readWebList(_webUsersKey);
      users.removeWhere((item) => item['id'] == id);
      await _writeWebList(_webUsersKey, users);
      final reservas = await _readWebList(_webReservasKey);
      reservas.removeWhere((item) => item['user_id'] == id);
      await _writeWebList(_webReservasKey, reservas);
      return;
    }
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  // CREATE
  Future<int> insertReserva(Reserva reserva) async {
    if (kIsWeb) {
      final reservas = await _readWebList(_webReservasKey);
      final id = reservas.isEmpty
          ? 1
          : (reservas.map((item) => item['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
      reservas.add(reserva.copyWith().toMap()..['id'] = id);
      await _writeWebList(_webReservasKey, reservas);
      return id;
    }
    final db = await database;
    return await db.insert('reservas', reserva.toMap());
  }

  // READ — todas as reservas (usado no dashboard de status, que é global)
  Future<List<Reserva>> retrieveReservas() async {
    if (kIsWeb) {
      final reservas = await _readWebList(_webReservasKey);
      reservas.sort((a, b) => (b['criada_em'] as String).compareTo(a['criada_em'] as String));
      return reservas.map(Reserva.fromMap).toList();
    }
    final db = await database;
    final result = await db.query('reservas', orderBy: 'criada_em DESC');
    return result.map((e) => Reserva.fromMap(e)).toList();
  }

  // READ — apenas as reservas do usuário logado ("Minhas Reservas")
  Future<List<Reserva>> retrieveReservasByUser(int userId) async {
    if (kIsWeb) {
      final reservas = await retrieveReservas();
      return reservas.where((reserva) => reserva.userId == userId).toList();
    }
    final db = await database;
    final result = await db.query(
      'reservas',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'criada_em DESC',
    );
    return result.map((e) => Reserva.fromMap(e)).toList();
  }

  // UPDATE — atualização genérica (aceita mudanças em qualquer campo)
  Future<int> updateReserva(Reserva reserva) async {
    if (kIsWeb) {
      final reservas = await _readWebList(_webReservasKey);
      final index = reservas.indexWhere((item) => item['id'] == reserva.id);
      if (index == -1) return 0;
      reservas[index] = reserva.toMap()..['id'] = reserva.id;
      await _writeWebList(_webReservasKey, reservas);
      return 1;
    }
    final db = await database;
    return await db.update(
      'reservas',
      reserva.toMap(),
      where: 'id = ?',
      whereArgs: [reserva.id],
    );
  }

  // UPDATE — atalho específico para cancelar (só troca o status)
  Future<void> cancelarReserva(int id) async {
    if (kIsWeb) {
      final reservas = await _readWebList(_webReservasKey);
      final index = reservas.indexWhere((item) => item['id'] == id);
      if (index != -1) reservas[index]['status'] = 'cancelada';
      await _writeWebList(_webReservasKey, reservas);
      return;
    }
    final db = await database;
    await db.update(
      'reservas',
      {'status': 'cancelada'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE — remove a reserva permanentemente (diferente de cancelar)
  Future<void> deleteReserva(int id) async {
    if (kIsWeb) {
      final reservas = await _readWebList(_webReservasKey);
      reservas.removeWhere((item) => item['id'] == id);
      await _writeWebList(_webReservasKey, reservas);
      return;
    }
    final db = await database;
    await db.delete('reservas', where: 'id = ?', whereArgs: [id]);
  }

  // Próxima mesa livre para um evento (consulta apenas reservas confirmadas)
  Future<int> proximaMesaDisponivel(String eventoId) async {
    if (kIsWeb) {
      final reservas = await retrieveReservas();
      final ocupadas = reservas
          .where((reserva) => reserva.eventoId == eventoId && reserva.status == StatusReserva.confirmada)
          .map((reserva) => reserva.numeroMesa)
          .toSet();
      int mesa = 1;
      while (ocupadas.contains(mesa)) {
        mesa++;
      }
      return mesa;
    }
    final db = await database;
    final result = await db.query(
      'reservas',
      columns: ['numero_mesa'],
      where: 'evento_id = ? AND status = ?',
      whereArgs: [eventoId, 'confirmada'],
    );
    final ocupadas = result.map((e) => e['numero_mesa'] as int).toSet();
    int m = 1;
    while (ocupadas.contains(m)) {
      m++;
    }
    return m;
  }

  // Contagem de reservas confirmadas de um evento (usado para calcular
  // quantas mesas ainda estão disponíveis na aba "Eventos")
  Future<int> contarReservasConfirmadas(String eventoId) async {
    if (kIsWeb) {
      final reservas = await retrieveReservas();
      return reservas
          .where((reserva) => reserva.eventoId == eventoId && reserva.status == StatusReserva.confirmada)
          .length;
    }
    final db = await database;
    final result = await db.query(
      'reservas',
      where: 'evento_id = ? AND status = ?',
      whereArgs: [eventoId, 'confirmada'],
    );
    return result.length;
  }
}
