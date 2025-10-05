import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/route_event.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/models/route_model.dart';
import 'package:crud_rutas360/states/route_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class CreateRoute extends StatefulWidget {
  final MapRoute? route;
  final GlobalKey<NavigatorState> rootNavigatorKey;
  const CreateRoute({super.key, required this.rootNavigatorKey, this.route});

  @override
  State<CreateRoute> createState() => _CreateRouteState();
}

class _CreateRouteState extends State<CreateRoute> {
  void _onPOISelectionChanged() {
    setState(() {});
  }
  LatLng? _initialLatLng;
  LatLng? _finalLatLng;

  @override
  void initState() {
    super.initState();
    _initialLatController.addListener(_updateInitialLatLng);
    _initialLongController.addListener(_updateInitialLatLng);
    _finalLatController.addListener(_updateFinalLatLng);
    _finalLongController.addListener(_updateFinalLatLng);

  _multiSelectController.addListener(_onPOISelectionChanged);

    if (widget.route != null) {
      _nameController.text = widget.route!.name;
      _initialLatController.text = widget.route!.initialLatitude.toString();
      _initialLongController.text = widget.route!.initialLongitude.toString();
      _finalLatController.text = widget.route!.finalLatitude.toString();
      _finalLongController.text = widget.route!.finalLongitude.toString();
      _updateInitialLatLng();
      _updateFinalLatLng();
    }
    BlocProvider.of<RouteBloc>(context).add(LoadUnasignedPOIs());
  }
  

  void _updateInitialLatLng() {
    final lat = double.tryParse(_initialLatController.text);
    final lng = double.tryParse(_initialLongController.text);
    if (lat != null && lng != null) {
      setState(() {
        _initialLatLng = LatLng(lat, lng);
      });
    } else {
      setState(() {
        _initialLatLng = null;
      });
    }
  }

  void _updateFinalLatLng() {
    final lat = double.tryParse(_finalLatController.text);
    final lng = double.tryParse(_finalLongController.text);
    if (lat != null && lng != null) {
      setState(() {
        _finalLatLng = LatLng(lat, lng);
      });
    } else {
      setState(() {
        _finalLatLng = null;
      });
    }
  }
  final String apiKey = 'vuobOOmhVcspXRuOBRRs';

  final MapController mapController = MapController();

  final _createRouteFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _initialLatController = TextEditingController();
  final TextEditingController _initialLongController = TextEditingController();
  final TextEditingController _finalLatController = TextEditingController();
  final TextEditingController _finalLongController = TextEditingController();
  final MultiSelectController<POI> _multiSelectController =
      MultiSelectController<POI>();

  

  @override
  void dispose() {
    _nameController.dispose();
    _initialLatController.removeListener(_updateInitialLatLng);
    _initialLatController.dispose();
    _initialLongController.removeListener(_updateInitialLatLng);
    _initialLongController.dispose();
    _finalLatController.removeListener(_updateFinalLatLng);
    _finalLatController.dispose();
    _finalLongController.removeListener(_updateFinalLatLng);
    _finalLongController.dispose();
    _multiSelectController.removeListener(_onPOISelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        if (state is RouteCreating) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1, // campos
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Form(
                      key: _createRouteFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crear Ruta',
                            style: TextStyle(fontSize: 24, color: Colors.black),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre de la Ruta',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa un nombre';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          Text("Punto inicial"),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _initialLatController,
                                  decoration: InputDecoration(
                                    labelText: 'Latitud',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa una latitud';
                                    }
                                    final numValue = double.tryParse(value);
                                    if (numValue == null) {
                                      return 'Ingresa un número válido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _initialLongController,
                                  decoration: InputDecoration(
                                    labelText: 'Longitud',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa una longitud';
                                    }
                                    final numValue = double.tryParse(value);
                                    if (numValue == null) {
                                      return 'Ingresa un número válido';
                                    }
                                    return null;
                                  },
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
                                child: TextFormField(
                                  controller: _finalLatController,
                                  decoration: InputDecoration(
                                    labelText: 'Latitud',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa una latitud';
                                    }
                                    final numValue = double.tryParse(value);
                                    if (numValue == null) {
                                      return 'Ingresa un número válido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _finalLongController,
                                  decoration: InputDecoration(
                                    labelText: 'Longitud',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa una longitud';
                                    }
                                    final numValue = double.tryParse(value);
                                    if (numValue == null) {
                                      return 'Ingresa un número válido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text("Puntos de interés"),
                          SizedBox(height: 8),
                          (() {
                            // Combine POIs from route and unasigned
                            final routePOIs = widget.route?.pois ?? [];
                            final unasignedPOIs = state.unasignedPOIs;
                            // Avoid duplicates by POI id
                            final allPOIsMap = <String, POI>{};
                            for (var poi in routePOIs) {
                              allPOIsMap[poi.id] = poi;
                            }
                            for (var poi in unasignedPOIs) {
                              allPOIsMap[poi.id] = poi;
                            }
                            final allPOIs = allPOIsMap.values.toList();

                            
                            if (routePOIs.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                try {
                                  _multiSelectController.selectWhere((element) =>
                                    routePOIs.any((poi) => poi.id == element.value.id)
                                  );
                                } catch (_) {}
                              });
                            }

                            if (allPOIs.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'No hay puntos de interés disponibles para asignar.',
                                  style: TextStyle(color: Colors.red, fontSize: 16),
                                ),
                              );
                            } else {
                              return MultiDropdown(
                                items: allPOIs
                                    .map((poi) => DropdownItem(
                                          label: poi.nombre,
                                          value: poi,
                                        ))
                                    .toList(),
                                                
                                controller: _multiSelectController,
                                enabled: true,
                                searchEnabled: true,
                                fieldDecoration: FieldDecoration(
                                  labelText: 'Selecciona POIs',
                                  hintText: 'Selecciona POIs',
                                  border: OutlineInputBorder(),
                                ),
                                searchDecoration: SearchFieldDecoration(
                                  hintText: 'Buscar',
                                  border: OutlineInputBorder(),
                                ),
                              );
                            }
                          })(),
                          SizedBox(height: 64),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFE0E0E0),
                                  ),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {
                                    if (_createRouteFormKey.currentState!.validate()) {
                                      _fnAddRoute();
                                      // Trigger refresh in shared Bloc (table) using rootNavigatorKey
                                      final sharedBloc = BlocProvider.of<RouteBloc>(widget.rootNavigatorKey.currentContext!, listen: false);
                                      sharedBloc.add(LoadRoute());
                                      context.go('/rutas');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4D67AE),
                                  ),
                                  child: Text('Crear Ruta'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                                  initialCenter: _initialLatLng ?? _finalLatLng ?? LatLng(-35.6960057, -71.4060907),
                                  initialZoom: 15,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey',
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      if (_initialLatLng != null)
                                        Marker(
                                          point: _initialLatLng!,
                                          width: 40,
                                          height: 40,
                                          child: Icon(Icons.flag, color: Colors.green, size: 40),
                                        ),
                                      if (_finalLatLng != null)
                                        Marker(
                                          point: _finalLatLng!,
                                          width: 40,
                                          height: 40,
                                          child: Icon(Icons.flag, color: Colors.red, size: 40),
                                        ),
                                      // POI markers
                                      ..._multiSelectController.selectedItems
                                        .map((item) => Marker(
                                          point: LatLng(item.value.latitud, item.value.longitud),
                                          width: 32,
                                          height: 32,
                                          child: Icon(Icons.location_on, color: Colors.purple, size: 32),
                                        ))
                                    ],
                                  ),
                                  if (_initialLatLng != null && _finalLatLng != null)
                                    PolylineLayer(
                                      polylines: [
                                        Polyline(
                                          points: [_initialLatLng!, _finalLatLng!],
                                          color: Colors.blue,
                                          strokeWidth: 4,
                                        ),
                                      ],
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
        } else if (state is RouteError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  'Error: ${state.error}',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<RouteBloc>(context).add(LoadUnasignedPOIs());
                  },
                  child: Text('Reintentar'),
                ),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _fnAddRoute() {
    final name = _nameController.text.trim();
    final initialLat = _initialLatController.text.trim();
    final initialLong = _initialLongController.text.trim();
    final finalLat = _finalLatController.text.trim();
    final finalLong = _finalLongController.text.trim();

    BlocProvider.of<RouteBloc>(context).add(
      AddRoute(
        MapRoute(
          id: name,
          initialLatitude: double.parse(initialLat),
          initialLongitude: double.parse(initialLong),
          finalLatitude: double.parse(finalLat),
          finalLongitude: double.parse(finalLong),
          name: name,
          pois: _multiSelectController.selectedItems
              .map((item) => item.value)
              .toList(),
        ),
      ),
    );
  }
}
