import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }
  
  static FirebaseAuth get auth => _auth;
  static FirebaseFirestore get firestore => _firestore;
} 