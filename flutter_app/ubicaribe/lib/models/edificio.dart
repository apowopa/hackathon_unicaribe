class Edificio {
  final int id;
  final String nombre;

  Edificio({
    required this.id,
    required this.nombre,
  });

  // La "Magia": Este método convierte la fila de SQLite en un objeto Edificio
  factory Edificio.fromMap(Map<String, dynamic> map) {
    return Edificio(
      id: map['id'],
      nombre: map['nombre'],
    );
  }
}