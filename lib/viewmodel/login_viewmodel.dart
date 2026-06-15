import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginViewModel extends ChangeNotifier {

  bool loading = false;

  String? error;

  int idUsuario = 0;
  String nombre = "";
  String email = "";
  String plan = "free";

  final String API_URL = "http://localhost/api_prototipo";



  // ================= LOGIN =================

  Future<bool> login(
  String userEmail,
  String password,
) async {

  if (
      userEmail.isEmpty ||
      password.isEmpty) {

    error =
        "Todos los campos son obligatorios";

    notifyListeners();

    return false;
  }

  loading = true;

  error = null;

  notifyListeners();

  try {

    final response =
        await http.post(

      Uri.parse("${API_URL}/login.php"),

      headers: {
        "Content-Type":
            "application/json; charset=UTF-8",
      },

      body: jsonEncode({

        "email":
            userEmail.trim(),

        "password":
            password.trim(),
      }),
    );

    final data =
        jsonDecode(response.body);

    if (data["success"] == true) {

  idUsuario =
    int.tryParse(
      data["id"].toString(),
    ) ?? 0;

nombre =
    data["nombre"]
        ?.toString() ?? "";

email =
    data["email"]
        ?.toString() ?? "";

plan =
    data["plan"]
        ?.toString() ?? "free";

  return true;
} else {

      error =
          data["message"] ??
          "Error en login";

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

  // ================= RECUPERAR PASSWORD =================

  Future<bool> recuperarPassword(
      String email) async {

    if (email.isEmpty) {

      error =
          "Ingrese un correo";

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
          "${API_URL}/recuperar_password.php"
        ),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode({
          "email": email.trim(),
        }),
      );

      final data =
          jsonDecode(response.body);

      if (data["success"] == true) {

        return true;

      } else {

        error =
            data["message"] ??
            "Error";

        return false;
      }

    } catch (e) {

      error =
          "Error de conexión";

      return false;

    } finally {

      loading = false;

      notifyListeners();
    }
  }

  Future<bool> actualizarPlan(
  int idUsuario,
  String plan,
) async {

  try {

    final response = await http.post(

      Uri.parse(
        "${API_URL}/actualizar_plan.php",
      ),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({

        "id": idUsuario,

        "plan": plan,
      }),
    );

    final data =
        jsonDecode(response.body);

    if (data["success"] == true) {

      this.plan = plan;

      notifyListeners();

      return true;
    }

    error = data["message"];

    return false;

  } catch (e) {

    error = "Error de conexión";

    return false;
  }
}

}

