class Complaint {
  final String type;
  final String description;
  final DateTime date;

  Complaint({
    required this.type,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      type: json['type'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  @override
  String toString() {
    return 'Complaint(type: $type, description: $description, date: $date)';
  }
}
