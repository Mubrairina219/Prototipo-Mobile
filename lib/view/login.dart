import 'package:flutter/material.dart';
import 'package:prototipo/view/loading.dart';
import 'package:prototipo/view/map.dart';
import 'package:prototipo/viewmodel/loading_viewmodel.dart';
import 'package:prototipo/viewmodel/login_viewmodel.dart';
import 'package:prototipo/viewmodel/map_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool aceptaEliminacion = false;

  final LoginViewModel loginVM =
      LoginViewModel();

  @override
    void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();
  }


  void _mostrarRecuperarPassword() {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(
              Icons.lock_reset,
              color: Colors.blueAccent,
            ),
            SizedBox(width: 10),
            Text(
              "Recuperar contraseña",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.email,
                    size: 40,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Se enviará una nueva contraseña al correo:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _emailController.text.trim().isEmpty
                        ? "Ingrese un correo electrónico"
                        : _emailController.text.trim(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
            label: const Text("Cancelar"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Enviar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final ok =
                  await loginVM.recuperarPassword(
                _emailController.text.trim(),
              );

              if (!mounted) return;

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor:
                      ok ? Colors.green : Colors.red,
                  content: Text(
                    ok
                        ? "Nueva contraseña enviada correctamente"
                        : loginVM.error ?? "Error",
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

  Future<void> _iniciarSesion() async {

    final ok =
        await loginVM.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!ok || !mounted) return;

    final loadingVM =
        LoadingViewModel();

    loadingVM.mostrar(
      "Cargando mapa...",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LoadingScreen(
          viewModel: loadingVM,
          textColor:
              Colors.black,
        ),
      ),
    );

    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
        viewModel: MapViewModel(),
        plan: loginVM.plan,
        nombre: loginVM.nombre,
        email: loginVM.email, 
        idUsuario: loginVM.idUsuario,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: 220,
                      height: 180,
                      child: Image.asset(
                        'assets/acceso.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
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

                    const SizedBox(height: 15),

                    AnimatedBuilder(
                      animation: loginVM,
                      builder: (context, _) {
                        if (loginVM.error == null) {
                          return const SizedBox();
                        }

                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Text(
                            loginVM.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: AnimatedBuilder(
                        animation: loginVM,
                        builder: (context, _) {
                          return ElevatedButton.icon(
                            icon: const Icon(Icons.login),
                            label: loginVM.loading
                                ? const Text("Cargando...")
                                : const Text(
                                    "Iniciar Sesión",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blueAccent,
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        15),
                              ),
                            ),
                            onPressed:
                                loginVM.loading
                                    ? null
                                    : _iniciarSesion,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextButton.icon(
                      onPressed:
                          _mostrarRecuperarPassword,
                      icon: const Icon(
                        Icons.lock_reset,
                      ),
                      label: const Text(
                        "Olvidé mi contraseña",
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
  ); 
  }
}