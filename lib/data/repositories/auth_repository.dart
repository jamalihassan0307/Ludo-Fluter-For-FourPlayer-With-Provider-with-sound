import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/services/firebase_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        final userData = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();
            
        return UserModel.fromJson(userData.data() ?? {});
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<UserModel> signUpWithEmail(
    String email, 
    String password, 
    String name,
  ) async {
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user!;
    final userData = {
      'id': user.uid,
      'name': name,
      'email': email,
      'photoUrl': '',
      'gamesPlayed': 0,
      'gamesWon': 0,
    };

    await _firestore.collection('users').doc(user.uid).set(userData);
    return UserModel.fromJson(userData);
  }

  Future<UserModel> createUserFromGoogle(User user) async {
    final userData = {
      'id': user.uid,
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'gamesPlayed': 0,
      'gamesWon': 0,
    };

    await _firestore.collection('users').doc(user.uid).set(userData);
    return UserModel.fromJson(userData);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
} 