class Ticket {
  final String titulo;
  final String descripcion;
  final String categoria;

  Ticket({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
    );
  }
}
