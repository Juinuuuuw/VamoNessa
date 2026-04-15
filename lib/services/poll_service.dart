// lib/services/poll_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PollService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> voteDate(String eventId, String dateOptionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final eventRef = _firestore.collection('events').doc(eventId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventRef);
      if (!snapshot.exists) throw Exception('Evento não encontrado');

      final data = snapshot.data()!;
      final List<dynamic> dateOptionsRaw = data['dateOptions'] ?? [];
      final List<Map<String, dynamic>> dateOptions =
          dateOptionsRaw.map((e) => Map<String, dynamic>.from(e)).toList();

      final index = dateOptions.indexWhere((d) => d['id'] == dateOptionId);
      if (index == -1) throw Exception('Opção de data não encontrada');

      List<String> votes = List<String>.from(dateOptions[index]['votes'] ?? []);
      if (votes.contains(user.uid)) {
        votes.remove(user.uid);
      } else {
        votes.add(user.uid);
      }
      dateOptions[index]['votes'] = votes;

      transaction.update(eventRef, {'dateOptions': dateOptions});
    });
  }

  Future<void> voteVenue(String eventId, String venueOptionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final eventRef = _firestore.collection('events').doc(eventId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventRef);
      if (!snapshot.exists) throw Exception('Evento não encontrado');

      final data = snapshot.data()!;
      final List<dynamic> venueOptionsRaw = data['venueOptions'] ?? [];
      final List<Map<String, dynamic>> venueOptions =
          venueOptionsRaw.map((e) => Map<String, dynamic>.from(e)).toList();

      final index = venueOptions.indexWhere((v) => v['id'] == venueOptionId);
      if (index == -1) throw Exception('Opção de local não encontrada');

      List<String> votes = List<String>.from(venueOptions[index]['votes'] ?? []);
      if (votes.contains(user.uid)) {
        votes.remove(user.uid);
      } else {
        votes.add(user.uid);
      }
      venueOptions[index]['votes'] = votes;

      transaction.update(eventRef, {'venueOptions': venueOptions});
    });
  }

  bool hasUserVoted(List<String> votes) {
    final user = _auth.currentUser;
    return user != null && votes.contains(user.uid);
  }
}