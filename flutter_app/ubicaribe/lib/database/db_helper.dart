import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Importamos los moldes que acabamos de crear
import '../models/edificio.dart';
import '../models/departamento.dart';
import '../models/profesor.dart';
import '../models/notificacion.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "unicaribe.db");

    var exists = await databaseExists(path);

    if (!exists) {
      print("Primera vez: Copiando base de datos desde assets...");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load("assets/unicaribe.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path, readOnly: false);
  }

  // ==========================================================
  // 📌 MÉTODOS ACTUALIZADOS (Retornan Modelos)
  // ==========================================================

  // 1. Obtener todos los Edificios
  Future<List<Edificio>> obtenerEdificios() async {
    final db = await database;
    final List<Map<String, dynamic>> mapas = await db.query('edificios');
    
    // Convertimos la lista de mapas crudos a una lista de objetos Edificio
    return mapas.map((mapa) => Edificio.fromMap(mapa)).toList();
  }

  // 2. Obtener Departamentos de un Edificio
  Future<List<Departamento>> obtenerDepartamentosPorEdificio(int edificioId) async {
    final db = await database;
    final List<Map<String, dynamic>> mapas = await db.query(
      'departamentos',
      where: 'edificio_id = ?',
      whereArgs: [edificioId],
    );
    
    return mapas.map((mapa) => Departamento.fromMap(mapa)).toList();
  }

  // 3. Obtener Profesores de un Departamento
  Future<List<Profesor>> obtenerProfesoresPorDepartamento(int departamentoId) async {
    final db = await database;
    final List<Map<String, dynamic>> mapas = await db.query(
      'profesores',
      where: 'departamento_id = ?',
      whereArgs: [departamentoId],
    );
    
    return mapas.map((mapa) => Profesor.fromMap(mapa)).toList();
  }

  // 4. Obtener todos los Profesores de un Edificio (JOIN con departamentos)
  Future<List<Profesor>> obtenerProfesoresPorEdificio(int edificioId) async {
    final db = await database;
    final List<Map<String, dynamic>> mapas = await db.rawQuery(
      '''SELECT p.* FROM profesores p
         INNER JOIN departamentos d ON p.departamento_id = d.id
         WHERE d.edificio_id = ?''',
      [edificioId],
    );
    return mapas.map((mapa) => Profesor.fromMap(mapa)).toList();
  }

  // DEBUG: vuelca todas las tablas en consola para verificar datos
  Future<void> debugDump() async {
    final db = await database;
    print('=== DEBUG DUMP unicaribe.db ===');
    for (final tabla in ['edificios', 'departamentos', 'profesores', 'notificaciones']) {
      final rows = await db.query(tabla);
      print('--- $tabla (${rows.length} filas) ---');
      for (final r in rows) {
        print(r);
      }
    }
    print('=== FIN DEBUG DUMP ===');
  }

  // 5. Obtener Notificaciones
  Future<List<Notificacion>> obtenerNotificaciones() async {
    final db = await database;
    final List<Map<String, dynamic>> mapas = await db.query(
      'notificaciones',
      orderBy: 'created_at DESC', 
    );
    
    return mapas.map((mapa) => Notificacion.fromMap(mapa)).toList();
  }
}