import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart' as pg;

// --- Database Abstraction ---

abstract class DatabaseService {
  Future<void> init();
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);
  Future<int> insert(String table, Map<String, dynamic> values);
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  });
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});
  Future<void> execute(String sql, [List<Object?>? arguments]);
  Future<int> rawInsert(String sql, [List<Object?>? arguments]);
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]);
  Future<void> close();
}

class SqfliteService implements DatabaseService {
  Database? _db;
  final Future<void> Function(Database, int)? onCreate;
  final Future<void> Function(Database, int, int)? onUpgrade;
  final int version;
  final String path;

  SqfliteService({
    required this.path,
    required this.version,
    this.onCreate,
    this.onUpgrade,
  });

  @override
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, path);
    _db = await openDatabase(
      fullPath,
      version: version,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  Database get db {
    if (_db == null) throw Exception("Database not initialized");
    return _db!;
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return await db.rawQuery(sql, arguments);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) async {
    return await db.insert(table, values);
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    return await db.execute(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    return await db.rawInsert(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    return await db.rawUpdate(sql, arguments);
  }

  @override
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}

class PostgresService implements DatabaseService {
  pg.Connection? _conn;
  final String host;
  final int port;
  final String databaseName;
  final String username;
  final String password;

  PostgresService({
    required this.host,
    required this.port,
    required this.databaseName,
    required this.username,
    required this.password,
  });

  @override
  Future<void> init() async {
    _conn = await pg.Connection.open(
      pg.Endpoint(
        host: host,
        port: port,
        database: databaseName,
        username: username,
        password: password,
      ),
      settings: pg.ConnectionSettings(sslMode: pg.SslMode.disable),
    );
  }

  String _convertSql(String sql) {
    int index = 1;
    // Basic conversion from ? to $1, $2...
    // Note: This matches ? specifically.
    return sql.splitMapJoin(
      '?',
      onMatch: (m) => '\$${index++}',
      onNonMatch: (n) => n,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    String sql = 'SELECT ';
    if (distinct == true) sql += 'DISTINCT ';
    sql += (columns?.join(', ') ?? '*');
    sql += ' FROM $table';
    if (where != null) sql += ' WHERE $where';
    if (groupBy != null) sql += ' GROUP BY $groupBy';
    if (having != null) sql += ' HAVING $having';
    if (orderBy != null) sql += ' ORDER BY $orderBy';
    if (limit != null) sql += ' LIMIT $limit';
    if (offset != null) sql += ' OFFSET $offset';

    return await rawQuery(sql, whereArgs);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final finalSql = _convertSql(sql);
    debugPrint('Postgres Exec: $finalSql, Args: $arguments');
    try {
      final result = await _conn!.execute(
        pg.Sql(finalSql),
        parameters: arguments,
      );

      final List<Map<String, dynamic>> maps = [];
      for (final row in result) {
        maps.add(_PostgresMap(row.toColumnMap()));
      }
      debugPrint('Postgres Result Count: ${maps.length}');
      return maps;
    } catch (e) {
      debugPrint('Postgres Error: $e');
      rethrow;
    }
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) async {
    // Filter out id if null (to allow SERIAL auto-increment)
    final validValues = Map<String, dynamic>.from(values);
    if (validValues['id'] == null) {
      validValues.remove('id');
    }

    final columns = validValues.keys.join(', ');
    final placeholders = List.filled(validValues.length, '?').join(', ');
    final sql =
        'INSERT INTO $table ($columns) VALUES ($placeholders) RETURNING id'; // Postgres specific
    // Note: If table doesn't have 'id', this fails. Assuming all our tables have 'id'.

    // For now simple implementation
    try {
      final res = await rawQuery(sql, validValues.values.toList());
      if (res.isNotEmpty) {
        // rawQuery already returns _PostgresMap, so keys are case-insensitive
        if (res.first.containsKey('id')) {
          return res.first['id'] as int;
        }
      }
    } catch (e) {
      // Fallback if returning id fails or table structure differs
      final sqlNoReturn =
          'INSERT INTO $table ($columns) VALUES ($placeholders)';
      await rawQuery(sqlNoReturn, validValues.values.toList());
    }
    return 0;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final sets = values.keys.map((k) => '$k = ?').join(', ');
    final sql =
        'UPDATE $table SET $sets${where != null ? ' WHERE $where' : ''}';
    final args = [...values.values, ...(whereArgs ?? [])];
    return await rawUpdate(sql, args);
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final sql = 'DELETE FROM $table${where != null ? ' WHERE $where' : ''}';
    return await rawUpdate(sql, whereArgs); // rawUpdate returns affected rows
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    await _conn!.execute(pg.Sql(_convertSql(sql)), parameters: arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    // This assumes sql has RETURNING ID or similar if we want result.
    // Sqflite rawInsert returns ID.
    // If we just execute, we get result.
    final result = await _conn!.execute(
      pg.Sql(_convertSql(sql)),
      parameters: arguments,
    );
    if (result.isNotEmpty && result.first.toColumnMap().containsKey('id')) {
      return result.first[0] as int;
    }
    return 0;
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    final result = await _conn!.execute(
      pg.Sql(_convertSql(sql)),
      parameters: arguments,
    );
    return result.affectedRows;
  }

  @override
  Future<void> close() async {
    await _conn?.close();
    _conn = null;
  }
}

class _PostgresMap extends MapBase<String, dynamic> {
  final Map<String, dynamic> _source;
  final Map<String, String> _lowerKeys;

  _PostgresMap(this._source)
    : _lowerKeys = _source.map((k, v) => MapEntry(k.toLowerCase(), k));

  @override
  dynamic operator [](Object? key) {
    if (key is String) {
      final realKey = _lowerKeys[key.toLowerCase()];
      if (realKey != null) {
        final value = _source[realKey];
        if (value is bool) {
          return value ? 1 : 0;
        }
        return value;
      }
    }
    return null;
  }

  @override
  Iterable<String> get keys => _lowerKeys.values;

  @override
  void operator []=(String key, dynamic value) {
    _source[key] = value;
    _lowerKeys[key.toLowerCase()] = key;
  }

  @override
  void clear() {
    _source.clear();
    _lowerKeys.clear();
  }

  @override
  bool containsKey(Object? key) {
    if (key is String) {
      return _lowerKeys.containsKey(key.toLowerCase());
    }
    return false;
  }

  @override
  dynamic remove(Object? key) {
    if (key is String) {
      final realKey = _lowerKeys[key.toLowerCase()];
      if (realKey != null) {
        _lowerKeys.remove(key.toLowerCase());
        return _source.remove(realKey);
      }
    }
    return null;
  }
}
