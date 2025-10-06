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
  LatLng? _initialLatLng;
  LatLng? _finalLatLng;

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

  final Color mainColor = const Color(0xFF4D67AE);

  @override
  void initState() {
    super.initState();
    _initialLatController.addListener(_updateInitialLatLng);
    _initialLongController.addListener(_updateInitialLatLng);
    _finalLatController.addListener(_updateFinalLatLng);
    _finalLongController.addListener(_updateFinalLatLng);
    _multiSelectController.addListener(() => setState(() {}));

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
    setState(() {
      _initialLatLng = (lat != null && lng != null) ? LatLng(lat, lng) : null;
    });
  }

  void _updateFinalLatLng() {
    final lat = double.tryParse(_finalLatController.text);
    final lng = double.tryParse(_finalLongController.text);
    setState(() {
      _finalLatLng = (lat != null && lng != null) ? LatLng(lat, lng) : null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialLatController.dispose();
    _initialLongController.dispose();
    _finalLatController.dispose();
    _finalLongController.dispose();
    _multiSelectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        if (state is RouteCreating) {
          const double kFormWidth = 500;
          const double kGutter = 24;

          return Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.all(kGutter),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==== PANEL DE FORMULARIO ====
                SizedBox(
                  width: kFormWidth,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _createRouteFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Crear Ruta",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Define los puntos de inicio y fin para crear una nueva ruta",
                                style: TextStyle(color: Colors.black54),
                              ),
                              const Divider(height: 24),

                              _buildSection(
                                title: "Información de la Ruta",
                                subtitle: "Nombre identificador de la ruta",
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: _inputDecoration(
                                    label: "Nombre de la Ruta",
                                    hint: "Ej: Ruta Centro - Norte",
                                  ),
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Por favor ingresa un nombre'
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 20),

                              _buildSection(
                                title: "Punto Inicial",
                                subtitle: "Coordenadas del punto de partida",
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _initialLatController,
                                        decoration: _inputDecoration(
                                          label: "Latitud",
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _initialLongController,
                                        decoration: _inputDecoration(
                                          label: "Longitud",
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              _buildSection(
                                title: "Punto Final",
                                subtitle: "Coordenadas del punto de destino",
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _finalLatController,
                                        decoration: _inputDecoration(
                                          label: "Latitud",
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _finalLongController,
                                        decoration: _inputDecoration(
                                          label: "Longitud",
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              _buildSection(
                                title: "Puntos de Interés",
                                subtitle: "Selecciona los POIs a incluir",
                                child: MultiDropdown(
                                  items: state.unasignedPOIs
                                      .map(
                                        (poi) => DropdownItem(
                                          label: poi.nombre,
                                          value: poi,
                                        ),
                                      )
                                      .toList(),
                                  controller: _multiSelectController,
                                  enabled: true,
                                  searchEnabled: true,
                                  fieldDecoration: const FieldDecoration(
                                    labelText: 'Selecciona POIs',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => context.pop(),
                                      child: Text(
                                        "Cancelar",
                                        style: TextStyle(
                                          color: mainColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_createRouteFormKey.currentState!
                                            .validate()) {
                                          _fnAddRoute();
                                          final sharedBloc =
                                              BlocProvider.of<RouteBloc>(
                                            widget.rootNavigatorKey.currentContext!,
                                            listen: false,
                                          );
                                          sharedBloc.add(LoadRoute());
                                          context.go('/rutas');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: mainColor,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Crear Ruta",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: kGutter),

                // ==== PANEL DE VISTA PREVIA ====
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Vista previa de la Ruta",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "El mapa mostrará la ruta al ingresar las coordenadas",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter: _initialLatLng ??
                                  _finalLatLng ??
                                  LatLng(-35.6960, -71.4060),
                              initialZoom: 13,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey',
                              ),
                              MarkerLayer(
                                markers: [
                                  if (_initialLatLng != null)
                                    Marker(
                                      point: _initialLatLng!,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.fiber_manual_record,
                                        color: Colors.green,
                                        size: 30,
                                      ),
                                    ),
                                  if (_finalLatLng != null)
                                    Marker(
                                      point: _finalLatLng!,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on_sharp,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    ),
                                  ..._multiSelectController.selectedItems.map(
                                    (item) => Marker(
                                      point: LatLng(
                                        item.value.latitud,
                                        item.value.longitud,
                                      ),
                                      width: 32,
                                      height: 32,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.purple,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_initialLatLng != null && _finalLatLng != null)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: [_initialLatLng!, _finalLatLng!],
                                      color: mainColor,
                                      strokeWidth: 4,
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
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: mainColor, width: 4)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: mainColor, width: 2),
      ),
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
