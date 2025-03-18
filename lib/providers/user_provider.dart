import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/offline_user.dart';

class UserProvider extends ChangeNotifier {
  dynamic _user;
  bool _isLoading = false;
  bool _isOfflineUser = false;

  dynamic get user => _user;
  bool get isLoading => _isLoading;
  bool get isOfflineUser => _isOfflineUser;

  void setOfflineUser(OfflineUser user) {
    _user = user;
    _isOfflineUser = true;
    notifyListeners();
  }

  Future<void> setUser(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        _user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error setting user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserLastLogin() async {
    try {
      if (_user != null) {
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
          'lastLogin': DateTime.now(),
        });
      }
    } catch (e) {
      print("Error updating last login: $e");
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _user = null;
      notifyListeners();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  bool get isLoggedIn => _user != null;

  Future<void> updateUserSettings(String key, bool value) async {
    try {
      if (_user != null) {
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
          'settings.$key': value,
        });

        // Refresh user data
        await setUser(_user!.uid);
      }
    } catch (e) {
      print("Error updating settings: $e");
    }
  }
}
