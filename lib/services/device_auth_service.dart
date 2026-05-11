import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _registerOrUpdateDevice(credential.user!);
      }

      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password (optional, if you want new admins to sign up)
  Future<User?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _registerOrUpdateDevice(credential.user!);
      }

      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Register device in Firestore
  Future<void> _registerOrUpdateDevice(User user) async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = 'unknown';
    String deviceName = 'unknown';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        deviceName = iosInfo.name;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
        deviceName = windowsInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceId = linuxInfo.machineId ?? 'unknown';
        deviceName = linuxInfo.name;
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        deviceId = macInfo.systemGUID ?? 'unknown';
        deviceName = macInfo.computerName;
      }
    } catch (e) {
      print('Error getting device info: $e');
    }

    final userDoc = _firestore.collection('users').doc(user.uid);

    // Use set with merge to update or create
    await userDoc.set({
      'email': user.email,
      'last_login': FieldValue.serverTimestamp(),
      'devices': FieldValue.arrayUnion([
        {
          'device_id': deviceId,
          'device_name': deviceName,
          'last_active': DateTime.now().toIso8601String(),
        },
      ]),
      // Default subscription if not exists
      'subscription_type': 'basic', // You can change logic to check existing
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
