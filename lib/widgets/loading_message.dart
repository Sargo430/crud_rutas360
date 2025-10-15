import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar spinner con un mensaje uniforme.
class LoadingMessage extends StatelessWidget {
  final String message;
  const LoadingMessage({
    super.key,
    this.message = 'Cargando, por favor espere...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
