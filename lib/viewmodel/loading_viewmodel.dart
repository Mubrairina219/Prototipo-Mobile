import 'package:flutter/material.dart';

class LoadingViewModel extends ChangeNotifier {

  bool _loading = false;
  String _mensaje = "Cargando...";

  bool get loading => _loading;
  String get mensaje => _mensaje;

  void mostrar([String mensaje = "Cargando..."]) {
    _mensaje = mensaje;
    _loading = true;
    notifyListeners();
  }

  void ocultar() {
    _loading = false;
    notifyListeners();
  }

  void actualizarMensaje(String mensaje) {
    _mensaje = mensaje;
    notifyListeners();
  }
}