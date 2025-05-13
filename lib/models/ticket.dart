class Ticket {
  final String titulo;
  final String descripcion;
  final String categoria;
  final String estado;
  final String? asignadoA;

  Ticket({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    this.asignadoA,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      estado: json['estado'] ?? 'abierto',
      asignadoA: json['asignadoA'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'estado': estado,
      'asignadoA': asignadoA,
    };
  }
}
