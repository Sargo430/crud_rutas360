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
  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<PoiBloc>(context);
    if (bloc.state is! PoiLoaded && bloc.state is! PoiLoadedWithSuccess) {
      bloc.add(LoadPOIs());
    }
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

          // Alturas coherentes con tu TablaRutas
          const double rowHeight = 56.0;
          const double headerHeight = 50.0;
          final double tableHeight = headerHeight + (pois.length * rowHeight);

          // Config base
          const double columnSpacing = 16.0; // 8 gaps entre 9 columnas
          const double innerHPadding = 12.0; // padding horizontal dentro del DataTable

          // Mínimos por columna (garantizan visibilidad; Acciones nunca se corta)
          const double minNombre = 120;
          const double minDesc   = 150; // ES, EN, PT
          const double minCoord  = 75;  // Lat, Long
          const double minCats   = 130;
          const double minActs   = 130;
          const double minAcc    = 100; // Acciones

          // Pesos para repartir el “extra” (sin huecos irregulares)
          // Ajustados para que Actividades no se vea más ancha que Categorías.
          const double wNombre = 0.10;
          const double wDescEs = 0.18;
          const double wDescEn = 0.18;
          const double wDescPt = 0.18;
          const double wCats   = 0.12;
          const double wActs   = 0.08;

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
                          "Puntos de Interés",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Gestiona los puntos de interés del sistema",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/pois/create'),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Agregar POI", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D67AE),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Card + tabla que llena EXACTO el ancho disponible (sin huecos)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: SizedBox(
                    width: double.infinity,
                    height: tableHeight,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Ancho útil total que deben sumar las columnas
                        final double available =
                            constraints.maxWidth - innerHPadding * 2 - columnSpacing * 8;

                        // Suma de mínimos
                        final double sumMins = minNombre + minDesc * 3 + minCoord * 2 + minCats + minActs + minAcc;

                        // Extra a repartir (si hay)
                        final double extra = (available - sumMins).clamp(0, double.infinity);

                        const double totalWeight =
                            wNombre + wDescEs + wDescEn + wDescPt + wCats + wActs;

                        double grow(double w) =>
                            totalWeight == 0 ? 0 : extra * (w / totalWeight);

                        // Cálculo final de anchos: suman EXACTAMENTE "available"
                        final double widthNombre = minNombre + grow(wNombre);
                        final double widthDescEs = minDesc   + grow(wDescEs);
                        final double widthDescEn = minDesc   + grow(wDescEn);
                        final double widthDescPt = minDesc   + grow(wDescPt);
                        final double widthLat    = minCoord; // fijo
                        final double widthLng    = minCoord; // fijo
                        final double widthCats   = minCats   + grow(wCats);
                        final double widthActs   = minActs   + grow(wActs);
                        final double widthAcc    = minAcc;   // fijo

                        return DataTableTheme(
                          data: DataTableThemeData(
                            headingRowHeight: headerHeight,
                            dataRowMinHeight: rowHeight,
                            dataRowMaxHeight: rowHeight,
                            // Usa MaterialStateProperty para compatibilidad amplia
                            headingRowColor:
                                MaterialStateProperty.all<Color>(const Color(0xFFF3F4F6)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: innerHPadding),
                            child: DataTable(
                              columnSpacing: columnSpacing,
                              border: TableBorder(
                                horizontalInside:
                                    BorderSide(width: 0.3, color: Colors.grey.shade300),
                              ),
                              columns: const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Descripción (ES)')),
                                DataColumn(label: Text('Descripción (EN)')),
                                DataColumn(label: Text('Descripción (PT)')),
                                DataColumn(label: Text('Latitud')),
                                DataColumn(label: Text('Longitud')),
                                DataColumn(label: Text('Categorías')),
                                DataColumn(label: Text('Actividades')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: pois.map((poi) {
                                return DataRow(
                                  cells: [
                                    DataCell(SizedBox(
                                      width: widthNombre,
                                      child: Text(poi.nombre, overflow: TextOverflow.ellipsis),
                                    )),
                                    DataCell(SizedBox(
                                      width: widthDescEs,
                                      child: Text(
                                        (poi.descripcion["es"] ?? '').toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )),
                                    DataCell(SizedBox(
                                      width: widthDescEn,
                                      child: Text(
                                        (poi.descripcion["en"] ?? '').toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )),
                                    DataCell(SizedBox(
                                      width: widthDescPt,
                                      child: Text(
                                        (poi.descripcion["pt"] ?? '').toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )),
                                    DataCell(SizedBox(
                                      width: widthLat,
                                      child: Text(
                                        poi.latitud.toStringAsFixed(5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                                    DataCell(SizedBox(
                                      width: widthLng,
                                      child: Text(
                                        poi.longitud.toStringAsFixed(5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                                    DataCell(SizedBox(
                                      width: widthCats,
                                      child: Text(
                                        poi.categorias
                                            .map((e) => (e.nombre["es"] ?? '').toString())
                                            .where((s) => s.isNotEmpty)
                                            .join(', '),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )),
                                    DataCell(SizedBox(
                                      width: widthActs,
                                      child: Text(
                                        poi.actividades
                                            .map((e) => (e.nombre["es"] ?? '').toString())
                                            .where((s) => s.isNotEmpty)
                                            .join(', '),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )),
                                    DataCell(SizedBox(
                                      width: widthAcc,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            tooltip: "Editar",
                                            icon: const Icon(Icons.edit, color: Color(0xFF4D67AE)),
                                            onPressed: () => context.go(
                                              '/pois/edit/${poi.id}',
                                              extra: poi,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: "Eliminar",
                                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                                            onPressed: () =>
                                                fnDeletePOI(poi.id, poi.routeId, context),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este punto de interés?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<PoiBloc>(context).add(DeletePOI(route, id));
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
