// lib/services/event_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart'; // <-- Único import necessário

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Busca um evento pelo ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) return null;
      return Event.fromFirestore(doc);
    } catch (e) {
      print('Erro ao buscar evento: $e');
      return null;
    }
  }

  /// Cria um evento simples (modelo Event básico)
  Future<void> createEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  /// Cria um evento avançado com opções de data e local
  Future<String> createAdvancedEvent({
    required String title,
    required String description,
    required String? imageUrl,
    required List<DateOption> dateOptions,
    required List<VenueOptionModel> venueOptions,
    required String createdBy,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final dateOptionsMap = dateOptions.map((d) {
      return {
        'id': d.id.isEmpty ? _firestore.collection('events').doc().id : d.id,
        'startDate': Timestamp.fromDate(d.startDate),
        'endDate': Timestamp.fromDate(d.endDate),
        'votes': d.votes,
      };
    }).toList();

    final venueOptionsMap = venueOptions.map((v) {
      return {
        'id': v.id.isEmpty ? _firestore.collection('events').doc().id : v.id,
        'title': v.title,
        'venueName': v.venueName,
        'venueLink': v.venueLink,
        'price': v.price,
        'priceDetail': v.priceDetail,
        'imageUrl': v.imageUrl,
        'activities': v.activities.map((a) => a.toMap()).toList(),
        'scheduleName': v.scheduleName,
        'scheduleActivities': v.scheduleActivities.map((a) => a.toMap()).toList(),
        'total': v.total,
        'votes': v.votes,
      };
    }).toList();

    final docRef = await _firestore.collection('events').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl ?? '',
      'dateOptions': dateOptionsMap,
      'venueOptions': venueOptionsMap,
      'participants': [user.uid],
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'voting',
    });

    return docRef.id;
  }

  /// Stream dos eventos do usuário atual
  Stream<List<Event>> getUserEvents() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('events')
        .where('participants', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList(),
        );
  }
}