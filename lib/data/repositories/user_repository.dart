import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/services/firebase_service.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  Future<UserModel> createUser(String id, String email, String name) async {
    final userData = {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': '',
      'gamesPlayed': 0,
      'gamesWon': 0,
    };

    await _firestore.collection('users').doc(id).set(userData);
    return UserModel.fromJson(userData);
  }

  Future<UserModel?> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateStats(String userId, {bool won = false}) async {
    await _firestore.collection('users').doc(userId).update({
      'gamesPlayed': FieldValue.increment(1),
      if (won) 'gamesWon': FieldValue.increment(1),
    });
  }
} 