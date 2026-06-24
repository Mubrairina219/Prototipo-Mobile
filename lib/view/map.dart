import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:prototipo/Paradas.dart';
import 'package:prototipo/view/loading.dart';
import 'package:prototipo/viewmodel/loading_viewmodel.dart';
import 'package:prototipo/viewmodel/map_viewmodel.dart';
import 'package:prototipo/view/wearable/watch.dart';
import 'package:prototipo/viewmodel/login_viewmodel.dart';
import 'package:prototipo/main.dart';

class MapScreen extends StatefulWidget {

  final MapViewModel viewModel;

  final String plan;

  final String nombre;

  final String email;

  final int idUsuario;

  const MapScreen({
    super.key,
    required this.viewModel,
    required this.plan,
    required this.nombre,
    required this.email,
    required this.idUsuario,
  });

  @override
  State<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  // =====================================
  // VIEWMODEL DEL MAPA
  // =====================================

  late MapViewModel _viewModel;

  // =====================================
  // CONTROLADOR DEL MAPA
  // =====================================

  final MapController _mapController =
      MapController();

  // =====================================
  // VIEWMODEL DE CARGA
  // =====================================

  final LoadingViewModel loadingVM =
      LoadingViewModel();

  // =====================================
  // CONFIGURACIÓN DEL MAPA
  // =====================================

  double _zoom = 15;

  bool _centrado = false;

  bool _mapaListo = false;

  String _planActual = "";

  final LoginViewModel loginVM =
    LoginViewModel();

  bool aceptaEliminacion = false;

  String? _paradaSeleccionadaKey;

  // =====================================
  // INICIALIZACIÓN
  // =====================================

  @override
  void initState() {

    super.initState();

    _planActual = widget.plan;

    _viewModel = widget.viewModel;

    // Escucha cambios del Loading

    loadingVM.addListener(() {

      if (mounted) {

        setState(() {});
      }
    });

    // Escucha cambios del mapa

    _viewModel.addListener(() {

      if (!mounted) return;

      setState(() {});

      // Centrar una sola vez

      if (!_centrado &&
          _viewModel.ubicacionUsuario != null) {

        _mapController.move(
          _viewModel.ubicacionUsuario!,
          _zoom,
        );

        _centrado = true;
      }
    });

    _cargarMapa();
  }

  @override
  void dispose() {

    loadingVM.dispose();

    super.dispose();
  }

  void _mostrarDialogPremium() {

  showDialog(

    context: context,

    builder: (_) => AlertDialog(

      title: const Text(
        "Plan Premium",
      ),

      content: Column(

        mainAxisSize: MainAxisSize.min,

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: const [

          Text(
            "Beneficios:",
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 15),

          ListTile(
            leading: Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            title: Text(
              "Asistente IA integrado",
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            title: Text(
              "Consultas inteligentes",
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            title: Text(
              "Información avanzada",
            ),
          ),

          SizedBox(height: 15),

          Center(
            child: Text(
              "\$4.99 USD / mes",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      actions: [

        TextButton(

          onPressed: () {

            Navigator.pop(context);
          },

          child: const Text(
            "Cancelar",
          ),
        ),

        ElevatedButton(

          onPressed: () async {

            final ok =
    await _viewModel.actualizarPlan(
  widget.idUsuario,
  "premium",
);

if (ok) {

  setState(() {

    _planActual =
        "premium";
  });

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(

      content: Text(
        "Plan Premium activado",
      ),
    ),
  );

} else {

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(

      content: Text(
        "No se pudo actualizar el plan",
      ),
    ),
  );
}

            Navigator.pop(context);

            ScaffoldMessenger.of(
                    context)
                .showSnackBar(

              const SnackBar(

                content: Text(
                  "Plan Premium activado",
                ),
              ),
            );
          },

          child: const Text(
            "Cambiar",
          ),
        ),
      ],
    ),
  );
}

 void _mostrarCancelarPlan() {

  showDialog(

    context: context,

    builder: (_) => AlertDialog(

      title: const Text(
        "Cancelar Premium",
      ),

      content: const Text(
        "¿Estás seguro de que deseas cancelar tu suscripción Premium?",
      ),

      actions: [

        TextButton(

          onPressed: () {

            Navigator.pop(context);
          },

          child: const Text(
            "Volver",
          ),
        ),

        ElevatedButton(

          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                Colors.red,
          ),

          onPressed: () async {

            final ok =
    await _viewModel.actualizarPlan(
  widget.idUsuario,
  "free",
);

if (ok) {

  setState(() {

    _planActual =
        "free";
  });

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(

      content: Text(
        "Plan cancelado",
      ),
    ),
  );

} else {

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(

      content: Text(
        "No se pudo cancelar el plan",
      ),
    ),
  );
}

            Navigator.pop(context);

            ScaffoldMessenger.of(
                    context)
                .showSnackBar(

              const SnackBar(

                content: Text(
                  "Plan Premium cancelado",
                ),
              ),
            );
          },

          child: const Text(
            "Cancelar plan",
          ),
        ),
      ],
    ),
  );
}

void _confirmarEliminarCuenta() {

  aceptaEliminacion = false;

  showDialog(

    context: context,

    builder: (dialogContext) {

      return StatefulBuilder(

        builder: (
          context,
          setDialogState,
        ) {

          return AlertDialog(

            shape: RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(15),
            ),

            title: const Row(

              children: [

                Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),

                SizedBox(width: 10),

                Text(
                  "Eliminar cuenta",
                ),
              ],
            ),

            content: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const Icon(

                  Icons.warning_amber_rounded,

                  color: Colors.red,

                  size: 60,
                ),

                const SizedBox(
                  height: 15,
                ),

                const Text(

                  "Esta acción eliminará permanentemente tu cuenta.",

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(

                  "Todos tus datos serán eliminados y no podrán recuperarse.",

                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(
                  height: 20,
                ),

                CheckboxListTile(

                  value:
                      aceptaEliminacion,

                  contentPadding:
                      EdgeInsets.zero,

                  controlAffinity:
                      ListTileControlAffinity
                          .leading,

                  title: const Text(

                    "Entiendo que esta acción es irreversible.",

                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),

                  onChanged: (value) {

                    setDialogState(() {

                      aceptaEliminacion =
                          value ?? false;
                    });
                  },
                ),
              ],
            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(
                    dialogContext,
                  );
                },

                child: const Text(
                  "Cancelar",
                ),
              ),

              ElevatedButton.icon(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.red,

                  foregroundColor:
                      Colors.white,
                ),

                onPressed:
                    aceptaEliminacion

                        ? () async {

                            final ok =
                                await widget.viewModel
                                    .eliminarCuenta(

                              widget.idUsuario,
                            );

                            if (!mounted) {
                              return;
                            }

                            Navigator.pop(
                              dialogContext,
                            );

                            if (ok) {

                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(

                                const SnackBar(

                                  content: Text(
                                    "Cuenta eliminada correctamente",
                                  ),
                                ),
                              );

                              Navigator.pushAndRemoveUntil(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      const MyApp(),
                                ),

                                (route) => false,
                              );

                            } else {

                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(

                                const SnackBar(

                                  content: Text(
                                    "No se pudo eliminar la cuenta",
                                  ),
                                ),
                              );
                            }
                          }

                        : null,

                icon: const Icon(
                  Icons.delete,
                ),

                label: const Text(
                  "Eliminar",
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

  // =====================================
// SIDEBAR DE PERFIL
// =====================================

Widget _buildDrawer() {

  return Drawer(

    child: SafeArea(

      child: Column(

        children: [

          // =====================================
          // CABECERA DEL USUARIO
          // =====================================

          Container(

            width: double.infinity,

            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 25,
            ),

            decoration: const BoxDecoration(

              gradient: LinearGradient(

                colors: [

                  Color(0xFF1565C0),

                  Color(0xFF42A5F5),
                ],

                begin: Alignment.topLeft,

                end: Alignment.bottomRight,
              ),
            ),

            child: Column(

              children: [

                Container(

                  decoration: BoxDecoration(

                    shape: BoxShape.circle,

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black26,

                        blurRadius: 10,
                      ),
                    ],
                  ),

                  child: const CircleAvatar(

                    radius: 45,

                    backgroundColor: Colors.white,

                    child: Icon(

                      Icons.person,

                      size: 50,

                      color: Colors.blueAccent,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Text(

                  widget.nombre,

                  textAlign: TextAlign.center,

                  style: const TextStyle(

                    color: Colors.white,

                    fontSize: 22,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(

                  widget.email,

                  textAlign: TextAlign.center,

                  style: const TextStyle(

                    color: Colors.white70,

                    fontSize: 14,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Container(

                  padding:
                      const EdgeInsets.symmetric(

                    horizontal: 20,

                    vertical: 8,
                  ),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),

                  child: Text(

                    _planActual.toUpperCase(),

                    style: TextStyle(

                      color:
                          _planActual ==
                                  "premium"
                              ? Colors.orange
                              : Colors.blueAccent,

                      fontWeight:
                          FontWeight.bold,

                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          // =====================================
          // PLAN ACTUAL
          // =====================================

          Card(

            margin:
                const EdgeInsets.symmetric(

              horizontal: 15,

              vertical: 5,
            ),

            elevation: 2,

            shape: RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            child: ListTile(

              leading: Icon(

                Icons.workspace_premium,

                color:
                    _planActual ==
                            "premium"
                        ? Colors.amber
                        : Colors.blueAccent,
              ),

              title: const Text(
                "Plan actual",
              ),

              subtitle: Text(
                _planActual.toUpperCase(),
              ),
            ),
          ),

          const Divider(),

          // =====================================
          // BOTÓN PREMIUM
          // =====================================

          Padding(

            padding:
                const EdgeInsets.all(16),

            child: SizedBox(

              width: double.infinity,

              child:
                  _planActual == "free"

                      ? ElevatedButton.icon(

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                Colors.amber,

                            foregroundColor:
                                Colors.white,

                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 15,
                            ),

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius.circular(
                                15,
                              ),
                            ),
                          ),

                          onPressed:
                              _mostrarDialogPremium,

                          icon: const Icon(
                            Icons.workspace_premium,
                          ),

                          label: const Text(
                            "Cambiar a Premium",
                          ),
                        )

                      : ElevatedButton.icon(

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                Colors.red,

                            foregroundColor:
                                Colors.white,

                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 15,
                            ),

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius.circular(
                                15,
                              ),
                            ),
                          ),

                          onPressed:
                              _mostrarCancelarPlan,

                          icon: const Icon(
                            Icons.cancel,
                          ),

                          label: const Text(
                            "Cancelar Premium",
                          ),
                        ),
            ),
          ),

          // =====================================
          // ELIMINAR CUENTA
          // =====================================

          Card(

            margin:
                const EdgeInsets.symmetric(

              horizontal: 15,

              vertical: 5,
            ),

            child: ListTile(

              leading: const Icon(

                Icons.delete_forever,

                color: Colors.red,
              ),

              title: const Text(

                "Eliminar cuenta",

                style: TextStyle(

                  color: Colors.red,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              onTap: () {

                Navigator.pop(context);

                _confirmarEliminarCuenta();
              },
            ),
          ),

          const Divider(),

          const Spacer(),

          // =====================================
          // CERRAR SESIÓN
          // =====================================

          Container(

            margin:
                const EdgeInsets.all(15),

            width: double.infinity,

            child: ElevatedButton.icon(

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    Colors.red,

                foregroundColor:
                    Colors.white,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),

              onPressed: () {

                Navigator.of(context)
                    .popUntil(
                  (route) => route.isFirst,
                );
              },

              icon: const Icon(
                Icons.logout,
              ),

              label: const Text(
                "Cerrar sesión",
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // =====================================
  // CARGA INICIAL DEL MAPA
  // =====================================

  Future<void> _cargarMapa() async {

    try {

      loadingVM.mostrar(
        "Obteniendo ubicación...",
      );

      await _viewModel.obtenerUbicacion();

      loadingVM.actualizarMensaje(
        "Cargando paradas...",
      );

      await _viewModel.obtenerParadas();

      loadingVM.actualizarMensaje(
        "Preparando mapa...",
      );

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      if (!mounted) return;

      setState(() {

        _mapaListo = true;
      });

    } finally {

      loadingVM.ocultar();
    }
  }

  // =====================================
  // ZOOM +
  // =====================================

  void _zoomIn() {

    setState(() {

      _zoom++;

      _mapController.move(
        _mapController.camera.center,
        _zoom,
      );
    });
  }

  // =====================================
  // ZOOM -
  // =====================================

  void _zoomOut() {

    setState(() {

      _zoom--;

      if (_zoom < 3) {
        _zoom = 3;
      }

      _mapController.move(
        _mapController.camera.center,
        _zoom,
      );
    });
  }

  // =====================================
// MOSTRAR INFORMACIÓN DE UNA PARADA
// =====================================

Future<void> _mostrarInfoParada(
  Paradas parada,
) async {

  setState(() {
    _paradaSeleccionadaKey =
        "${parada.latitud},${parada.longitud}";
  });

  loadingVM.mostrar("Calculando ruta...");

  await _viewModel.obtenerRutaHastaParada(
    LatLng(parada.latitud, parada.longitud),
  );

  loadingVM.actualizarMensaje("Cargando rutas...");

  final rutas =
      await _viewModel.obtenerRutasDeParada(parada.id);

  loadingVM.ocultar();

  if (!mounted) return;

  showDialog(
  context: context,
  builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    contentPadding: const EdgeInsets.all(16),

    title: Row(
      children: [
        const Icon(
          Icons.location_on,
          color: Colors.redAccent,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            parada.nombre,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),

    content: rutas.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Sin rutas disponibles",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          )
        : SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: rutas.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final r = rutas[index];

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        color: Colors.blueAccent,
                      ),
                    ),

                    title: Text(
                      r['ruta'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: Text(
                      "${r['empresa']} • ${r['matricula']}",
                      style: const TextStyle(fontSize: 12),
                    ),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                    ),

                    onTap: () async {
                      Navigator.pop(context);

                      loadingVM.mostrar("Cargando ruta...");

                      final idRuta =
                          int.parse(r['id'].toString());

                      await _viewModel.obtenerRutaPorId(
                        idRuta,
                        r['ruta'].toString(),
                      );

                      loadingVM.actualizarMensaje(
                        "Cargando horarios...",
                      );

                      await _viewModel.obtenerHorariosRuta(
                        idRuta,
                      );

                      loadingVM.ocultar();
                    },
                  ),
                );
              },
            ),
          ),

    actions: [
      TextButton.icon(
        onPressed: () {
          loadingVM.ocultar();
          Navigator.pop(context);

          setState(() {
            _paradaSeleccionadaKey = null;
          });
        },
        icon: const Icon(Icons.close),
        label: const Text("Cerrar"),
      ),
    ],
  ),
);
}

// =====================================
// BUILD
// =====================================

@override
@override
Widget build(BuildContext context) {

  // =====================================
  // PANTALLA DE CARGA
  // =====================================

  if (!_mapaListo) {

    return Scaffold(

      body: LoadingScreen(

        viewModel: loadingVM,

        textColor: Colors.white,
      ),
    );
  }

  final position =
      _viewModel.ubicacionUsuario;

  // =====================================
  // AGRUPAR HORARIOS POR PARADA
  // =====================================

  Map<String,
      List<Map<String, dynamic>>>
  horariosPorParada = {};

  for (var h in _viewModel.horarios) {

    final key =
        "${h['latitud']},${h['longitud']}";

    if (!horariosPorParada
        .containsKey(key)) {

      horariosPorParada[key] = [];
    }

    horariosPorParada[key]!.add(h);
  }

  // =====================================
  // SCAFFOLD PRINCIPAL
  // =====================================

  return Scaffold(

    drawer: _buildDrawer(),

    // =====================================
    // APPBAR
    // =====================================

    appBar: AppBar(

      automaticallyImplyLeading: false,

      elevation: 0,

      foregroundColor: Colors.white,

      flexibleSpace: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            colors: [

              Color(0xFF1565C0),

              Color(0xFF42A5F5),
            ],

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,
          ),
        ),
      ),

      title: const Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(
            Icons.directions_bus,
          ),

          SizedBox(
            width: 10,
          ),

          Text(

            "Transporte Rivera",

            style: TextStyle(

              fontWeight:
                  FontWeight.bold,

              letterSpacing: 0.5,
            ),
          ),
        ],
      ),

      centerTitle: true,

      actions: [

        Builder(

          builder: (context) {

            return Padding(

              padding:
                  const EdgeInsets.only(
                right: 10,
              ),

              child: IconButton(

                onPressed: () {

                  Scaffold.of(context)
                      .openDrawer();
                },

                icon:
                    const CircleAvatar(

                  radius: 18,

                  backgroundColor:
                      Colors.white,

                  child: Icon(

                    Icons.person,

                    color:
                        Colors.blueAccent,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),

    // =====================================
    // CONTENIDO
    // =====================================

    body: Stack(

      children: [

        FlutterMap(

  mapController: _mapController,

  options: MapOptions(

    initialCenter:
        position ??
        MapViewModel.defaultLocation,

    initialZoom: _zoom,
  ),

  children: [

    // =====================================
    // MAPA BASE
    // =====================================

    TileLayer(

      urlTemplate:
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    ),

    // =====================================
    // RUTA SELECCIONADA
    // =====================================

    PolylineLayer(

      polylines: [

        if (_viewModel.puntosRuta.isNotEmpty)

          Polyline(

            points:
                _viewModel.puntosRuta,

            strokeWidth: 5,

            color:
                _viewModel.colorRuta,
          ),
      ],
    ),

// =====================================
// MARCADORES
// =====================================

MarkerLayer(
  markers: [
    // ==========================
    // USUARIO
    // ==========================
    if (position != null)
      Marker(
        point: position,
        width: 40,
        height: 40,
        child: const Icon(
          Icons.my_location,
          color: Colors.red,
          size: 28,
        ),
      ),

    // ==========================
    // PARADAS (SIN CAJA)
    // ==========================
    ..._viewModel.paradas.map(
      (p) => Marker(
        point: LatLng(p.latitud, p.longitud),
        width: 35,
        height: 35,
        child: GestureDetector(
          onTap: () => _mostrarInfoParada(p),
          child: const Icon(
            Icons.directions_bus,
            color: Colors.blueAccent,
            size: 28,
          ),
        ),
      ),
    ),

    // ==========================
    // HORARIOS (RELOJ CON BADGE)
    // ==========================
    ...horariosPorParada.entries.map((entry) {
      final coords = entry.key.split(",");
      final lat = double.parse(coords[0]);
      final lng = double.parse(coords[1]);
      final lista = entry.value;

      return Marker(
        point: LatLng(lat, lng),
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blueAccent),
                    SizedBox(width: 10),
                    Text("Horarios"),
                  ],
                ),
                content: SizedBox(
                  width: 250,
                  child: ListView(
                    shrinkWrap: true,
                    children: lista.map((h) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.access_time,
                          color: Colors.blueAccent,
                          size: 18,
                        ),
                        title: Text(
                          h['hora'].toString().substring(0, 5),
                        ),
                        subtitle: Text(h['nombre'].toString()),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },

          // 🔥 BADGE DE RELOJ (VISIBLE PERO LIMPIO)
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_bus,
                color: Colors.deepPurple,
                size: 24,
              ),
              const SizedBox(height: 3),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }),
  ],
)
  ],
),
// =====================================
// BOTONES FLOTANTES
// =====================================

Positioned(

  right: 15,

  bottom: 20,

  child: Container(

    padding: const EdgeInsets.all(10),

    decoration: BoxDecoration(

      color: Colors.white,

      borderRadius:
          BorderRadius.circular(25),

      boxShadow: const [

        BoxShadow(

          color: Colors.black26,

          blurRadius: 10,

          offset: Offset(0, 3),
        ),
      ],
    ),

    child: Column(

      mainAxisSize: MainAxisSize.min,

      children: [

        // ==========================
        // IA PREMIUM
        // ==========================

        Tooltip(

          message:
              _planActual == "premium"
                  ? "Asistente IA"
                  : "Disponible solo para Premium",

          child: FloatingActionButton.small(

            heroTag: "ia",

            elevation: 0,

            backgroundColor:
                _planActual == "premium"
                    ? Colors.amber
                    : Colors.grey.shade400,

            onPressed:
                _planActual == "premium"

                    ? () {

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(

                          const SnackBar(

                            content: Text(
                              "Asistente IA activado",
                            ),
                          ),
                        );
                      }

                    : null,

            child: const Icon(

              Icons.auto_awesome,

              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        // ==========================
        // WATCH
        // ==========================

        Tooltip(

          message: "Modo Smartwatch",

          child: FloatingActionButton.small(

            heroTag: "watch",

            elevation: 0,

            backgroundColor:
                Colors.blueAccent,

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      const WatchScreen(),
                ),
              );
            },

            child: const Icon(

              Icons.watch,

              color: Colors.white,
            ),
          ),
        ),

        const Divider(),

        // ==========================
        // ZOOM +
        // ==========================

        Tooltip(

          message: "Acercar",

          child: FloatingActionButton.small(

            heroTag: "zoom_in",

            elevation: 0,

            backgroundColor:
                Colors.white,

            foregroundColor:
                Colors.blueAccent,

            onPressed: _zoomIn,

            child: const Icon(
              Icons.zoom_in,
            ),
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        // ==========================
        // ZOOM -
        // ==========================

        Tooltip(

          message: "Alejar",

          child: FloatingActionButton.small(

            heroTag: "zoom_out",

            elevation: 0,

            backgroundColor:
                Colors.white,

            foregroundColor:
                Colors.blueAccent,

            onPressed: _zoomOut,

            child: const Icon(
              Icons.zoom_out,
            ),
          ),
        ),
      ],
    ),
  ),
),
      ],
    ),
  );
}
}