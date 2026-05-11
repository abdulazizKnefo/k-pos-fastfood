import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:kpos/main.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  /// Fetch branches allowed for the user
  Future<List<String>> fetchBranches(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        if (data.containsKey('branches')) {
          return List<String>.from(data['branches']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching branches: $e');
      return [];
    }
  }

  /// Create a default branch for the user with unique ID
  Future<String> createDefaultBranch(String uid) async {
    try {
      final branchId = 'branch_${DateTime.now().millisecondsSinceEpoch}';
      await _firestore.collection('users').doc(uid).set({
        'branches': FieldValue.arrayUnion([branchId]),
      }, SetOptions(merge: true));

      // Also create the branch document
      await _firestore.collection('branches').doc(branchId).set({
        'name': 'Main Branch',
        'created_at': FieldValue.serverTimestamp(),
        'owner_uid': uid,
      });

      return branchId;
    } catch (e) {
      debugPrint('Error creating default branch: $e');
      rethrow;
    }
  }

  /// Check connectivity and start sync
  Future<void> syncData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      debugPrint('No internet connection. Skip sync.');
      return;
    }

    debugPrint('Starting data synchronization...');
    await uploadUnsyncedData();
  }

  /// Upload unsynced data from all relevant tables
  Future<void> uploadUnsyncedData() async {
    final uid = auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('No user logged in to Firebase. Skipping sync.');
      return;
    }

    final db = DatabaseHelper.instance;
    const int batchLimit = 400; // Firestore limit is 500

    // List of tables to sync
    final tables = [
      'categories',
      'products',
      'addons',
      'discounts',
      'sales',
      'shifts',
      'customers',
      'payment_devices',
      'suppliers',
      'purchase_invoices',
      'expenses',
      'ingredients',
      'users', // local staff users
    ];

    for (var table in tables) {
      final unsyncedRows = await db.query(table, where: 'is_synced = 0');

      if (unsyncedRows.isEmpty) continue;

      debugPrint('Found ${unsyncedRows.length} unsynced records in $table');

      final batch = _firestore.batch();
      int batchCount = 0;
      List<String> batchedIds = [];

      for (var row in unsyncedRows) {
        final docId = row['id']?.toString();
        if (docId == null) continue;

        // Base Path: users/{user_id}/{collection}/{doc_id}
        // Note: For staff users, they are in the 'users' table locally
        // but they sync to 'users/{owner_uid}/users/{staff_id}'
        final docRef = _firestore
            .collection('users')
            .doc(uid)
            .collection(table)
            .doc(docId);

        final dataToUpload = Map<String, dynamic>.from(row);
        dataToUpload.remove('is_synced');
        dataToUpload['uploaded_at'] = FieldValue.serverTimestamp();

        batch.set(docRef, dataToUpload, SetOptions(merge: true));
        batchedIds.add(docId);
        batchCount++;

        if (batchCount >= batchLimit) {
          await batch.commit();
          await _markAsSynced(db, table, batchedIds);
          batchCount = 0;
          batchedIds = [];
        }
      }

      if (batchCount > 0) {
        await batch.commit();
        await _markAsSynced(db, table, batchedIds);
        debugPrint('Batch for $table committed.');
      }
    }

    debugPrint('Sync completed.');
  }

  Future<void> _markAsSynced(
    DatabaseHelper db,
    String table,
    List<String> ids,
  ) async {
    for (var id in ids) {
      await db.update(
        table,
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}
