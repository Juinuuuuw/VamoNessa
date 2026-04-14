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
}