import 'package:crud_rutas360/blocs/poi_bloc.dart';
import 'package:crud_rutas360/events/poi_events.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/states/poi_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crud_rutas360/widgets/loading_message.dart';
import 'package:go_router/go_router.dart';

class PoiTable extends StatefulWidget {
  const PoiTable({super.key});

  @override
  State<PoiTable> createState() => _PoiTableState();
}

class _PoiTableState extends State<PoiTable> {
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<PoiBloc>(context);
    if (bloc.state is! PoiLoaded && bloc.state is! PoiLoadedWithSuccess) {
      bloc.add(LoadPOIs());
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PoiBloc, PoiState>(
      listener: (context, state) {
        if (state is PoiLoadedWithSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is PoiError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is PoiLoaded || state is PoiLoadedWithSuccess) {
          final List<POI> pois =
              state is PoiLoaded ? state.pois : (state as PoiLoadedWithSuccess).pois;

          const double rowHeight = 60.0;
          const double headerHeight = 52.0;

          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== HEADER =====
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
                                  "Puntos de Interés",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF202124),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Gestiona los puntos de interés del sistema",
                                  style: TextStyle(fontSize: 15, color: Colors.black54),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/pois/create'),
                              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                              label: const Text(
                                "Agregar POI",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4D67AE),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                                shadowColor: const Color(0xFF4D67AE).withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                  ),

                  // ===== BARRA CONTEXTUAL =====
                  Container(
                    margin: const EdgeInsets.only(bottom: 28),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF4D67AE), size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Aquí puedes crear, editar o eliminar puntos de interés. "
                            "Cada POI puede tener descripciones en varios idiomas, coordenadas y categorías asociadas.",
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== TABLA DE POIs =====
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Scrollbar(
                          controller: _verticalController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          radius: const Radius.circular(6),
                          thickness: 8,
                          child: SingleChildScrollView(
                            controller: _verticalController,
                            scrollDirection: Axis.vertical,
                            child: DataTableTheme(
                              data: DataTableThemeData(
                                headingRowHeight: headerHeight,
                                dataRowMinHeight: rowHeight,
                                dataRowMaxHeight: rowHeight,
                                headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F6F7)),
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
                                columnSpacing: 22,
                                horizontalMargin: 22,
                                border: TableBorder(
                                  horizontalInside: BorderSide(
                                    width: 0.4,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                columns: const [
                                  DataColumn(label: Text('Nombre')),
                                  DataColumn(label: Text('Descripción (ES)')),
                                  DataColumn(label: Text('Latitud')),
                                  DataColumn(label: Text('Longitud')),
                                  DataColumn(label: Text('Categorías')),
                                  DataColumn(label: Text('Actividades')),
                                  DataColumn(label: Text('Acciones')),
                                ],
                                rows: List<DataRow>.generate(
                                  pois.length,
                                  (index) {
                                    final poi = pois[index];
                                    final Color zebraColor = index.isEven
                                        ? Colors.white
                                        : const Color(0xFFF9FAFB);

                                    return DataRow(
                                      color: WidgetStateProperty.resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                          if (states.contains(WidgetState.hovered)) {
                                            return const Color(0xFF4D67AE).withValues(alpha:0.08);
                                          }
                                          return zebraColor;
                                        },
                                      ),
                                      cells: [
                                        DataCell(Text(poi.nombre, overflow: TextOverflow.ellipsis)),
                                        DataCell(Text(
                                          (poi.descripcion["es"] ?? "").toString(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        )),
                                        DataCell(Text(poi.latitud.toStringAsFixed(5))),
                                        DataCell(Text(poi.longitud.toStringAsFixed(5))),
                                        DataCell(Text(
                                          poi.categorias
                                              .map((e) => (e.nombre["es"] ?? "").toString())
                                              .where((s) => s.isNotEmpty)
                                              .join(', '),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        )),
                                        DataCell(Text(
                                          poi.actividades
                                              .map((e) => (e.nombre["es"] ?? "").toString())
                                              .where((s) => s.isNotEmpty)
                                              .join(', '),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        )),
                                        DataCell(Row(
                                          children: [
                                            IconButton(
                                              tooltip: "Editar",
                                              icon: const Icon(Icons.edit_outlined,
                                                  color: Color(0xFF4D67AE)),
                                              onPressed: () => context.go(
                                                '/pois/edit/${poi.id}',
                                                extra: poi,
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: "Eliminar",
                                              icon: const Icon(Icons.delete_outline,
                                                  color: Colors.redAccent),
                                              onPressed: () =>
                                                  fnDeletePOI(poi.id, poi.routeId, context),
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
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is PoiError) {
          return Center(child: Text('Error al cargar POIs: ${state.error}'));
        } else {
          return const LoadingMessage();
        }
      },
    );
  }

  void fnDeletePOI(id, route, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Eliminar POI', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          '¿Seguro que deseas eliminar este punto de interés?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              BlocProvider.of<PoiBloc>(context).add(DeletePOI(route, id));
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
