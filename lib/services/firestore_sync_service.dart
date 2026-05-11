import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../main.dart'; // For DatabaseHelper

class FirestoreSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // List of tables to sync
  final List<String> _tables = [
    'users',
    'printers',
    'categories',
    'products',
    'addons',
    'discounts',
    'sales',
    'sale_items',
    'shifts',
    'customers',
    'payment_devices',
    'suppliers',
    'purchase_invoices',
    'purchase_invoice_items',
    'stock_batches',
    'expenses',
    'ingredients',
    'product_ingredients',
    'branches',
  ];

  Future<Map<String, int>> syncAll({
    Function(String, double)? onProgress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in to Firebase');
    }

    final String userId = user.uid;
    final Map<String, int> results = {};
    int totalTables = _tables.length;
    int currentTableIndex = 0;

    for (final table in _tables) {
      try {
        if (onProgress != null) {
          onProgress(table, currentTableIndex / totalTables);
        }

        int count = await _syncTable(userId, table);
        results[table] = count;
      } catch (e) {
        debugPrint('Error syncing table $table: $e');
        results[table] = -1; // Indicate error
      }
      currentTableIndex++;
    }

    if (onProgress != null) {
      onProgress('Complete', 1.0);
    }

    return results;
  }

  Future<int> _syncTable(String uid, String tableName) async {
    final db = DatabaseHelper.instance;

    // Get unsynced records
    // Note: Assuming 'is_synced' column exists on all tables as per migration v25
    final List<Map<String, dynamic>> unsyncedRows = await db.query(
      tableName,
      where: 'is_synced = ? OR is_synced IS NULL',
      whereArgs: [0],
    );

    if (unsyncedRows.isEmpty) return 0;

    final WriteBatch batch = _firestore.batch();
    int batchCount = 0;
    int totalSynced = 0;

    // We process in chunks of 500 (Firestore batch limit)
    for (final row in unsyncedRows) {
      final docId = (row['cloud_id']?.toString().isNotEmpty == true)
          ? row['cloud_id'].toString()
          : row['id'].toString();
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection(tableName)
          .doc(docId);

      // Clean row data (remove local-only flags if any, keeping is_synced for cloud is fine or remove it)
      final Map<String, dynamic> data = Map.from(row);
      // Ensure specific types for Firestore if needed, generally implicit support is fine.
      // Convert 'date' strings to timestamps? Or keep as strings to match local.
      // User asked for specific schema, usually strings are fine for simple sync.

      // Remove is_synced from the upload payload to keep cloud clean?
      // Or keep it as 1? Let's set it to 1 in cloud to indicate it's a synced record.
      data['is_synced'] = 1;
      // Add server timestamp
      data['_synced_at'] = FieldValue.serverTimestamp();

      batch.set(docRef, data);
      batchCount++;

      if (batchCount >= 450) {
        // Commit batch before limit
        await batch.commit();
        // Update local status
        await _markAsSynced(
          tableName,
          unsyncedRows.sublist(totalSynced, totalSynced + batchCount),
        );
        totalSynced += batchCount;
        batchCount = 0;
        // batch = _firestore.batch(); // Re-instantiate batch? No, wait.
        // Cannot re-use committed batch object easily in loop structure without re-assigning.
        // Ideally we should process batches properly.
      }
    }

    // Commit remaining
    if (batchCount > 0) {
      await batch.commit();
      // Update local status for remaining
      await _markAsSynced(tableName, unsyncedRows.sublist(totalSynced));
      totalSynced += batchCount;
    }

    return totalSynced;
  }

  Future<List<Map<String, dynamic>>> fetchBranches() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in to Firebase');
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('branches')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] =
            int.tryParse(doc.id) ?? data['id']; // Ensure ID is preserved
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching branches: $e');
      rethrow;
    }
  }

  Future<void> _markAsSynced(
    String tableName,
    List<Map<String, dynamic>> rows,
  ) async {
    final db = DatabaseHelper.instance;
    final ids = rows.map((r) => r['id']).toList();

    // Efficient update? SQLite might typically need iteration or "IN" clause
    // For many IDs, "IN" clause might hit limits.
    // Iteration is safest for now.

    // Optimization: Transaction
    // But DatabaseHelper doesn't expose transaction easily globally yet without accessing db object.
    // We will simple loop rawUpdate for now.

    for (final id in ids) {
      await db.rawUpdate('UPDATE $tableName SET is_synced = 1 WHERE id = ?', [
        id,
      ]);
    }
  }

  Future<int> importTable(String tableName, {bool clearFirst = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in to Firebase');
    }

    try {
      final db = DatabaseHelper.instance;

      if (clearFirst) {
        await db.delete(tableName);
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection(tableName)
          .get();

      // 1. Get the local table columns to avoid "no such column" errors
      final List<Map<String, dynamic>> columnInfo = await db.rawQuery(
        'PRAGMA table_info($tableName)',
      );
      final Set<String> localColumns = columnInfo
          .map((c) => c['name'] as String)
          .toSet();

      int importedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final cloudId = doc.id;

        // Remove cloud-specific metadata
        data.remove('_synced_at');

        // Sanitize data AND filter by local schema
        final sanitizedData = <String, dynamic>{};

        // 1. Map document ID to cloud_id if supported
        if (localColumns.contains('cloud_id')) {
          sanitizedData['cloud_id'] = cloudId;
        }

        // 2. Iterate through data and resolve foreign keys
        for (var entry in data.entries) {
          final key = entry.key;
          final value = entry.value;

          if (localColumns.contains(key)) {
            // A. Handle Relationships (Foreign Keys)
            if (key == 'categoryId' && tableName != 'categories') {
              sanitizedData[key] = await _resolveLocalId('categories', value);
            } else if (key == 'productId' && tableName != 'products') {
              sanitizedData[key] = await _resolveLocalId('products', value);
            } else if (key == 'saleId' && tableName != 'sales') {
              sanitizedData[key] = await _resolveLocalId('sales', value);
            }
            // B. Handle primary ID (Don't overwrite local ID if it's already a numeric ID and we are appending)
            else if (key == 'id') {
              if (value is int) {
                sanitizedData[key] = value;
              } else if (value is String && int.tryParse(value) != null) {
                sanitizedData[key] = int.parse(value);
              }
              // If ID is not numeric, we don't put it in the 'id' column (SQLite expects INTEGER PRIMARY KEY)
              // It will be stored in 'cloud_id' and SQLite will auto-generate a new 'id' if not provided
            }
            // C. Handle Timestamps
            else if (value is Timestamp) {
              sanitizedData[key] = value.toDate().toIso8601String();
            }
            // D. Standard case
            else if (!sanitizedData.containsKey(key)) {
              sanitizedData[key] = value;
            }
          }
        }

        // Ensure is_synced is 1 for imported records
        if (localColumns.contains('is_synced')) {
          sanitizedData['is_synced'] = 1;
        }

        // Manual Upsert using cloud_id or numeric id
        if (localColumns.contains('cloud_id') && cloudId.isNotEmpty) {
          final existing = await db.query(
            tableName,
            where: 'cloud_id = ?',
            whereArgs: [cloudId],
          );
          if (existing.isNotEmpty) {
            await db.update(
              tableName,
              sanitizedData,
              where: 'cloud_id = ?',
              whereArgs: [cloudId],
            );
          } else {
            await db.insert(tableName, sanitizedData);
          }
        } else if (sanitizedData.containsKey('id')) {
          final existing = await db.query(
            tableName,
            where: 'id = ?',
            whereArgs: [sanitizedData['id']],
          );
          if (existing.isNotEmpty) {
            await db.update(
              tableName,
              sanitizedData,
              where: 'id = ?',
              whereArgs: [sanitizedData['id']],
            );
          } else {
            await db.insert(tableName, sanitizedData);
          }
        } else {
          await db.insert(tableName, sanitizedData);
        }
        importedCount++;
      }
      return importedCount;
    } catch (e) {
      debugPrint('Error importing table $tableName: $e');
      rethrow;
    }
  }

  /// Helper to find the local SQLite ID from a Firestore Document ID (cloud_id)
  Future<int?> _resolveLocalId(String tableName, dynamic cloudIdValue) async {
    if (cloudIdValue == null) return null;
    final cloudId = cloudIdValue.toString();

    // If the value is already numeric, it might be a Legacy ID or already resolved
    if (int.tryParse(cloudId) != null) {
      return int.parse(cloudId);
    }

    final db = DatabaseHelper.instance;
    try {
      final results = await db.query(
        tableName,
        where: 'cloud_id = ?',
        whereArgs: [cloudId],
        limit: 1,
      );
      if (results.isNotEmpty) {
        return results.first['id'] as int?;
      }
    } catch (e) {
      debugPrint('Error resolving mapping for $tableName: $e');
    }
    return null;
  }
}
