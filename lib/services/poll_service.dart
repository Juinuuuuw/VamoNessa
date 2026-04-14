import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/poll.dart';

class PollService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obter stream de polls de um evento por tipo
  Stream<List<Poll>> getPollsByType(String eventId, String type) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('polls')
        .where('type', isEqualTo: type)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Poll.fromFirestore(doc)).toList(),
        );
  }

  // Votar em uma opção
  Future<void> vote(String eventId, String pollId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final pollRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('polls')
        .doc(pollId);

    await _firestore.runTransaction((transaction) async {
      final pollSnapshot = await transaction.get(pollRef);
      if (!pollSnapshot.exists) throw Exception('Opção não encontrada');

      final data = pollSnapshot.data()!;
      List<String> votedBy = List<String>.from(data['votedBy'] ?? []);
      int votes = data['votes'] ?? 0;

      if (votedBy.contains(user.uid)) {
        // Remove voto
        votedBy.remove(user.uid);
        votes--;
      } else {
        // Adiciona voto
        votedBy.add(user.uid);
        votes++;
      }

      transaction.update(pollRef, {'votes': votes, 'votedBy': votedBy});
    });
  }

  // Verificar se usuário atual votou em determinada opção
  bool hasUserVoted(Poll poll) {
    final user = _auth.currentUser;
    return user != null && poll.votedBy.contains(user.uid);
  }

  // Criar uma nova opção de votação (ex.: adicionar local)
  Future<void> createPoll(String eventId, Poll poll) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('polls')
        .add(poll.toMap());
  }
}
