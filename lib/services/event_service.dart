// lib/services/event_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';

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

  /// Gera um código de convite único de 6 caracteres
  Future<String> _generateUniqueInviteCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    String code;
    bool exists;
    int attempts = 0;

    do {
      code = List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
      final query = await _firestore
          .collection('events')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();
      exists = query.docs.isNotEmpty;
      attempts++;
      if (attempts > 10) {
        // Fallback: adiciona um timestamp para garantir unicidade
        code = '${code.substring(0, 4)}${DateTime.now().millisecondsSinceEpoch % 100}';
        break;
      }
    } while (exists);

    return code;
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

    // Gera código único de convite
    final inviteCode = await _generateUniqueInviteCode();

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
      'inviteCode': inviteCode,
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

  /// Obtém o código de convite existente ou gera um novo
  Future<String> getOrCreateInviteCode(String eventId) async {
    final event = await getEventById(eventId);
    if (event?.inviteCode != null && event!.inviteCode!.isNotEmpty) {
      return event.inviteCode!;
    }
    final newCode = await _generateUniqueInviteCode();
    await _firestore.collection('events').doc(eventId).update({'inviteCode': newCode});
    return newCode;
  }

  /// Ingressa em um evento usando código de convite
  Future<bool> joinEventWithCode(String inviteCode) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final query = await _firestore
        .collection('events')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final eventRef = query.docs.first.reference;

    await eventRef.update({
      'participants': FieldValue.arrayUnion([user.uid])
    });

    return true;
  }

  /// Confirma o evento, mudando o status para 'confirmed'
  Future<void> confirmEvent(String eventId) async {
    final eventRef = _firestore.collection('events').doc(eventId);
    await eventRef.update({'status': 'confirmed'});
  }
}