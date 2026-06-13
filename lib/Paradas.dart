class Paradas {

  final int id;
  final String nombre;
  final double latitud;
  final double longitud;
  final String? rutas;

  Paradas({
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    this.rutas,
  });

  factory Paradas.fromJson(
    Map<String, dynamic> json,
  ) {

    return Paradas(

      id: int.tryParse(
            json['id']?.toString() ?? '0',
          ) ??
          0,

      nombre:
          json['nombre']?.toString() ??
          'Sin nombre',

      latitud: double.tryParse(
            json['latitud']?.toString() ?? '0',
          ) ??
          0,

      longitud: double.tryParse(
            json['longitud']?.toString() ?? '0',
          ) ??
          0,

      rutas:
          json['rutas']?.toString(),

    );
  }
}