import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/route_event.dart';
import 'package:crud_rutas360/models/route_model.dart';
import 'package:crud_rutas360/states/route_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class TablaRutas extends StatefulWidget {
  const TablaRutas({super.key});

  @override
  State<TablaRutas> createState() => _TablaRutasState();
}

class _TablaRutasState extends State<TablaRutas> {
   @override
  void initState() {
    BlocProvider.of<RouteBloc>(context).add(LoadRoute());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder:(context, state) {
        if(state is RouteLoaded){
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Rutas',
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.go('/rutas/create');
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Agregar Ruta', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D67AE),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            
              const   SizedBox(height: 8),
              
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: RouteTable(routes: state.routes))
                ),
            ],
          );
        }
        else{
          return const Center(child: CircularProgressIndicator());
        }
      }
    );
  }
}

class RouteSource extends DataTableSource {
  final List<MapRoute> routes;
  RouteSource(this.routes);
  @override
  DataRow? getRow(int index) {
    if (index >= routes.length) return null;
    final route = routes[index];
    return DataRow(cells: [
      DataCell(Text(route.name)),
      DataCell(Text(route.initialLatitude.toString())),
      DataCell(Text(route.initialLongitude.toString())),
      DataCell(Text(route.finalLatitude.toString())),
      DataCell(Text(route.finalLongitude.toString())),
      DataCell(Text(route.pois.map((e) => e.nombre).join(', '))),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Acción para editar la ruta
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Acción para eliminar la ruta
            },
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => routes.length;

  @override
  int get selectedRowCount => 0;
}

class RouteTable extends StatelessWidget {
  final List<MapRoute> routes;
  const RouteTable({super.key, required this.routes});

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      columns: const [
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Latitud inicio')),
        DataColumn(label: Text('Longitud inicio')),
        DataColumn(label: Text('Latitud fin')),
        DataColumn(label: Text('Longitud fin')),
        DataColumn(label: Text ('Puntos de interés')),
        DataColumn(label: Text('Acciones')),
      ],
      source: RouteSource(routes),
      );
  }
}

