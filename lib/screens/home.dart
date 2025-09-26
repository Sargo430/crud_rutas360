import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '¿Que acción quieres realizar?',
              style: TextStyle(fontSize: 24),
            ),
            // ...existing code...
            SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Card(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Rutas",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      FilledButton(
                                        onPressed: () {
                                          context.go('/rutas/create');
                                        },
                                        style: FilledButton.styleFrom(
                                          minimumSize: Size(
                                            double.infinity,
                                            50,
                                          ),
                                          backgroundColor: Color(0xFF4D67AE),
                                        ),
                                        child: Text("Crear nueva Ruta"),
                                      ),
                                      SizedBox(height: 16),
                                      FilledButton(
                                        onPressed: () {
                                          context.go('/rutas');
                                        },
                                        style: FilledButton.styleFrom(
                                          minimumSize: Size(
                                            double.infinity,
                                            50,
                                          ),
                                          backgroundColor: Color(0xFF4D67AE),
                                        ),
                                        child: Text("Ver Rutas"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: Card(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Puntos de Interés",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      FilledButton(
                                        onPressed: () {},
                                        style: FilledButton.styleFrom(
                                          minimumSize: Size(
                                            double.infinity,
                                            50,
                                          ),
                                          backgroundColor: Color(0xFF4D67AE),
                                        ),
                                        child: Text("Crear nuevo punto"),
                                      ),
                                      SizedBox(height: 16),
                                      FilledButton(
                                        onPressed: () {},
                                        style: FilledButton.styleFrom(
                                          minimumSize: Size(
                                            double.infinity,
                                            50,
                                          ),
                                          backgroundColor: Color(0xFF4D67AE),
                                        ),
                                        child: Text("Ver puntos de interés"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Categorías",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      FilledButton(
                                        onPressed: () {},
                                        style: FilledButton.styleFrom(
                                          minimumSize: Size(
                                            double.infinity,
                                            50,
                                          ),
                                          backgroundColor: Color(0xFF4D67AE),
                                        ),
                                        child: Text("Crear nueva categoría"),
                                      ),
                                      SizedBox(height: 16),
                                      FilledButton(
                                        onPressed: () {},
                                        style: FilledButton.styleFrom(
                                          minimumSize: Size(
                                            double.infinity,
                                            50,
                                          ),
                                          backgroundColor: Color(0xFF4D67AE),
                                        ),
                                        child: Text("Ver Categorías"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: Card(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Categorías",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      FilledButton(
                                        onPressed: () {},
                                        style: FilledButton.styleFrom(
                                          minimumSize: Size(
                                            double.infinity,
                                            50,
                                          ),
                                          backgroundColor: Color(0xFF4D67AE),
                                        ),
                                        child: Text("Crear nueva actividad"),
                                      ),
                                      SizedBox(height: 16),
                                      FilledButton(
                                        onPressed: () {},
                                        style: FilledButton.styleFrom(
                                          minimumSize: Size(
                                            double.infinity,
                                            50,
                                          ),
                                          backgroundColor: Color(0xFF4D67AE),
                                        ),
                                        child: Text("Ver actividades"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
