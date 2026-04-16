import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getParticipants(String eventId) async {
    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    final uids = List<String>.from(eventDoc.data()?['participants'] ?? []);
    final List<Map<String, dynamic>> result = [];

    for (var uid in uids) {
      try {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        String name = uid;
        if (userDoc.exists) {
          final data = userDoc.data()!;
          final first = data['first_name'] ?? '';
          final last = data['last_name'] ?? '';
          name = '$first $last'.trim();
          if (name.isEmpty) name = data['email']?.split('@').first ?? uid;
        }
        result.add({'uid': uid, 'name': name});
      } catch (e) {
        result.add({'uid': uid, 'name': uid}); // fallback seguro
      }
    }
    return result;
  }
}
