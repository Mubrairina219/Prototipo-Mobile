import 'dart:async';
import 'package:flutter/material.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({
    super.key,
  });

  @override
  State<WatchScreen> createState() =>
      _WatchScreenState();
}

class _WatchScreenState
    extends State<WatchScreen> {

  late Timer _timer;

  DateTime _horaActual =
      DateTime.now();

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        setState(() {
          _horaActual = DateTime.now();
        });
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get hora {

    final h = _horaActual.hour
        .toString()
        .padLeft(2, '0');

    final m = _horaActual.minute
        .toString()
        .padLeft(2, '0');

    final s = _horaActual.second
        .toString()
        .padLeft(2, '0');

    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Modo Reloj",
        ),
      ),

      body: Center(

        child: ClipOval(

          child: Container(

            width: 250,
            height: 250,

            color: Colors.black,

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                Text(
                  hora,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Icon(
                  Icons.directions_bus,
                  size: 50,
                  color: Colors.blue,
                ),

                const SizedBox(
                  height: 20,
                ),

                ElevatedButton.icon(

                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },

                  icon: const Icon(
                    Icons.map,
                  ),

                  label: const Text(
                    "Mapa",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}