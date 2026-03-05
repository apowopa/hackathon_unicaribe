class Notificacion {
  final int id;
  final String titulo;
  final String mensaje;
  final bool leida; // Lo manejamos como true/false en Flutter
  final DateTime createdAt; // Lo manejamos como fecha real

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    required this.createdAt,
  });

  factory Notificacion.fromMap(Map<String, dynamic> map) {
    return Notificacion(
      id: map['id'],
      titulo: map['titulo'],
      mensaje: map['mensaje'],
      // TRUCO 1: Si SQLite dice 1 es true, si es 0 es false
      leida: map['leida'] == 1, 
      // TRUCO 2: Convertimos el texto de SQLite a un objeto DateTime de Dart
      createdAt: DateTime.parse(map['created_at']), 
    );
  }
}