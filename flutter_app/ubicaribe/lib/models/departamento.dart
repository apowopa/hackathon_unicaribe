class Departamento {
  final int id;
  final String nombre;
  final String piso;
  final int edificioId;

  Departamento({
    required this.id,
    required this.nombre,
    required this.piso,
    required this.edificioId,
  });

  factory Departamento.fromMap(Map<String, dynamic> map) {
    return Departamento(
      id: map['id'],
      nombre: map['nombre'],
      piso: map['piso'] ?? '', // Si viene nulo de la DB, ponemos texto vacío
      edificioId: map['edificio_id'],
    );
  }
}