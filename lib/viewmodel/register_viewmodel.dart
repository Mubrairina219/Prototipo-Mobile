import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterViewModel extends ChangeNotifier {

  bool loading = false;

  String? error;

  int idUsuario = 0;

  final String API_URL =
      "http://localhost/api_prototipo";

  Future<bool> registrar(
    String nombre,
    String email,
    String password,
    String plan,
  ) async {

    if (
      nombre.isEmpty ||
      email.isEmpty ||
      password.isEmpty ||
      plan.isEmpty
    ) {

      error =
          "Todos los campos son obligatorios";

      notifyListeners();

      return false;
    }

    if (!email.contains("@")) {

      error = "Correo inválido";

      notifyListeners();

      return false;
    }

    if (
      !RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$'
      ).hasMatch(password)
    ) {

      error =
          "La contraseña debe tener al menos 8 caracteres, incluyendo letras y números";

      notifyListeners();

      return false;
    }

    loading = true;

    error = null;

    notifyListeners();

    try {

      final response =
          await http.post(

        Uri.parse(
          '$API_URL/registrar_pasajero.php',
        ),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "nombre":
              nombre.trim(),

          "email":
              email.trim(),

          "contraseña":
              password.trim(),

          "plan":
              plan.trim(),
        }),
      );

      final data =
          jsonDecode(response.body);

      if (data["success"] == true) {

        idUsuario =
            int.parse(
              data["id_usuario"].toString(),
            );

        return true;

      } else {

        error =
            data["message"] ??
            "Error al registrar";

        return false;
      }

    } catch (e) {

      print(e);

      error =
          "No se pudo conectar al servidor";

      return false;

    } finally {

      loading = false;

      notifyListeners();
    }
  }
}