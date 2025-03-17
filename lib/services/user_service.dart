import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user data from Firestore
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user's last login
  static Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': DateTime.now(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Update user stats
  static Future<void> updateUserStats(
    String userId, {
    int? gamesPlayed,
    int? gamesWon,
    int? totalScore,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (gamesPlayed != null) updates['stats.gamesPlayed'] = FieldValue.increment(1);
      if (gamesWon != null) updates['stats.gamesWon'] = FieldValue.increment(1);
      if (totalScore != null) updates['stats.totalScore'] = FieldValue.increment(totalScore);

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  // Check if user exists
  static Future<bool> checkUserExists(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // Get stored credentials
  static Future<Map<String, dynamic>?> getStoredCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final isGoogleSignIn = prefs.getBool('isGoogleSignIn') ?? false;

      if (userId != null && isLoggedIn) {
        return {
          'userId': userId,
          'isGoogleSignIn': isGoogleSignIn,
          'email': prefs.getString('userEmail'),
          'password': prefs.getString('userPassword'),
        };
      }
      return null;
    } catch (e) {
      print('Error getting stored credentials: $e');
      return null;
    }
  }

  // Clear stored credentials
  static Future<void> clearStoredCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing stored credentials: $e');
    }
  }
}
