// lib/models/event.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participants;
  final String status;
  final String createdBy;
  final DateTime? createdAt;
  final List<DateOption>? dateOptions;
  final List<VenueOptionModel>? venueOptions;

  Event({
    required this.id,
    required this.title,
    this.description = '',
    this.imageUrl = '',
    required this.startDate,
    required this.endDate,
    this.participants = const [],
    this.status = 'planning',
    required this.createdBy,
    this.createdAt,
    this.dateOptions,
    this.venueOptions,
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Documento sem dados');
    }

    // ---------- EXTRAIR DATAS ----------
    DateTime startDate;
    DateTime endDate;

    // Tenta primeiro obter do array dateOptions
    final dateOptionsRaw = data['dateOptions'] as List<dynamic>?;
    if (dateOptionsRaw != null && dateOptionsRaw.isNotEmpty) {
      final first = dateOptionsRaw.first as Map<String, dynamic>?;
      final last = dateOptionsRaw.last as Map<String, dynamic>?;
      if (first != null && first['startDate'] is Timestamp) {
        startDate = (first['startDate'] as Timestamp).toDate();
      } else {
        startDate = DateTime.now();
      }
      if (last != null && last['endDate'] is Timestamp) {
        endDate = (last['endDate'] as Timestamp).toDate();
      } else {
        endDate = startDate.add(const Duration(days: 1));
      }
    } else {
      // Fallback para campos diretos
      final directStart = data['startDate'];
      final directEnd = data['endDate'];
      startDate = directStart is Timestamp
          ? directStart.toDate()
          : DateTime.now();
      endDate = directEnd is Timestamp
          ? directEnd.toDate()
          : startDate.add(const Duration(days: 1));
    }

    // ---------- EXTRAIR IMAGEM ----------
    String imageUrl = data['imageUrl']?.toString() ?? '';
    if (imageUrl.isEmpty) {
      final venueOptsRaw = data['venueOptions'] as List<dynamic>?;
      if (venueOptsRaw != null && venueOptsRaw.isNotEmpty) {
        final firstVenue = venueOptsRaw.first as Map<String, dynamic>?;
        if (firstVenue != null) {
          imageUrl = firstVenue['imageUrl']?.toString() ?? '';
        }
      }
    }

    // ---------- PARTICIPANTES ----------
    final participantsRaw = data['participants'] as List<dynamic>?;
    final participants = participantsRaw != null
        ? participantsRaw.map((e) => e.toString()).toList()
        : <String>[];

    // ---------- CONVERSÃO DE ARRAYS COMPLEXOS ----------
    List<DateOption>? parsedDateOptions;
    if (data['dateOptions'] is List) {
      try {
        parsedDateOptions = (data['dateOptions'] as List)
            .map((item) => DateOption.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    List<VenueOptionModel>? parsedVenueOptions;
    if (data['venueOptions'] is List) {
      try {
        parsedVenueOptions = (data['venueOptions'] as List)
            .map((item) => VenueOptionModel.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return Event(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      imageUrl: imageUrl,
      startDate: startDate,
      endDate: endDate,
      participants: participants,
      status: data['status']?.toString() ?? 'planning',
      createdBy: data['createdBy']?.toString() ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      dateOptions: parsedDateOptions,
      venueOptions: parsedVenueOptions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'participants': participants,
      'status': status,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'dateOptions': dateOptions?.map((d) => d.toMap()).toList(),
      'venueOptions': venueOptions?.map((v) => v.toMap()).toList(),
    };
  }
}

// ---------- MODELOS AUXILIARES ----------
class DateOption {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  List<String> votes;

  DateOption({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.votes = const [],
  });

  factory DateOption.fromMap(Map<String, dynamic> map) {
    return DateOption(
      id: map['id']?.toString() ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      votes: List<String>.from(map['votes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'votes': votes,
      };
}

class VenueOptionModel {
  final String id;
  final String title;
  final String venueName;
  final String? venueLink;
  final double price;
  final String priceDetail;
  final String imageUrl;
  final List<Activity> activities;
  final String scheduleName;
  final List<Activity> scheduleActivities;
  final double total;
  List<String> votes;

  VenueOptionModel({
    required this.id,
    required this.title,
    required this.venueName,
    this.venueLink,
    required this.price,
    required this.priceDetail,
    required this.imageUrl,
    required this.activities,
    required this.scheduleName,
    required this.scheduleActivities,
    required this.total,
    this.votes = const [],
  });

  factory VenueOptionModel.fromMap(Map<String, dynamic> map) {
    return VenueOptionModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      venueName: map['venueName']?.toString() ?? '',
      venueLink: map['venueLink']?.toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      priceDetail: map['priceDetail']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      activities: (map['activities'] as List?)
              ?.map((a) => Activity.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      scheduleName: map['scheduleName']?.toString() ?? '',
      scheduleActivities: (map['scheduleActivities'] as List?)
              ?.map((a) => Activity.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      votes: List<String>.from(map['votes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'venueName': venueName,
        'venueLink': venueLink,
        'price': price,
        'priceDetail': priceDetail,
        'imageUrl': imageUrl,
        'activities': activities.map((a) => a.toMap()).toList(),
        'scheduleName': scheduleName,
        'scheduleActivities': scheduleActivities.map((a) => a.toMap()).toList(),
        'total': total,
        'votes': votes,
      };
}

class Activity {
  final String name;
  final String? time;

  Activity({required this.name, this.time});

  factory Activity.fromMap(Map<String, dynamic> map) => Activity(
        name: map['name']?.toString() ?? '',
        time: map['time']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'time': time,
      };
}