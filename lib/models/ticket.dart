class Ticket {
  final String titulo;
  final String descripcion;
  final String categoria;
  final String estado;

  Ticket({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.estado,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      estado: json['estado'] ?? 'abierto',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'estado': estado,
    };
  }
}
