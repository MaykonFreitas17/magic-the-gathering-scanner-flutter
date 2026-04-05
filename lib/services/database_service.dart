import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/magic_card.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sol_lens.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // 1. Verifica se o banco já foi copiado para o aparelho
    final exists = await databaseExists(path);

    if (!exists) {
      debugPrint("Copiando o Grimório (Banco de Dados) dos assets...");

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      try {
        // 2. Tenta carregar o arquivo binário da pasta assets/db/
        ByteData data = await rootBundle.load(join('assets', 'db', filePath));
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        // 3. Escreve o arquivo na memória interna do celular
        await File(path).writeAsBytes(bytes, flush: true);
        debugPrint("Banco de dados copiado com sucesso!");
      } catch (e) {
        debugPrint(
          "Aviso: Arquivo sol_lens.db não encontrado nos assets. Criando um banco vazio de fallback. Erro: $e",
        );
        // Se o arquivo não existir nos assets, cria um banco vazio para o app não quebrar
        return await openDatabase(
          path,
          version: 1,
          onCreate: _createDBFallback,
        );
      }
    }

    // Abre e retorna o banco de dados (seja o copiado ou o que já estava lá)
    return await openDatabase(path);
  }

  // --- REDE DE SEGURANÇA (FALLBACK) ---
  // Só roda se o arquivo .db não for encontrado na pasta assets
  Future _createDBFallback(Database db, int version) async {
    await db.execute('''
      CREATE TABLE decks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        format TEXT NOT NULL,
        cover_image TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE deck_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id INTEGER NOT NULL,
        scryfall_id TEXT NOT NULL,
        name TEXT NOT NULL,
        image_url TEXT,
        mana_cost TEXT,
        type_line TEXT,
        quantity INTEGER NOT NULL,
        board_type TEXT NOT NULL DEFAULT 'main',
        FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- CRUD DE DECKS ---
  Future<int> createDeck(String name, String format) async {
    final db = await instance.database;
    return await db.insert('decks', {
      'name': name,
      'format': format.toLowerCase(),
      'cover_image': '',
    });
  }

  Future<int> updateDeck(int id, String name, String format) async {
    final db = await instance.database;
    return await db.update(
      'decks',
      {'name': name, 'format': format.toLowerCase()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllDecks() async {
    final db = await instance.database;
    return await db.query('decks', orderBy: 'id DESC');
  }

  Future<void> deleteDeck(int id) async {
    final db = await instance.database;
    await db.delete('decks', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD DE CARTAS ---
  Future<void> addCardToDeck(
    int deckId,
    MagicCard card,
    String format, {
    String boardType = 'main',
  }) async {
    final db = await instance.database;
    final existing = await db.query(
      'deck_cards',
      where: 'deck_id = ? AND scryfall_id = ? AND board_type = ?',
      whereArgs: [deckId, card.id, boardType],
    );

    if (existing.isNotEmpty) {
      final int currentQty = existing.first['quantity'] as int;
      int limit = (format.toLowerCase() == 'commander')
          ? 1
          : (format.toLowerCase() == 'mesa de cozinha' ? 999 : 4);
      bool isBasicLand = card.typeLine.toLowerCase().contains('basic land');

      if (isBasicLand || currentQty < limit) {
        await db.update(
          'deck_cards',
          {'quantity': currentQty + 1},
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      }
    } else {
      await db.insert('deck_cards', {
        'deck_id': deckId,
        'scryfall_id': card.id,
        'name': card.name,
        'image_url': card.imageUrl,
        'mana_cost': card.manaCost,
        'type_line': card.typeLine,
        'quantity': 1,
        'board_type': boardType,
      });

      // Se for a primeira carta do Main Deck, define como capa
      if (boardType == 'main') {
        await db.update(
          'decks',
          {'cover_image': card.imageUrl},
          where: 'id = ? AND (cover_image IS NULL OR cover_image = "")',
          whereArgs: [deckId],
        );
      }
    }
  }

  Future<void> updateCardQuantity(
    int rowId,
    int currentQty,
    int delta,
    int limit,
  ) async {
    final db = await instance.database;
    final newQty = currentQty + delta;
    if (newQty <= 0) {
      await db.delete('deck_cards', where: 'id = ?', whereArgs: [rowId]);
    } else if (newQty <= limit) {
      await db.update(
        'deck_cards',
        {'quantity': newQty},
        where: 'id = ?',
        whereArgs: [rowId],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getDeckCards(int deckId) async {
    final db = await instance.database;
    return await db.query(
      'deck_cards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );
  }

  // --- IDENTIDADE DE COR ---
  Future<List<String>> getDeckColors(int deckId) async {
    final db = await instance.database;
    // Pega as cores só do main deck pra formar a identidade
    final cards = await db.query(
      'deck_cards',
      columns: ['mana_cost'],
      where: 'deck_id = ? AND board_type = "main"',
      whereArgs: [deckId],
    );

    final Set<String> colors = {};
    final RegExp colorRegex = RegExp(r'\{([WUBRG])\}');

    for (var card in cards) {
      final cost = card['mana_cost'] as String?;
      if (cost != null) {
        for (var match in colorRegex.allMatches(cost)) {
          colors.add(match.group(1)!);
        }
      }
    }
    return colors.toList();
  }
}
