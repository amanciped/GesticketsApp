class Ticket {
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;

  Ticket({
    required this.title,
    required this.description,
    required this.category,
  }) : createdAt = DateTime.now();
}