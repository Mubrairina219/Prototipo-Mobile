import 'package:flutter/material.dart';
import 'package:prototipo/viewmodel/loading_viewmodel.dart';

class LoadingScreen extends StatefulWidget {
  final LoadingViewModel viewModel;
  final Color textColor;

  const LoadingScreen({
    super.key,
    required this.viewModel,
    this.textColor = Colors.white,
  });

  @override
  State<LoadingScreen> createState() =>
      _LoadingScreenState();
}

class _LoadingScreenState
    extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {

    return Center(
      child: AnimatedBuilder(
        animation: widget.viewModel,

        builder: (context, _) {

          return Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              const Icon(
                Icons.directions_bus,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              CircularProgressIndicator(
                color: widget.textColor,
              ),

              const SizedBox(height: 20),

              Text(
                widget.viewModel.mensaje,

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      widget.textColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}