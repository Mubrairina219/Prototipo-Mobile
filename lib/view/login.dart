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

  void _confirmarEliminarCuenta() {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool obscurePassword = true;

  showDialog(

    context: context,

    builder: (dialogContext) {

      return StatefulBuilder(

        builder: (
          context,
          setDialogState,
        ) {

          return AlertDialog(

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            title: Row(

              children: const [

                Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),

                SizedBox(
                  width: 10,
                ),

                Text(
                  "Eliminar cuenta",
                ),
              ],
            ),

            content: SizedBox(

              width: 350,

              child: SingleChildScrollView(

                child: Column(

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    const Text(
                      "Para eliminar tu cuenta ingresa tus credenciales. Esta acción es permanente y no podrá deshacerse.",
                      textAlign:
                          TextAlign.center,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    TextField(

                      controller:
                          emailController,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Correo electrónico",

                        border:
                            OutlineInputBorder(),

                        prefixIcon:
                            Icon(
                          Icons.email,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    TextField(

                      controller:
                          passwordController,

                      obscureText:
                          obscurePassword,

                      decoration:
                          InputDecoration(

                        labelText:
                            "Contraseña",

                        border:
                            const OutlineInputBorder(),

                        prefixIcon:
                            const Icon(
                          Icons.lock,
                        ),

                        suffixIcon:
                            IconButton(

                          icon: Icon(

                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),

                          onPressed: () {

                            setDialogState(() {

                              obscurePassword =
                                  !obscurePassword;

                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
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

                        "Entiendo que la eliminación de la cuenta es irreversible y que perderé todos mis datos.",

                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),

                      onChanged: (
                        value,
                      ) {

                        setDialogState(() {

                          aceptaEliminacion =
                              value ?? false;

                        });
                      },
                    ),
                  ],
                ),
              ),
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

                            final email =
                                emailController.text
                                    .trim();

                            final password =
                                passwordController
                                    .text
                                    .trim();

                            if (
                                email.isEmpty ||
                                password.isEmpty) {

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(

                                const SnackBar(
                                  content: Text(
                                    "Complete todos los campos",
                                  ),
                                ),
                              );

                              return;
                            }

                            final ok =
                                await loginVM
                                    .eliminarCuenta(
                              email,
                              password,
                            );

                            if (!mounted)
                              return;

                            Navigator.pop(
                              dialogContext,
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(

                              SnackBar(

                                content: Text(

                                  ok
                                      ? "Cuenta eliminada correctamente"
                                      : loginVM.error ??
                                          "Error",
                                ),
                              ),
                            );

                            if (ok) {

                              _emailController
                                  .clear();

                              _passwordController
                                  .clear();
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

              const SizedBox(
                height: 5,
              ),

              TextButton.icon(
                onPressed:
                  _confirmarEliminarCuenta,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                    ),
                  label: const Text(
                    "Eliminar cuenta",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );  
  }
}