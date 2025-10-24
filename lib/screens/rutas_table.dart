import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/route_event.dart';
import 'package:crud_rutas360/states/route_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crud_rutas360/widgets/loading_message.dart';

// 👇 Importa el bloc/estado de POI para escuchar éxitos y refrescar rutas
import 'package:crud_rutas360/blocs/poi_bloc.dart';
import 'package:crud_rutas360/states/poi_state.dart';

class TablaRutas extends StatefulWidget {
  const TablaRutas({super.key});

  @override
  State<TablaRutas> createState() => _TablaRutasState();
}

class _TablaRutasState extends State<TablaRutas> {
  @override
  void initState() {
    super.initState();
    // Primera carga
    final bloc = context.read<RouteBloc>();
    if (bloc.state is! RouteLoaded && bloc.state is! RouteLoading) {
      bloc.add(LoadRoute());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 👇 Cada vez que esta pantalla vuelve a estar activa (por ejemplo, vuelves desde /pois),
    // recargamos las rutas. Esto evita depender de listeners de GoRouter.
    context.read<RouteBloc>().add(LoadRoute());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 👇 Si hubo una operación exitosa en POI (crear/editar/eliminar),
        // refrescamos las rutas para que la tabla se actualice sin recargar.
        BlocListener<PoiBloc, PoiState>(
          listener: (context, state) {
            if (state is PoiLoadedWithSuccess ||
                state is PoiOperationSuccess) {
              context.read<RouteBloc>().add(LoadRoute());
            }
          },
        ),
      ],
      child: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          if (state is RouteLoaded) {
            const double rowHeight = 60.0;
            const double headerHeight = 52.0;

            return Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======= HEADER =======
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Rutas",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF202124),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Gestiona las rutas registradas en el sistema",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.go('/rutas/create');
                                },
                                icon: const Icon(Icons.add_rounded,
                                    color: Colors.white, size: 18),
                                label: const Text(
                                  "Crear ruta",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4D67AE),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                  shadowColor:
                                      const Color(0xFF4D67AE).withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ),

                    // ======= BARRA CONTEXTUAL =======
                    Container(
                      margin: const EdgeInsets.only(bottom: 28),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline,
                              color: Color(0xFF4D67AE), size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Aquí puedes crear, editar o eliminar rutas. "
                              "Cada ruta define coordenadas de inicio y fin, y puede asociar múltiples puntos de interés.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======= TABLA =======
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Scrollbar(
                                thumbVisibility: true,
                                radius: const Radius.circular(10),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                      ),
                                      child: DataTableTheme(
                                        data: DataTableThemeData(
                                          headingRowHeight: headerHeight,
                                          dataRowMinHeight: rowHeight,
                                          dataRowMaxHeight: rowHeight,
                                          headingRowColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xFFF5F6F7)),
                                          headingTextStyle: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF4D67AE),
                                            fontSize: 14,
                                          ),
                                          dataTextStyle: const TextStyle(
                                            fontSize: 13.5,
                                            color: Color(0xFF1F1F1F),
                                          ),
                                        ),
                                        child: DataTable(
                                          columnSpacing: 26,
                                          horizontalMargin: 22,
                                          border: TableBorder(
                                            horizontalInside: BorderSide(
                                              width: 0.4,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          columns: const [
                                            DataColumn(label: Text("Nombre")),
                                            DataColumn(
                                                label: Text("Latitud inicio")),
                                            DataColumn(
                                                label: Text("Longitud inicio")),
                                            DataColumn(
                                                label: Text("Latitud fin")),
                                            DataColumn(
                                                label: Text("Longitud fin")),
                                            DataColumn(
                                                label: Text("Puntos de interés")),
                                            DataColumn(label: Text("Acciones")),
                                          ],
                                          rows: List<DataRow>.generate(
                                            state.routes.length,
                                            (index) {
                                              final route = state.routes[index];
                                              final Color zebraColor = index.isEven
                                                  ? Colors.white
                                                  : const Color(0xFFF9FAFB);

                                              return DataRow(
                                                color: MaterialStateProperty
                                                    .resolveWith<Color?>(
                                                  (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState.hovered)) {
                                                      return const Color(0xFF4D67AE)
                                                          .withOpacity(0.08);
                                                    }
                                                    return zebraColor;
                                                  },
                                                ),
                                                cells: [
                                                  DataCell(Text(route.name)),
                                                  DataCell(Text(route
                                                      .initialLatitude
                                                      .toStringAsFixed(5))),
                                                  DataCell(Text(route
                                                      .initialLongitude
                                                      .toStringAsFixed(5))),
                                                  DataCell(Text(route.finalLatitude
                                                      .toStringAsFixed(5))),
                                                  DataCell(Text(route.finalLongitude
                                                      .toStringAsFixed(5))),
                                                  DataCell(Text(
                                                    route.pois
                                                        .map((e) => e.nombre)
                                                        .join(', '),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                                  DataCell(Row(
                                                    children: [
                                                      IconButton(
                                                        tooltip: "Editar",
                                                        icon: const Icon(
                                                            Icons.edit_outlined,
                                                            color:
                                                                Color(0xFF4D67AE)),
                                                        onPressed: () {
                                                          context.go(
                                                            '/rutas/edit/${route.id}',
                                                            extra: route,
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        tooltip: "Eliminar",
                                                        icon: const Icon(
                                                            Icons.delete_outline,
                                                            color:
                                                                Colors.redAccent),
                                                        onPressed: () {
                                                          fnDeleteRoute(
                                                              route.id, context);
                                                        },
                                                      ),
                                                    ],
                                                  )),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const LoadingMessage();
          }
        },
      ),
    );
  }

  void fnDeleteRoute(String id, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text(
          "Eliminar ruta",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "¿Seguro que deseas eliminar esta ruta?",
          style: TextStyle(fontSize: 14),
        ),
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
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
