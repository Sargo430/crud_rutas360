import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color mainColor = const Color(0xFF4D67AE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Bienvenido al sistema de gestión CRUD Rutas 360",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),

            // GRID RESPONSIVO
            LayoutBuilder(
              builder: (context, constraints) {
                // Calcular cuántas columnas mostrar según ancho disponible
                int crossAxisCount = 1;
                if (constraints.maxWidth >= 1000) {
                  crossAxisCount = 4; // Escritorio
                } else if (constraints.maxWidth >= 600) {
                  crossAxisCount = 2; // Tablet
                }

                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.2, // Proporción de la card
                  ),
                  children: [
                    _buildDashboardCard(
                      icon: Icons.map,
                      title: "Rutas",
                      subtitle: "Crea y gestiona rutas del sistema",
                      onTap: () => context.go('/rutas'),
                    ),
                    _buildDashboardCard(
                      icon: Icons.place,
                      title: "POIs",
                      subtitle: "Administra puntos de interés",
                      onTap: () => context.go('/pois'),
                    ),
                    _buildDashboardCard(
                      icon: Icons.category,
                      title: "Categorías",
                      subtitle: "Organiza por categorías",
                      onTap: () => context.go('/categorias'),
                    ),
                    _buildDashboardCard(
                      icon: Icons.directions_walk,
                      title: "Actividades",
                      subtitle: "Gestiona actividades disponibles",
                      onTap: () => context.go('/actividades'),
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

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Ícono alineado a la izquierda
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: mainColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
