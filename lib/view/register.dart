import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prototipo/view/loading.dart';
import 'package:prototipo/view/map.dart';
import 'package:prototipo/view/TermsAndPrivacyScreen.dart';
import 'package:prototipo/viewmodel/loading_viewmodel.dart';
import 'package:prototipo/viewmodel/map_viewmodel.dart';
import 'package:prototipo/viewmodel/register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  Position? userPosition;

  bool locationAccepted = false;
  bool locationLoading = false;

  String locationStatus =
      "Ubicación no obtenida";

  bool acceptedTerms = false;

  String selectedPlan = "free";

  @override
  void dispose() {

    _nameController.dispose();

    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _getLocation() async {

    setState(() {
      locationLoading = true;
    });

    try {

      bool serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {

        setState(() {

          locationStatus =
              'Servicio de ubicación desactivado';

          locationLoading = false;
        });

        return;
      }

      LocationPermission permission =
          await Geolocator
              .checkPermission();

      if (permission ==
          LocationPermission.denied) {

        permission =
            await Geolocator
                .requestPermission();
      }

      if (permission ==
          LocationPermission.denied) {

        setState(() {

          locationStatus =
              'Permiso de ubicación denegado';

          locationLoading = false;
        });

        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {

        setState(() {

          locationStatus =
              'Permiso de ubicación denegado permanentemente';

          locationLoading = false;
        });

        return;
      }

      Position position =
          await Geolocator
              .getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high,
      );

      setState(() {

        userPosition = position;

        locationStatus =
            'Ubicación obtenida correctamente';

        locationLoading = false;
      });

    } catch (e) {

      setState(() {

        locationStatus =
            'Error al obtener ubicación';

        locationLoading = false;
      });
    }
  }

  Future<void> _registrarUsuario() async {

    if (!acceptedTerms) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(

            'Debe aceptar los Términos de Uso y la Política de Privacidad',
          ),
        ),
      );

      return;
    }

    final viewModel =
        RegisterViewModel();

    bool ok =
        await viewModel.registrar(

      _nameController.text,

      _emailController.text,

      _passwordController.text,

      selectedPlan,
    );

    if (!mounted) return;

    if (!ok) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(

            viewModel.error ??
                'Error al registrar',
          ),
        ),
      );

      return;
    }

    final loadingVM =
        LoadingViewModel();

    loadingVM.mostrar(
      "Creando cuenta...",
    );

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            LoadingScreen(

          viewModel: loadingVM,

          textColor: Colors.black,
        ),
      ),
    );

    await Future.delayed(
      const Duration(seconds: 1),
    );

    loadingVM.actualizarMensaje(
      "Cargando mapa...",
    );

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) => MapScreen(

          viewModel: MapViewModel(),

          plan: selectedPlan,

          nombre:
              _nameController.text
                  .trim(),

          email:
              _emailController.text
                  .trim(),

          idUsuario:
              viewModel.idUsuario,
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1565C0),
            Color(0xFF42A5F5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 550,
              ),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [

                      // ================= VOLVER =================

                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      // ================= ICONO =================

                      const Icon(
                        Icons.person_add_alt_1,
                        size: 70,
                        color: Colors.blueAccent,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Crear Cuenta",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        "Completa tus datos para registrarte",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ================= NOMBRE =================

                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon:
                              const Icon(Icons.person),
                          filled: true,
                          fillColor:
                              Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= EMAIL =================

                      TextField(
                        controller: _emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText:
                              'Correo electrónico',
                          prefixIcon:
                              const Icon(Icons.email),
                          filled: true,
                          fillColor:
                              Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= PASSWORD =================

                      TextField(
                        controller:
                            _passwordController,
                        obscureText:
                            _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon:
                              const Icon(Icons.lock),
                          filled: true,
                          fillColor:
                              Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    15),
                          ),
                          suffixIcon:
                              IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons
                                      .visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ================= TÉRMINOS =================

                      Card(
                        elevation: 6,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                                  15),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Checkbox(
                                value:
                                    acceptedTerms,
                                onChanged: (value) {
                                  setState(() {
                                    acceptedTerms =
                                        value ??
                                            false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 12,
                                  ),
                                  child: Wrap(
                                    children: [
                                      const Text(
                                        "He leído y acepto los ",
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const TermsAndPrivacyScreen(),
                                            ),
                                          );
                                        },
                                        child:
                                            const Text(
                                          "Términos de Uso y Política de Privacidad",
                                          style:
                                              TextStyle(
                                            color:
                                                Colors
                                                    .blue,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            decoration:
                                                TextDecoration
                                                    .underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ================= PLANES =================

                      Card(
  elevation: 6,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Row(
          children: [
            Icon(
              Icons.workspace_premium,
              color: Colors.amber,
            ),
            SizedBox(width: 10),
            Text(
              "Selecciona tu plan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        RadioListTile<String>(
          value: "free",
          groupValue: selectedPlan,
          activeColor: Colors.blueAccent,
          onChanged: (value) {
            setState(() {
              selectedPlan = value!;
            });
          },
          title: const Text(
            "Plan Free",
          ),
          subtitle: const Text(
            "Acceso a mapas, rutas y paradas",
          ),
        ),

        RadioListTile<String>(
          value: "premium",
          groupValue: selectedPlan,
          activeColor: Colors.blueAccent,
          onChanged: (value) {
            setState(() {
              selectedPlan = value!;
            });
          },
          title: const Text(
            "Plan Premium",
          ),
          subtitle: const Text(
            "Incluye asistente IA",
          ),
        ),

        if (selectedPlan == "premium") ...[

          const Divider(),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              children: [

                Row(
                  children: [
                    Icon(Icons.auto_awesome),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Consultas inteligentes mediante IA",
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.route),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Búsqueda de rutas usando lenguaje natural",
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Información avanzada del transporte",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.orange,
              ),
            ),
            child: const Text(
              "\$4.99 USD / mes",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ],
    ),
  ),
),

                      const SizedBox(height: 25),

                      // ================= UBICACIÓN =================

                      Card(
  elevation: 6,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [

          const Icon(
            Icons.location_on,
            size: 60,
            color: Colors.blueAccent,
          ),

          const SizedBox(height: 10),

          const Text(
            "Permitir acceso a tu ubicación",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Esto permitirá mostrar rutas y paradas cercanas.",
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15),

          CheckboxListTile(
            value: locationAccepted,
            activeColor: Colors.blueAccent,
            controlAffinity:
                ListTileControlAffinity.leading,
            title: const Text(
              "Acepto compartir mi ubicación",
            ),
            secondary: const Icon(
              Icons.my_location,
              color: Colors.blueAccent,
            ),
            onChanged: (value) {
              setState(() {
                locationAccepted =
                    value ?? false;
              });

              if (locationAccepted) {
                _getLocation();
              } else {
                setState(() {
                  userPosition = null;
                  locationStatus =
                      "Ubicación no obtenida";
                });
              }
            },
          ),

          if (locationLoading)
            const Padding(
              padding: EdgeInsets.all(15),
              child:
                  CircularProgressIndicator(),
            ),

          if (!locationLoading)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 8,
              ),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: userPosition != null
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(
                          10),
                ),
                child: Text(
                  locationStatus,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w500,
                    color: userPosition != null
                        ? Colors.green
                        : Colors.grey[700],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  ),
),

                      const SizedBox(height: 30),

                      // ================= BOTÓN =================

                      SizedBox(
                        height: 55,
                        child:
                            ElevatedButton.icon(
                          icon: const Icon(
                            Icons.person_add,
                          ),
                          label: const Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors
                                    .blueAccent,
                            foregroundColor:
                                Colors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          15),
                            ),
                          ),
                          onPressed:
                              acceptedTerms
                                  ? _registrarUsuario
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}