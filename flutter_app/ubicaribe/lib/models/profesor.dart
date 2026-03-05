class Profesor {
  final int id;
  final String nombre;
  final String correo;
  final String extension;
  final String telefono;
  final String puesto;
  final String biografia;
  final String imagen;
  final int departamentoId;

  Profesor({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.extension,
    required this.telefono,
    required this.puesto,
    required this.biografia,
    required this.imagen,
    required this.departamentoId,
  });

  factory Profesor.fromMap(Map<String, dynamic> map) {
    return Profesor(
      id: map['id'],
      nombre: map['nombre'],
      correo: map['correo'] ?? '',
      extension: map['extension'] ?? '',
      telefono: map['telefono'] ?? '',
      puesto: map['puesto'] ?? '',
      biografia: map['biografia'] ?? '',
      imagen: map['imagen'] ?? '',
      departamentoId: map['departamento_id'],
    );
  }
}