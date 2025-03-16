import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';
import '../../core/services/firebase_service.dart';

class GameRepository {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  Future<GameModel> createGame(String hostId) async {
    final gameData = {
      'hostId': hostId,
      'players': [hostId],
      'gameStatus': 'waiting',
      'createdAt': Timestamp.now(),
      'gameData': {},
    };

    final docRef = await _firestore.collection('games').add(gameData);
    return GameModel.fromJson({...gameData, 'id': docRef.id});
  }

  Future<void> joinGame(String gameId, String playerId) async {
    await _firestore.collection('games').doc(gameId).update({
      'players': FieldValue.arrayUnion([playerId]),
    });
  }

  Stream<GameModel> watchGame(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots().map(
          (doc) => GameModel.fromJson({...doc.data()!, 'id': doc.id}),
        );
  }
} 