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
      categoria: json['categoria'].toString().toUpperCase(), // normaliza a mayúsculas
      estado: json['estado'].toString().toUpperCase(),
      asignadoA: json['asignadoA'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria.toUpperCase(),
      'estado': estado.toUpperCase(),
      'asignadoA': asignadoA,
    };
  }
}
