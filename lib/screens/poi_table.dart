import 'package:crud_rutas360/blocs/poi_bloc.dart';
import 'package:crud_rutas360/events/poi_events.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/states/poi_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PoiTable extends StatefulWidget {
  const PoiTable({super.key});

  @override
  State<PoiTable> createState() => _PoiTableState();
}

class _PoiTableState extends State<PoiTable> {
  @override
  void initState() {
    BlocProvider.of<PoiBloc>(context).add(LoadPOIs());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PoiBloc, PoiState>(
      builder: (context, state) {
        if (state is PoiLoaded) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Puntos de Interés',
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/pois/create');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Agregar POI',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D67AE),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: PoiDataTable(pois: state.pois),
                ),
              ),
            ],
          );
        } else if (state is PoiError) {
          return Center(child: Text('Error loading POIs'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class PoiSource extends DataTableSource {
  final List<POI> pois;
  final BuildContext context;
  PoiSource(this.pois, this.context);
  
  @override
  DataRow? getRow(int index) {
    if (index >= pois.length) return null;
    final poi = pois[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Container(
          alignment: Alignment.centerLeft,
          child: Text(
            poi.nombre,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Container(
          alignment: Alignment.centerLeft,
          width: 175,
          child: Text(
            (poi.descripcion["es"] ?? '').toString(),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Container(
          alignment: Alignment.centerLeft,
          width: 175,
          child: Text(
            (poi.descripcion["en"] ?? '').toString(),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Container(
          alignment: Alignment.centerLeft,
          width: 175,
          child: Text(
            (poi.descripcion["pt"] ?? '').toString(),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Container(
          alignment: Alignment.centerLeft,
          child: Text(
            poi.latitud.toString(),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Container(
          alignment: Alignment.centerLeft,
          child: Text(
            poi.longitud.toString(),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Container(
          alignment: Alignment.centerLeft,
          child: Text(
            poi.categorias
                .map((e) => (e.nombre["es"] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .join(', '),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Container(
          alignment: Alignment.centerLeft,
          child: Text(
            poi.actividades
                .map((e) => (e.nombre["es"] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .join(', '),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.go('/pois/edit/${poi.id}', extra: poi);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  fnDeletePOI(poi.id, poi.routeId, context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => pois.length;

  @override
  int get selectedRowCount => 0;

  void fnDeletePOI(id, route, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta categoría?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<PoiBloc>(context).add(DeletePOI(id, route));
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class PoiDataTable extends StatelessWidget {
  final List<POI> pois;
  const PoiDataTable({super.key, required this.pois});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: PaginatedDataTable(
        columnSpacing: 10,
        rowsPerPage: 10,
        dataRowMinHeight: 50,
        dataRowMaxHeight: 100,
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Descripción es')),
          DataColumn(label: Text('Descripción en')),
          DataColumn(label: Text('Descripción pt' )),
          DataColumn(label: Text('Latitud')),
          DataColumn(label: Text('Longitud')),
          DataColumn(label: Text('Categorías')),
          DataColumn(label: Text('Actividades')),
          DataColumn(label: Text('Acciones')),
        ],
        source: PoiSource(pois, context),
      ),
    );
  }
}
