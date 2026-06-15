import "package:flutter/foundation.dart";
import "package:latlong2/latlong.dart";
import 'package:geolocator/geolocator.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:prototipo/Paradas.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class MapViewModel extends ChangeNotifier {

  static const String baseUrl =
      "http://localhost/api_prototipo";

  static const LatLng defaultLocation =
      LatLng(-30.9179, -55.5469);

  LatLng? _userLocation;
  LatLng? get ubicacionUsuario =>
      _userLocation;

  List<Paradas> _paradas = [];
  List<Paradas> get paradas =>
      _paradas;

  List<LatLng> _puntosRuta = [];
  List<LatLng> get puntosRuta =>
      _puntosRuta;

  List<Map<String, dynamic>> _horarios = [];
  List<Map<String, dynamic>> get horarios =>
      _horarios;

  Color _colorRuta = Colors.blue;
  Color get colorRuta =>
      _colorRuta;

  bool _loading = false;
  bool get loading =>
      _loading;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setUbicacion(
    LatLng ubicacion,
  ) {
    _userLocation = ubicacion;
    notifyListeners();
  }

  Future<void> obtenerUbicacion() async {

    _setLoading(true);

    try {

      Position position =
          await Geolocator.getCurrentPosition();

      _userLocation = LatLng(
        position.latitude,
        position.longitude,
      );

    } catch (e) {

      print(
        "Error ubicación: $e",
      );

    } finally {

      _setLoading(false);
    }

    notifyListeners();
  }

  Future<void> obtenerParadas() async {

  _setLoading(true);

  try {

    final url = Uri.parse(
      '$baseUrl/obtener_parada.php',
    );

    final response =
        await http.get(url);

    if (response.statusCode == 200) {

      final data =
          json.decode(response.body);

      if (data['paradas'] != null) {

        _paradas =
            (data['paradas'] as List)
                .map(
                  (p) =>
                      Paradas.fromJson(p),
                )
                .toList();

        notifyListeners();
      }
    }

  } catch (e) {

    print(
      "Error paradas: $e",
    );

  } finally {

    _setLoading(false);
  }
}

  Future<List<dynamic>>
      obtenerRutasDeParada(
    int idParada,
  ) async {

    final url = Uri.parse(
      '$baseUrl/obtener_ruta_por_parada.php?id_parada=$idParada',
    );

    final response =
        await http.get(url);

    if (response.statusCode == 200) {

      final data =
          json.decode(response.body);

      return data['rutas'];
    }

    return [];
  }

  Future<void> obtenerRutaPorId(
  int idRuta,
  String nombre,
) async {

  _setLoading(true);

  _puntosRuta = [];
  _horarios = [];

  _colorRuta = Color.fromARGB(
    255,
    Random().nextInt(255),
    Random().nextInt(255),
    Random().nextInt(255),
  );

  notifyListeners();

  try {

    /*
      OBTENER DATOS DE LA RUTA
    */

    final rutaUrl = Uri.parse(
      '$baseUrl/listado_rutas.php',
    );

    final rutaResponse =
        await http.get(rutaUrl);

    if (rutaResponse.statusCode != 200) {
      return;
    }

    final rutasData =
        json.decode(rutaResponse.body);

    final ruta =
        (rutasData['rutas'] as List)
            .firstWhere(
      (r) => r['id'].toString() ==
          idRuta.toString(),
    );

    /*
      OBTENER PARADAS
    */

    final url = Uri.parse(
      '$baseUrl/obtener_ruta.php?id_ruta=$idRuta',
    );

    final response =
        await http.get(url);

    if (response.statusCode != 200) {
      return;
    }

    final data =
        json.decode(response.body);

    /*
      INICIO REAL
    */

    final LatLng inicio = LatLng(
      double.parse(
        ruta['punto_inicio_lat']
            .toString(),
      ),
      double.parse(
        ruta['punto_inicio_lng']
            .toString(),
      ),
    );

    /*
      FIN REAL
    */

    final LatLng fin = LatLng(
      double.parse(
        ruta['punto_fin_lat']
            .toString(),
      ),
      double.parse(
        ruta['punto_fin_lng']
            .toString(),
      ),
    );

    /*
      PARADAS INTERMEDIAS
    */

    final List<LatLng> paradas = [];

    for (var p in data['paradas']) {

      final lat =
          double.tryParse(
        p['latitud'].toString(),
      );

      final lng =
          double.tryParse(
        p['longitud'].toString(),
      );

      if (
          lat != null &&
          lng != null
      ) {

        paradas.add(
          LatLng(lat, lng),
        );
      }
    }

    /*
      ORDEN CORRECTO:
      INICIO -> PARADAS -> FIN
    */

    final List<LatLng> puntos = [

      inicio,

      ...paradas,

      fin
    ];

    /*
      GENERAR RUTA REAL
    */

    if (puntos.length >= 2) {

      await buscarRutaOSRM(
        puntos,
      );
    }

  } catch (e) {

    print(
      "ERROR obtenerRutaPorId: $e",
    );

  } finally {

    _setLoading(false);
  }

  notifyListeners();
}

  Future<void> buscarRutaOSRM(
    List<LatLng> paradas,
  ) async {

    try {

      final coords = paradas
          .map(
            (p) =>
                "${p.longitude},${p.latitude}",
          )
          .join(";");

      final url = Uri.parse(
        "https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson",
      );

      final response =
          await http.get(url);

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        final lista =
            data['routes'][0]
                ['geometry']
                ['coordinates'];

        _puntosRuta = lista
            .map<LatLng>(
              (c) => LatLng(
                c[1].toDouble(),
                c[0].toDouble(),
              ),
            )
            .toList();

      } else {

        _puntosRuta = paradas;
      }

    } catch (e) {

      print(
        "ERROR OSRM: $e",
      );

      _puntosRuta = paradas;
    }

    notifyListeners();
  }

  Future<void> obtenerHorariosRuta(
    int idRuta,
  ) async {

    _setLoading(true);

    try {

      final url = Uri.parse(
        '$baseUrl/obtener_horario.php?id_ruta=$idRuta',
      );

      final response =
          await http.get(url);

      if (response.statusCode == 200) {

        final data =
            json.decode(response.body);

        if (
            data is Map &&
            data.containsKey(
              "horarios",
            )) {

          _horarios =
              List<Map<String, dynamic>>
                  .from(
            data["horarios"],
          );
        }
      }

    } catch (e) {

      print(
        "Error horarios: $e",
      );

    } finally {

      _setLoading(false);
    }

    notifyListeners();
  }

  Future<void>
      obtenerRutaHastaParada(
    LatLng destino,
  ) async {

    if (_userLocation == null) {
      return;
    }

    _setLoading(true);

    _horarios = [];

    try {

      final coords =
          "${_userLocation!.longitude},${_userLocation!.latitude};${destino.longitude},${destino.latitude}";

      final url = Uri.parse(
        "https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson",
      );

      final response =
          await http.get(url);

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        final lista =
            data['routes'][0]
                ['geometry']
                ['coordinates'];

        _puntosRuta = lista
            .map<LatLng>(
              (c) => LatLng(
                c[1].toDouble(),
                c[0].toDouble(),
              ),
            )
            .toList();

        _colorRuta = Colors.red;

      } else {

        _puntosRuta = [
          _userLocation!,
          destino,
        ];
      }

    } catch (e) {

      print(
        "Error ruta usuario -> parada: $e",
      );

      _puntosRuta = [
        _userLocation!,
        destino,
      ];

    } finally {

      _setLoading(false);
    }

    notifyListeners();
  }

  Future<bool> actualizarPlan(
  int idUsuario,
  String nuevoPlan,
) async {

  try {

    final response =
        await http.post(

      Uri.parse(
        "$baseUrl/actualizar_plan.php",
      ),

      headers: {

        "Content-Type":
            "application/json",
      },

      body: jsonEncode({

        "id": idUsuario,

        "plan": nuevoPlan,
      }),
    );

    final data =
        jsonDecode(response.body);

    return data["success"] == true;

  } catch (e) {

    print(
      "Error actualizando plan: $e",
    );

    return false;
  }
}

// ================= ELIMINAR CUENTA =================

 Future<bool> eliminarCuenta(
  int idUsuario,
) async {

  try {

    final response =
        await http.post(

      Uri.parse(
        "$baseUrl/eliminar_pasajero.php",
      ),

      headers: {
        "Content-Type":
            "application/json",
      },

      body: jsonEncode({

        "id": idUsuario,
      }),
    );

    final data =
        jsonDecode(response.body);

    return data["success"] == true;

  } catch (e) {

    print(
      "Error eliminando cuenta: $e",
    );

    return false;
  }
}

}
