import 'package:flutter/material.dart';

/// Pantalla informativa para bloquear dispositivos moviles.
class DesktopOnlyMessage extends StatelessWidget {
  final String message;
  const DesktopOnlyMessage({
    super.key,
    this.message =
        'Esta aplicaci\u00f3n solo est\u00e1 disponible en escritorio.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
