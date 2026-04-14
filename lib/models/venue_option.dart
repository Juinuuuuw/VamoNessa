class Activity {
  final String name;
  final String? time;

  Activity({required this.name, this.time});

  Map<String, dynamic> toMap() => {'name': name, 'time': time};
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
}
