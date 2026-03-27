import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'troupeau_ovins.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (database, version) async {
        await _createTables(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute(
              "ALTER TABLE mouvements ADD COLUMN lot TEXT DEFAULT 'abdel_fidaoui'");
          await database.execute(
              "ALTER TABLE depenses ADD COLUMN lot TEXT DEFAULT 'abdel_fidaoui'");
          await database.execute(
              "ALTER TABLE revenus ADD COLUMN lot TEXT DEFAULT 'abdel_fidaoui'");
        }
      },
    );
  }

  Future<void> _createTables(Database database) async {
    await database.execute('''
      CREATE TABLE mouvements (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        qte INTEGER NOT NULL,
        date TEXT NOT NULL,
        remarque TEXT DEFAULT '',
        lot TEXT DEFAULT 'abdel_fidaoui'
      )
    ''');

    await database.execute('''
      CREATE TABLE depenses (
        id TEXT PRIMARY KEY,
        montant REAL NOT NULL,
        date TEXT NOT NULL,
        categorie TEXT NOT NULL,
        remarque TEXT DEFAULT '',
        lot TEXT DEFAULT 'abdel_fidaoui'
      )
    ''');

    await database.execute('''
      CREATE TABLE revenus (
        id TEXT PRIMARY KEY,
        montant REAL NOT NULL,
        date TEXT NOT NULL,
        categorie TEXT NOT NULL,
        remarque TEXT DEFAULT '',
        lot TEXT DEFAULT 'abdel_fidaoui'
      )
    ''');
  }

  Future<bool> isEmpty() async {
    final database = await db;
    final count = Sqflite.firstIntValue(
          await database.rawQuery('SELECT COUNT(*) FROM mouvements'),
        ) ??
        0;
    return count == 0;
  }

  Future<void> insertAll({
    required List<Mouvement> mouvements,
    required List<Depense> depenses,
    required List<Revenu> revenus,
  }) async {
    final database = await db;
    final batch = database.batch();
    for (final m in mouvements) {
      batch.insert('mouvements', m.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final d in depenses) {
      batch.insert('depenses', d.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final r in revenus) {
      batch.insert('revenus', r.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Mouvement>> getMouvements() async {
    final database = await db;
    final rows = await database.query('mouvements', orderBy: 'date ASC');
    return rows.map(Mouvement.fromMap).toList();
  }

  Future<void> insertMouvement(Mouvement mouvement) async {
    final database = await db;
    await database.insert(
      'mouvements',
      mouvement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMouvement(String id) async {
    final database = await db;
    await database.delete('mouvements', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Depense>> getDepenses() async {
    final database = await db;
    final rows = await database.query('depenses', orderBy: 'date DESC');
    return rows.map(Depense.fromMap).toList();
  }

  Future<void> insertDepense(Depense depense) async {
    final database = await db;
    await database.insert(
      'depenses',
      depense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDepense(String id) async {
    final database = await db;
    await database.delete('depenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Revenu>> getRevenus() async {
    final database = await db;
    final rows = await database.query('revenus', orderBy: 'date DESC');
    return rows.map(Revenu.fromMap).toList();
  }

  Future<void> insertRevenu(Revenu revenu) async {
    final database = await db;
    await database.insert(
      'revenus',
      revenu.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRevenu(String id) async {
    final database = await db;
    await database.delete('revenus', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final database = await db;
    await database.delete('mouvements');
    await database.delete('depenses');
    await database.delete('revenus');
  }
}
