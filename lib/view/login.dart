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

          title: const Text(
            "Recuperar contraseña",
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [

              const Text(
                "Se enviará una nueva contraseña al correo:",
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                _emailController.text.trim(),
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                "Cancelar",
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                final ok =
                    await loginVM
                        .recuperarPassword(
                  _emailController.text
                      .trim(),
                );

                if (!mounted) return;

                Navigator.pop(
                  context,
                );

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? "Nueva contraseña enviada"
                          : loginVM.error ??
                              "Error",
                    ),
                  ),
                );
              },
              child: const Text(
                "Enviar",
              ),
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
  Widget build(
      BuildContext context) {

      return Scaffold(

        appBar: AppBar(
          title: const Text(
            'Iniciar Sesión',
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          foregroundColor:Colors.white,
        ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(
                width: 300,
                height: 200,
                child: Image.asset(
                  'assets/acceso.png',
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width: 300,
                child: TextField(
                  controller:
                      _emailController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Correo Electrónico',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width: 300,
                child: TextField(
                  controller:
                      _passwordController,
                  obscureText:
                      _obscurePassword,
                  decoration:
                      InputDecoration(
                    labelText:
                        'Contraseña',
                    border:
                        const OutlineInputBorder(),
                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons
                                .visibility
                            : Icons
                                .visibility_off,
                      ),
                      onPressed:
                          () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              AnimatedBuilder(
                animation: loginVM,
                builder:
                    (context, _) {

                  if (loginVM.error ==
                      null) {

                    return const SizedBox();
                  }

                  return Text(
                    loginVM.error!,
                    style:
                        const TextStyle(
                      color:
                          Colors.red,
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 10,
              ),

              SizedBox(
                width: 200,
                height: 50,
                child:
                    AnimatedBuilder(
                  animation:
                      loginVM,
                  builder:
                      (context, _) {

                    return ElevatedButton(

                      onPressed:
                          loginVM.loading
                              ? null
                              : _iniciarSesion,

                      child:
                          loginVM.loading
                              ? const CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                )
                              : const Text(
                                  'Iniciar Sesión',
                                ),
                    );
                  },
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              TextButton(
                onPressed:
                  _mostrarRecuperarPassword,
                  child: const Text(
                    "Olvidé mi contraseña",
                    ),
                  ),
            ],
          ),
        ),
      ),
    );  
  }
}