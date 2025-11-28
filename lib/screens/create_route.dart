import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/route_event.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/models/route_model.dart';
import 'package:crud_rutas360/states/route_state.dart';
import 'package:crud_rutas360/services/input_validators.dart';
import 'package:crud_rutas360/widgets/build_section.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:crud_rutas360/services/api_keys.dart';
import 'package:crud_rutas360/services/routing_service.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

/// Formatter de rango tolerante con prefijos/signo/decimales.
class RangeTextInputFormatter extends TextInputFormatter {
  final double min;
  final double max;

  RangeTextInputFormatter({required this.min, required this.max})
      : assert(min <= max);

  int _requiredIntegerDigits() {
    final absMax = (min.abs() > max.abs()) ? min.abs() : max.abs();
    final intPart = absMax.floor();
    return intPart.toString().length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trim();

    // Estados intermedios permitidos
    if (text.isEmpty ||
        text == '-' ||
        text == '+' ||
        text == '.' ||
        text == '-.' ||
        text == '+.') {
      return newValue;
    }

    final v = double.tryParse(text);
    if (v == null) return newValue;

    final match = RegExp(r'^([+-]?)(\d*)(?:\.(\d*))?$').firstMatch(text);
    String intPart = '';
    if (match != null) intPart = match.group(2) ?? '';

    final needDigits = _requiredIntegerDigits();
    if (intPart.isEmpty || intPart.length < needDigits) return newValue;

    if (v < min || v > max) return oldValue;
    return newValue;
  }
}

class CreateRoute extends StatefulWidget {
  final MapRoute? route;
  final GlobalKey<NavigatorState> rootNavigatorKey;
  const CreateRoute({super.key, required this.rootNavigatorKey, this.route});

  @override
  State<CreateRoute> createState() => _CreateRouteState();
}

class _CreateRouteState extends State<CreateRoute> {
  // Coordenadas / ruta
  LatLng? _initialLatLng;
  LatLng? _finalLatLng;
  List<LatLng> _routePoints = [];
  bool _routeLoading = false;
  String? _routeError;
  Timer? _routeDebounce;
  String? _lastRouteKey;

  // Controllers
  final MapController mapController = MapController();
  final _createRouteFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _initialLatController = TextEditingController();
  final TextEditingController _initialLongController = TextEditingController();
  final TextEditingController _finalLatController = TextEditingController();
  final TextEditingController _finalLongController = TextEditingController();
  final MultiSelectController<POI> _multiSelectController =
      MultiSelectController<POI>();

  // Ciclo de vida
  bool _initialPOIsApplied = false;
  bool _mapReady = false;
  bool _initialized = false; // evita disparos prematuros
  LatLngBounds? _pendingRouteBounds; // fit pendiente

  final Color mainColor = const Color(0xFF4D67AE);
  bool get _isEditing => widget.route != null;

  // Formato numérico
  final List<TextInputFormatter> _numberFormattersBase = [
    FilteringTextInputFormatter.allow(RegExp(r'^[+-]?\d*\.?\d{0,8}$')),
  ];

  @override
  void initState() {
    super.initState();

    _initialLatController.addListener(_updateInitialLatLng);
    _initialLongController.addListener(_updateInitialLatLng);
    _finalLatController.addListener(_updateFinalLatLng);
    _finalLongController.addListener(_updateFinalLatLng);
    _multiSelectController.addListener(() => setState(() {}));

    if (_isEditing) {
      // Precarga de campos
      _nameController.text = widget.route!.name;
      _initialLatController.text = widget.route!.initialLatitude.toString();
      _initialLongController.text = widget.route!.initialLongitude.toString();
      _finalLatController.text = widget.route!.finalLatitude.toString();
      _finalLongController.text = widget.route!.finalLongitude.toString();

      // Diferir la primera actualización a después del primer frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _initialized = true;
          _updateInitialLatLng();
          _updateFinalLatLng();
        });
      });
    } else {
      _initialized = true;
    }

    // Cargar POIs no asignados
    context.read<RouteBloc>().add(LoadUnasignedPOIs());
  }

  @override
  void dispose() {
    _routeDebounce?.cancel();
    _nameController.dispose();
    _initialLatController.dispose();
    _initialLongController.dispose();
    _finalLatController.dispose();
    _finalLongController.dispose();
    _multiSelectController.dispose();
    super.dispose();
  }

  // --------- Coordenadas & Ruta ---------

  void _updateInitialLatLng() {
    final lat = double.tryParse(_initialLatController.text);
    final lng = double.tryParse(_initialLongController.text);
    setState(() {
      _initialLatLng = (lat != null && lng != null) ? LatLng(lat, lng) : null;
    });
    _maybeFetchRoute();
  }

  void _updateFinalLatLng() {
    final lat = double.tryParse(_finalLatController.text);
    final lng = double.tryParse(_finalLongController.text);
    setState(() {
      _finalLatLng = (lat != null && lng != null) ? LatLng(lat, lng) : null;
    });
    _maybeFetchRoute();
  }

  void _maybeFetchRoute() {
    if (!_initialized) return;

    if (_initialLatLng != null && _finalLatLng != null) {
      final okInitialLat =
          InputValidators.validateLatitude(_initialLatController.text) == null;
      final okInitialLng =
          InputValidators.validateLongitude(_initialLongController.text) == null;
      final okFinalLat =
          InputValidators.validateLatitude(_finalLatController.text) == null;
      final okFinalLng =
          InputValidators.validateLongitude(_finalLongController.text) == null;

      if (okInitialLat && okInitialLng && okFinalLat && okFinalLng) {
        _routeDebounce?.cancel();
        _routeDebounce = Timer(const Duration(milliseconds: 450), () {
          if (!mounted) return;
          final key =
              '${_initialLatLng!.latitude},${_initialLatLng!.longitude}|${_finalLatLng!.latitude},${_finalLatLng!.longitude}';
          if (_lastRouteKey == key && _routePoints.isNotEmpty) return;
          _lastRouteKey = key;
          _fetchRoute();
        });
      } else {
        setState(() {
          _routePoints = [];
          _routeError = null;
        });
      }
    } else {
      setState(() {
        _routePoints = [];
        _routeError = null;
      });
    }
  }

  Future<void> _fetchRoute() async {
    if (_routeLoading) return;
    final start = _initialLatLng!;
    final end = _finalLatLng!;

    setState(() {
      _routeLoading = true;
      _routeError = null;
    });

    try {
      final points = await RoutingService.fetchRoute(
        start: start,
        end: end,
        orsApiKey: ApiKeys.openRouteServiceKey,
      );
      if (!mounted) return;

      // Filtrar por seguridad
      final clean = points
          .where((p) =>
              p.latitude.isFinite &&
              p.longitude.isFinite &&
              p.latitude >= -90 &&
              p.latitude <= 90 &&
              p.longitude >= -180 &&
              p.longitude <= 180)
          .toList(growable: false);

      setState(() {
        _routePoints = clean;
      });

      if (clean.isEmpty) return;

      final bounds = clean.length >= 2
          ? LatLngBounds.fromPoints(clean)
          : LatLngBounds(clean.first, clean.first);

      if (_mapReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            mapController.fitCamera(
              CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(24)),
            );
          } catch (_) {
            // fallback por si la versión del paquete difiere
            mapController.move(clean.first, 13);
          }
        });
      } else {
        _pendingRouteBounds = bounds;
      }
    } catch (e) {
      setState(() {
        _routeError = e.toString();
        _routePoints = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _routeLoading = false;
        });
      }
    }
  }

  void _handleMapTap(LatLng tappedPoint) {
    final latText = tappedPoint.latitude.toStringAsFixed(6);
    final lonText = tappedPoint.longitude.toStringAsFixed(6);

    final shouldSetInitial =
        _initialLatLng == null || (_initialLatLng != null && _finalLatLng != null);

    if (shouldSetInitial) {
      if (_finalLatController.text.isNotEmpty ||
          _finalLongController.text.isNotEmpty) {
        _finalLatController.text = '';
        _finalLongController.text = '';
      }
      _initialLatController.text = latText;
      _initialLongController.text = lonText;
      setState(() {
        _routePoints = [];
        _routeError = null;
      });
    } else {
      _finalLatController.text = latText;
      _finalLongController.text = lonText;
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return BlocListener<RouteBloc, RouteState>(
      listener: (context, state) {
        final sm = ScaffoldMessenger.of(context);

        if (state is RouteOperationSuccess) {
          sm
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ));

          final rootContext = widget.rootNavigatorKey.currentContext;
          if (rootContext != null) {
            rootContext.read<RouteBloc>().add(LoadRoute());
          }
          context.go('/rutas');
        } else if (state is RouteError) {
          sm
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ));
        }
      },
      child: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          if (state is RouteCreating) {
            // IMPORTANTÍSIMO: extraer aquí para no tipar mal más abajo
            final List<POI> unasignedPOIs = state.unasignedPOIs;

            const double kFormWidth = 500;
            const double kGutter = 24;

            return Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(kGutter),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Panel formulario
                  SizedBox(width: kFormWidth, child: _buildForm(unasignedPOIs)),
                  const SizedBox(width: kGutter),
                  // Panel mapa
                  Expanded(child: _buildMapPreview()),
                ],
              ),
            );
          }

          // Otros estados -> loader
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// Recibe las POIs no asignadas tipadas correctamente (NO RouteState).
  Widget _buildForm(List<POI> unasignedPOIs) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _createRouteFormKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? "Editar Ruta" : "Crear Ruta",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing
                      ? "Modifica los datos de la ruta seleccionada"
                      : "Define los puntos de inicio y fin para crear una nueva ruta",
                  style: const TextStyle(color: Colors.black54),
                ),
                const Divider(height: 24),

                // Info ruta
                BuildSection(
                  mainColor: mainColor,
                  title: "Información de la Ruta",
                  subtitle: "Nombre identificador de la ruta",
                  child: TextFormField(
                    controller: _nameController,
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Ruta',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => InputValidators.validateTextField(
                      value,
                      emptyMessage: 'Por favor ingresa un nombre',
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Punto inicial
                _buildCoordinateFields(
                  "Punto Inicial",
                  _initialLatController,
                  _initialLongController,
                ),
                const SizedBox(height: 20),

                // Punto final
                _buildCoordinateFields(
                  "Punto Final",
                  _finalLatController,
                  _finalLongController,
                ),
                const SizedBox(height: 20),

                // POIs
                _buildPOISelector(unasignedPOIs),
                const SizedBox(height: 32),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text("Cancelar", style: TextStyle(color: mainColor)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_createRouteFormKey.currentState!.validate()) {
                            _fnAddRoute();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'Actualizar ruta' : 'Crear ruta',
                          style: const TextStyle(color: Colors.white),
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
    );
  }

  Widget _buildCoordinateFields(
    String title,
    TextEditingController lat,
    TextEditingController lon,
  ) {
    return BuildSection(
      mainColor: mainColor,
      title: title,
      subtitle: "Coordenadas del punto",
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: lat,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Latitud',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                ..._numberFormattersBase,
                RangeTextInputFormatter(
                  min: InputValidators.minChileLatitude,
                  max: InputValidators.maxChileLatitude,
                ),
              ],
              validator: InputValidators.validateLatitude,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: lon,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Longitud',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                ..._numberFormattersBase,
                RangeTextInputFormatter(
                  min: InputValidators.minChileLongitude,
                  max: InputValidators.maxChileLongitude,
                ),
              ],
              validator: InputValidators.validateLongitude,
            ),
          ),
        ],
      ),
    );
  }

  /// Selector de POIs (recibe explícitamente la lista no asignada).
  Widget _buildPOISelector(List<POI> unasignedPOIs) {
    final routePOIs = widget.route?.pois ?? [];

    final allPOIsMap = <String, POI>{};
    for (var poi in routePOIs) {
      allPOIsMap[poi.id] = poi;
    }
    for (var poi in unasignedPOIs) {
      allPOIsMap[poi.id] = poi;
    }
    final allPOIs = allPOIsMap.values.toList();

    if (routePOIs.isNotEmpty && !_initialPOIsApplied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _multiSelectController.selectWhere(
            (element) => routePOIs.any((poi) => poi.id == element.value.id),
          );
        } catch (_) {
        } finally {
          _initialPOIsApplied = true;
        }
      });
    }
    if (routePOIs.isEmpty && !_initialPOIsApplied) {
      _initialPOIsApplied = true;
    }

    if (allPOIs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No hay puntos de interés disponibles para asignar.',
          style: TextStyle(color: Colors.red[700], fontSize: 16),
        ),
      );
    }

    return BuildSection(
      mainColor: mainColor,
      title: "Puntos de Interés",
      subtitle: "Selecciona los POIs a incluir",
      child: MultiDropdown(
        items: allPOIs
            .map((poi) => DropdownItem(label: poi.nombre, value: poi))
            .toList(),
        controller: _multiSelectController,
        enabled: true,
        searchEnabled: true,
        fieldDecoration: const FieldDecoration(
          labelText: 'Selecciona POIs',
          hintText: 'Selecciona POIs',
          border: OutlineInputBorder(),
        ),
        searchDecoration: const SearchFieldDecoration(
          hintText: 'Buscar',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vista previa de la Ruta",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "El mapa mostrara la ruta al ingresar las coordenadas o seleccionando los puntos en el mapa",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter:
                    _initialLatLng ?? _finalLatLng ?? LatLng(-35.6960, -71.4060),
                initialZoom: 13,
                minZoom: 4,
                maxZoom: 18,
                onTap: (tapPosition, latLng) {
                  _handleMapTap(latLng);
                },
                // Evito APIs que varían entre versiones. Si usas flutter_map >=6
                // y quieres restringir cámara, puedes reactivar CameraConstraint.
                onMapReady: () {
                  _mapReady = true;
                  if (_pendingRouteBounds != null) {
                    final b = _pendingRouteBounds!;
                    _pendingRouteBounds = null;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      try {
                        mapController.fitCamera(
                          CameraFit.bounds(
                            bounds: b,
                            padding: const EdgeInsets.all(24),
                          ),
                        );
                      } catch (_) {
                        // Fallback por si fitCamera falla según versión
                        mapController.move(b.center, 13);
                      }
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${ApiKeys.maptilerKey}',
                  minZoom: 4,
                  maxZoom: 18,
                  maxNativeZoom: 18,
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
                    ..._multiSelectController.selectedItems
                        .where((item) {
                          final lat = item.value.latitud;
                          final lon = item.value.longitud;
                          return lat.isFinite &&
                              lon.isFinite &&
                              lat >= -90 &&
                              lat <= 90 &&
                              lon >= -180 &&
                              lon <= 180;
                        })
                        .map(
                          (item) => Marker(
                            point:
                                LatLng(item.value.latitud, item.value.longitud),
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
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: mainColor,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (_routeLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(),
          ),
        if (_routeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _routeError!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  void _fnAddRoute() {
    final name = _nameController.text.trim();
    final initialLat = _initialLatController.text.trim();
    final initialLong = _initialLongController.text.trim();
    final finalLat = _finalLatController.text.trim();
    final finalLong = _finalLongController.text.trim();

    final routeBloc = context.read<RouteBloc>();
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
      geometry: _routePoints,
    );

    if (_isEditing) {
      routeBloc.add(UpdateRoute(updatedRoute));
    } else {
      routeBloc.add(AddRoute(updatedRoute));
    }
  }
}
