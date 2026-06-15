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

            // Encabezado usuario

            Container(

              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.blue,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 45,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                
                  Text(
                    widget.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                        FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    widget.email,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(
                      _planActual.toUpperCase(),
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            ListTile(
              leading: const Icon(
                Icons.workspace_premium,
              ),
              title: const Text(
                "Plan actual",
              ),
              subtitle: Text(
                 _planActual,
              ),
            ),

            const Divider(),

Padding(

  padding:
      const EdgeInsets.all(16),

  child: SizedBox(

    width: double.infinity,

    child:
        _planActual == "free"

            ? ElevatedButton.icon(

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

                onPressed:
                    _mostrarCancelarPlan,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                  foregroundColor:
                      Colors.white,
                ),

                icon: const Icon(
                  Icons.cancel,
                ),

                label: const Text(
                  "Cancelar Premium",
                ),
              ),
  ),
),

ListTile(

  leading: const Icon(
    Icons.delete_forever,
    color: Colors.red,
  ),

  title: const Text(

    "Eliminar cuenta",

    style: TextStyle(
      color: Colors.red,
    ),
  ),

  onTap: () {

    Navigator.pop(context);

    _confirmarEliminarCuenta();
  },
),

const Divider(),

            const Spacer(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .popUntil(
                  (route) => route.isFirst,
                );
              },
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

  loadingVM.mostrar(
    "Calculando ruta...",
  );

  await _viewModel.obtenerRutaHastaParada(
    LatLng(
      parada.latitud,
      parada.longitud,
    ),
  );

  loadingVM.actualizarMensaje(
    "Cargando rutas...",
  );

  final rutas =
      await _viewModel
          .obtenerRutasDeParada(
    parada.id,
  );

  loadingVM.ocultar();

  if (!mounted) return;

  showDialog(

    context: context,

    builder: (_) => AlertDialog(

      title: Text(
        parada.nombre,
      ),

      content: rutas.isEmpty

          ? const Text(
              "Sin rutas disponibles",
            )

          : SizedBox(

              width: double.maxFinite,

              child: ListView(

                shrinkWrap: true,

                children:
                    rutas.map<Widget>((r) {

                  return ListTile(

                    leading: const Icon(
                      Icons.directions_bus,
                    ),

                    title: Text(
                      "- ${r['ruta']}",
                    ),

                    subtitle: Text(
                      "${r['empresa']} • ${r['matricula']}",
                    ),

                    onTap: () async {

                      Navigator.pop(
                        context,
                      );

                      loadingVM.mostrar(
                        "Cargando ruta...",
                      );

                      final idRuta =
                          int.parse(
                        r['id']
                            .toString(),
                      );

                      await _viewModel
                          .obtenerRutaPorId(
                        idRuta,
                        r['ruta']
                            .toString(),
                      );

                      loadingVM
                          .actualizarMensaje(
                        "Cargando horarios...",
                      );

                      await _viewModel
                          .obtenerHorariosRuta(
                        idRuta,
                      );

                      loadingVM.ocultar();
                    },
                  );
                }).toList(),
              ),
            ),

      actions: [

        TextButton(

          onPressed: () {

            loadingVM.ocultar();

            Navigator.pop(
              context,
            );

            setState(() {});
          },

          child: const Text(
            "Cerrar",
          ),
        ),
      ],
    ),
  );
}

// =====================================
// BUILD
// =====================================

@override
Widget build(BuildContext context) {

  // Pantalla de carga inicial

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

    // Sidebar del usuario

    drawer: _buildDrawer(),

    // =====================================
    // APPBAR
    // =====================================

    appBar: AppBar(

  automaticallyImplyLeading: false,

  title: const Text(
    "Mapa",
  ),

  centerTitle: true,

  backgroundColor: Colors.blue,

  foregroundColor: Colors.white,

  actions: [

    Builder(
      builder: (context) {
        return IconButton(

          onPressed: () {
            Scaffold.of(context).openDrawer();
          },

          icon: const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,

            child: Icon(
              Icons.person,
              color: Colors.blue,
              size: 20,
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

    TileLayer(
      urlTemplate:
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    ),

    // ==========================
    // RUTA
    // ==========================

    PolylineLayer(

      polylines: [

        if (_viewModel.puntosRuta.isNotEmpty)

          Polyline(

            points:
                _viewModel.puntosRuta,

            strokeWidth: 4,

            color:
                _viewModel.colorRuta,
          ),
      ],
    ),

    // ==========================
    // MARCADORES
    // ==========================

    MarkerLayer(

      markers: [

        if (position != null)

          Marker(

            point: position,

            width: 50,

            height: 50,

            child: const Icon(
              Icons.person_pin_circle,
              color: Colors.red,
              size: 40,
            ),
          ),

        ..._viewModel.paradas.map(
          (p) => Marker(

            point: LatLng(
              p.latitud,
              p.longitud,
            ),

            width: 40,

            height: 40,

            child: GestureDetector(

              onTap: () =>
                  _mostrarInfoParada(p),

              child: const Icon(
                Icons.directions_bus,
                color: Colors.purple,
              ),
            ),
          ),
        ),

        ...horariosPorParada.entries
            .map((entry) {

          final coords =
              entry.key.split(",");

          final lat =
              double.parse(coords[0]);

          final lng =
              double.parse(coords[1]);

          final lista =
              entry.value;

          return Marker(

            point: LatLng(
              lat,
              lng,
            ),

            width: 90,

            height: 90,

            child: GestureDetector(

              onTap: () {

                showDialog(

                  context: context,

                  builder: (_) =>
                      AlertDialog(

                    title:
                        const Text(
                      "Horarios",
                    ),

                    content:
                        SizedBox(

                      width: 200,

                      child: ListView(

                        shrinkWrap: true,

                        children:
                            lista.map((h) {

                          return ListTile(

                            title: Text(

                              h['hora']
                                  .toString()
                                  .substring(
                                    0,
                                    5,
                                  ),
                            ),

                            subtitle: Text(
                              h['nombre'],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },

              child: Column(

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  Container(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),

                    decoration:
                        BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),

                      boxShadow: const [

                        BoxShadow(
                          color:
                              Colors.black26,
                          blurRadius: 4,
                        ),
                      ],
                    ),

                    child: Text(

                      "${lista.length} horarios",

                      style:
                          const TextStyle(

                        fontSize: 10,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Icon(

                    Icons.directions_bus,

                    color:
                        _viewModel.colorRuta,

                    size: 30,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  ],
),
        // =====================================
// BOTONES FLOTANTES
// =====================================

Positioned(

  right: 10,

  bottom: 20,

  child: Column(

    children: [

      // ==========================
      // IA
      // ==========================

      FloatingActionButton(

        heroTag: "ia",

        backgroundColor:
            _planActual ==
                    "premium"
                ? Colors.white
                : Colors.black87,

        elevation: 8,

        onPressed:
            _planActual ==
                    "premium"

                ? () {

                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(

                      const SnackBar(

                        content: Text(
                          "Asistente IA activado",
                        ),
                      ),
                    );
                  }

                : null,

        child: Icon(

          Icons.auto_awesome,

          color:
              _planActual ==
                      "premium"
                  ? Colors.black
                  : Colors.white,
        ),
      ),

      const SizedBox(
        height: 10,
      ),

      // ==========================
      // WATCH
      // ==========================

      FloatingActionButton(

        heroTag: "watch",

        backgroundColor:
            Colors.black,

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

      const SizedBox(
        height: 10,
      ),

      // ==========================
      // ZOOM +
      // ==========================

      FloatingActionButton(

        heroTag: "zoom_in",

        onPressed: _zoomIn,

        child: const Icon(
          Icons.zoom_in,
        ),
      ),

      const SizedBox(
        height: 10,
      ),

      // ==========================
      // ZOOM -
      // ==========================

      FloatingActionButton(

        heroTag: "zoom_out",

        onPressed: _zoomOut,

        child: const Icon(
          Icons.zoom_out,
        ),
      ),
    ],
  ),
),
      ],
    ),
  );
}
}