class Comment {
  final String contenido;
  final String autor;
  final String fecha;

  Comment({
    required this.contenido,
    required this.autor,
    required this.fecha,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      contenido: json['contenido'],
      autor: json['autor'],
      fecha: json['fecha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contenido': contenido,
      'autor': autor,
      'fecha': fecha,
    };
  }
}