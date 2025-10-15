import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/route_event.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/models/route_model.dart';
import 'package:crud_rutas360/states/route_state.dart';
import 'package:crud_rutas360/widgets/build_section.dart';
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
  bool _initialPOIsApplied = false; // 🔧 agregado

  final Color mainColor = const Color(0xFF4D67AE);

  // 🚀 Nueva propiedad: detecta si el formulario está en modo edición
  bool get _isEditing => widget.route != null;

  @override
  void initState() {
    super.initState();
    _initialLatController.addListener(_updateInitialLatLng);
    _initialLongController.addListener(_updateInitialLatLng);
    _finalLatController.addListener(_updateFinalLatLng);
    _finalLongController.addListener(_updateFinalLatLng);
    _multiSelectController.addListener(() => setState(() {}));

    // Si estamos editando, precargar los datos de la ruta existente
    if (widget.route != null) {
      _nameController.text = widget.route!.name;
      _initialLatController.text = widget.route!.initialLatitude.toString();
      _initialLongController.text = widget.route!.initialLongitude.toString();
      _finalLatController.text = widget.route!.finalLatitude.toString();
      _finalLongController.text = widget.route!.finalLongitude.toString();
      _updateInitialLatLng();
      _updateFinalLatLng();
    }

    // Cargar POIs disponibles (no asignados)
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
    return BlocListener<RouteBloc, RouteState>(
      listener: (context, state) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        if (state is RouteOperationSuccess) {
          scaffoldMessenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );

          final rootContext = widget.rootNavigatorKey.currentContext;
          if (rootContext != null) {
            BlocProvider.of<RouteBloc>(
              rootContext,
              listen: false,
            ).add(LoadRoute());
          }
          context.go('/rutas');
        } else if (state is RouteError) {
          scaffoldMessenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: BlocBuilder<RouteBloc, RouteState>(
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
                              Text(
                                _isEditing ? "Editar Ruta" : "Crear Ruta",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isEditing
                                    ? "Modifica los datos de la ruta seleccionada"
                                    : "Define los puntos de inicio y fin para crear una nueva ruta",
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const Divider(height: 24),

                              // Información de la ruta
                              BuildSection(
                                mainColor: mainColor,
                                title: "Información de la Ruta",
                                subtitle:
                                    "Nombre identificador de la ruta",
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: _inputDecoration(
                                    label: "Nombre de la Ruta",
                                    hint: "Ej: Ruta Centro - Norte",
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Por favor ingresa un nombre'
                                          : null,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Punto inicial
                              BuildSection(
                                mainColor: mainColor,
                                title: "Punto Inicial",
                                subtitle: "Coordenadas del punto de partida",
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _initialLatController,
                                        decoration: _inputDecoration(
                                            label: "Latitud"),
                                        keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _initialLongController,
                                        decoration: _inputDecoration(
                                            label: "Longitud"),
                                        keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Punto final
                              BuildSection(
                                mainColor: mainColor,
                                title: "Punto Final",
                                subtitle: "Coordenadas del punto de destino",
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _finalLatController,
                                        decoration: _inputDecoration(
                                            label: "Latitud"),
                                        keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _finalLongController,
                                        decoration: _inputDecoration(
                                            label: "Longitud"),
                                        keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Puntos de interés
                              BuildSection(
                                mainColor: mainColor,
                                title: "Puntos de Interés",
                                subtitle: "Selecciona los POIs a incluir",
                                child: (() {
                                  final routePOIs = widget.route?.pois ?? [];
                                  final unasignedPOIs = state.unasignedPOIs;

                                  // Unir los POIs de la ruta y los no asignados
                                  final allPOIsMap = <String, POI>{};
                                  for (var poi in routePOIs) {
                                    allPOIsMap[poi.id] = poi;
                                  }
                                  for (var poi in unasignedPOIs) {
                                    allPOIsMap[poi.id] = poi;
                                  }
                                  final allPOIs =
                                      allPOIsMap.values.toList();

                                  // Preseleccionar POIs si estamos editando
                                  if (routePOIs.isNotEmpty &&
                                      !_initialPOIsApplied) { // ✅ corrección
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      try {
                                        _multiSelectController.selectWhere(
                                          (element) => routePOIs.any(
                                            (poi) =>
                                                poi.id ==
                                                element.value.id,
                                          ),
                                        );
                                      } catch (_) {} finally { // 🔧 agregado
                                        _initialPOIsApplied = true; // 🔧 agregado
                                      }
                                    });
                                  }
                                  if (routePOIs.isEmpty &&
                                      !_initialPOIsApplied) { // 🔧 agregado
                                    _initialPOIsApplied = true; // 🔧 agregado
                                  } // 🔧 agregado

                                  if (allPOIs.isEmpty) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                      child: Text(
                                        'No hay puntos de interés disponibles para asignar.',
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return MultiDropdown(
                                      items: allPOIs
                                          .map(
                                            (poi) => DropdownItem(
                                              label: poi.nombre,
                                              value: poi,
                                            ),
                                          )
                                          .toList(),
                                      controller:
                                          _multiSelectController,
                                      enabled: true,
                                      searchEnabled: true,
                                      fieldDecoration: FieldDecoration(
                                        labelText: 'Selecciona POIs',
                                        hintText: 'Selecciona POIs',
                                        border: const OutlineInputBorder(),
                                      ),
                                      searchDecoration:
                                          const SearchFieldDecoration(
                                        hintText: 'Buscar',
                                        border: OutlineInputBorder(),
                                      ),
                                    );
                                  }
                                })(),
                              ),
                              const SizedBox(height: 32),

                              // Botones de acción
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => context.pop(),
                                      child: Text(
                                        "Cancelar",
                                        style:
                                            TextStyle(color: mainColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_createRouteFormKey
                                            .currentState!
                                            .validate()) { // ✅ corrección
                                          _fnAddRoute(); // ✅ corrección
                                        } // ✅ corrección
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: mainColor,
                                        padding:
                                            const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        _isEditing
                                            ? 'Actualizar ruta'
                                            : 'Crear ruta',
                                        style: const TextStyle(
                                            color: Colors.white),
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
                                  ..._multiSelectController
                                      .selectedItems
                                      .map(
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
                              if (_initialLatLng != null &&
                                  _finalLatLng != null)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: [
                                        _initialLatLng!,
                                        _finalLatLng!
                                      ],
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
      ), // 🔧 agregado
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

  // 🧠 Función unificada: crea o actualiza según el modo actual
  void _fnAddRoute() {
    final name = _nameController.text.trim();
    final initialLat = _initialLatController.text.trim();
    final initialLong = _initialLongController.text.trim();
    final finalLat = _finalLatController.text.trim();
    final finalLong = _finalLongController.text.trim();

    final routeBloc = BlocProvider.of<RouteBloc>(context);
    final updatedRoute = MapRoute(
      id: _isEditing ? widget.route!.id : name,
      initialLatitude: double.parse(initialLat),
      initialLongitude: double.parse(initialLong),
      finalLatitude: double.parse(finalLat),
      finalLongitude: double.parse(finalLong),
      name: name,
      pois: _multiSelectController.selectedItems
          .map((item) => item.value)
          .toList(),
    );

    if (_isEditing) {
      routeBloc.add(UpdateRoute(updatedRoute));
    } else {
      routeBloc.add(AddRoute(updatedRoute));
    }
  }
}
