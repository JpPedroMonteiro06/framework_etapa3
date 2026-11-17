import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/filme.dart';

class FilmeService {
  static Database? _db;

  Future<Database> get banco async {
    _db ??= await _abrirBanco();
    return _db!;
  }

  Future<Database> _abrirBanco() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    return openDatabase(
      'filmes.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE filmes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            assistido INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> inserir(Filme filme) async {
    final db = await banco;
    final id = await db.insert('filmes', filme.toMap());
    print('INSERT -> ${filme.titulo} (id $id)');
    return id;
  }

  Future<List<Filme>> listar() async {
    final db = await banco;
    final resultado = await db.query('filmes', orderBy: 'id');
    print('SELECT -> ${resultado.length} filmes encontrados');
    return resultado.map((linha) => Filme.fromMap(linha)).toList();
  }

  Future<void> atualizarAssistido(Filme filme) async {
    final db = await banco;
    await db.update(
      'filmes',
      {'assistido': filme.assistido ? 1 : 0},
      where: 'id = ?',
      whereArgs: [filme.id],
    );
    print('UPDATE -> ${filme.titulo} assistido: ${filme.assistido}');
  }
}
