import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  final String id;
  final String type; // 'location' ou 'date'
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final DateTime? date; // para tipo 'date'
  final int votes;
  final List<String> votedBy;

  Poll({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.date,
    required this.votes,
    required this.votedBy,
  });

  factory Poll.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Poll(
      id: doc.id,
      type: data['type'] ?? 'location',
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      imageUrl: data['imageUrl'],
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
      votes: data['votes'] ?? 0,
      votedBy: List<String>.from(data['votedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'votes': votes,
      'votedBy': votedBy,
    };
  }
}