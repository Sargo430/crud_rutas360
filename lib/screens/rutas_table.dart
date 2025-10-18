import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/route_event.dart';
import 'package:crud_rutas360/states/route_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crud_rutas360/widgets/loading_message.dart';

class TablaRutas extends StatefulWidget {
  const TablaRutas({super.key});

  @override
  State<TablaRutas> createState() => _TablaRutasState();
}

class _TablaRutasState extends State<TablaRutas> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<RouteBloc>();
    if (bloc.state is! RouteLoaded && bloc.state is! RouteLoading) {
      // OPTIMIZACION: evitamos recargar rutas si ya existe una peticion en curso o datos listos.
      bloc.add(LoadRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        if (state is RouteLoaded) {
          // Alturas
          const double rowHeight = 56.0;
          const double headerHeight = 50.0;
          final double tableHeight =
              headerHeight + (state.routes.length * rowHeight);

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Rutas",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Gestiona las rutas del sistema",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/rutas/create');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Crear Ruta",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D67AE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Tabla ajustada al tamaño de las filas
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: SizedBox(
                    width: double.infinity,
                    height: tableHeight,
                    child: DataTableTheme(
                      data: DataTableThemeData(
                        headingRowHeight: headerHeight,
                        dataRowMinHeight: rowHeight,
                        dataRowMaxHeight: rowHeight,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF3F4F6),
                        ),
                      ),
                      child: DataTable(
                        columnSpacing: 24,
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            width: 0.3,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        columns: const [
                          DataColumn(label: Text("Nombre")),
                          DataColumn(label: Text("Latitud inicio")),
                          DataColumn(label: Text("Longitud inicio")),
                          DataColumn(label: Text("Latitud fin")),
                          DataColumn(label: Text("Longitud fin")),
                          DataColumn(label: Text("Puntos de interés")),
                          DataColumn(label: Text("Acciones")),
                        ],
                        rows: state.routes.map((route) {
                          return DataRow(
                            cells: [
                              DataCell(Text(route.name)),
                              DataCell(Text(route.initialLatitude.toStringAsFixed(5))),
                              DataCell(Text(route.initialLongitude.toStringAsFixed(5))),
                              DataCell(Text(route.finalLatitude.toStringAsFixed(5))),
                              DataCell(Text(route.finalLongitude.toStringAsFixed(5))),
                              DataCell(Text(
                                route.pois.map((e) => e.nombre).join(', '),
                                overflow: TextOverflow.ellipsis,
                              )),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    tooltip: "Editar",
                                    icon: const Icon(Icons.edit, color: Color(0xFF4D67AE)),
                                    onPressed: () {
                                      context.go('/rutas/edit/${route.id}', extra: route);
                                    },
                                  ),
                                  IconButton(
                                    tooltip: "Eliminar",
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () {
                                      fnDeleteRoute(route.id, context);
                                    },
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const LoadingMessage();
        }
      },
    );
  }

  void fnDeleteRoute(String id, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Estás seguro de que deseas eliminar esta ruta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<RouteBloc>(context).add(DeleteRoute(id));
              Navigator.of(context).pop();
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}


