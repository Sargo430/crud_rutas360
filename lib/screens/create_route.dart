import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/route_event.dart';
import 'package:crud_rutas360/states/route_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class CreateRoute extends StatefulWidget {
  const CreateRoute({super.key});

  @override
  State<CreateRoute> createState() => _CreateRouteState();
}

class _CreateRouteState extends State<CreateRoute> {
  final String apiKey = 'vuobOOmhVcspXRuOBRRs';

  final MapController mapController = MapController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _initialLatController = TextEditingController();
  final TextEditingController _initialLongController = TextEditingController();
  final TextEditingController _finalLatController = TextEditingController();
  final TextEditingController _finalLongController = TextEditingController();

  @override
  void initState() {
    BlocProvider.of<RouteBloc>(context).add(LoadUnasignedPOIs());
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialLatController.dispose();
    _initialLongController.dispose();
    _finalLatController.dispose();
    _finalLongController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        if(state is RouteCreating){
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1, // campos
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crear Ruta',
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre de la Ruta',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text("Punto inicial"),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _initialLatController,
                                decoration: InputDecoration(
                                  labelText: 'Latitud',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _initialLongController,
                                decoration: InputDecoration(
                                  labelText: 'Longitud',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text("Punto final"),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _finalLatController,
                                decoration: InputDecoration(
                                  labelText: 'Latitud',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _finalLongController,
                                decoration: InputDecoration(
                                  labelText: 'Longitud',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text("Puntos de interés"),
                        SizedBox(height: 8),
                        MultiDropdown(
                          items: state.unasignedPOIs.map(
                            (poi) => DropdownItem(label: poi.nombre, value: poi.id),
                          ).toList(),
                          )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, // mapa
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vista previa',
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    -35.6960057,
                                    -71.4060907,
                                  ),
                                  initialZoom: 15,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey',
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
