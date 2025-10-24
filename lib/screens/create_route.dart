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

/// Formatter de rango tolerante con prefijos:
/// - Permite estados intermedios ("", "-", ".", "-.", "+", "+.")
/// - Mientras no se completan los dígitos enteros mínimos del mayor valor absoluto
///   del rango (p.ej., 2 dígitos para 56/76), deja escribir.
/// - Cuando ya hay suficientes dígitos, aplica el rango estrictamente.
class RangeTextInputFormatter extends TextInputFormatter {
  final double min;
  final double max;

  RangeTextInputFormatter({required this.min, required this.max})
    : assert(min <= max);

  int _requiredIntegerDigits() {
    final absMax = (min.abs() > max.abs()) ? min.abs() : max.abs();
    final intPart = absMax.floor();
    return intPart.toString().length; // 2 para 56/76; 3 si fuese >=100
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trim();

    // Estados intermedios permitidos durante la escritura
    if (text.isEmpty ||
        text == '-' ||
        text == '+' ||
        text == '.' ||
        text == '-.' ||
        text == '+.') {
      return newValue;
    }

    // Si aún no es parseable (ej: "1.-"), deja corregir
    final v = double.tryParse(text);
    if (v == null) return newValue;

    // Extraer parte entera para saber cuántos dígitos lleva
    final match = RegExp(r'^([+-]?)(\d*)(?:\.(\d*))?$').firstMatch(text);
    String intPart = '';
    if (match != null) {
      intPart = match.group(2) ?? '';
    }

    // Hasta completar los dígitos enteros mínimos, no bloqueamos
    final needDigits = _requiredIntegerDigits();
    if (intPart.isEmpty || intPart.length < needDigits) {
      return newValue;
    }

    // Ya hay suficientes dígitos -> validar rango
    if (v < min || v > max) {
      return oldValue; // bloquear
    }
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
  LatLng? _initialLatLng;
  LatLng? _finalLatLng;
  List<LatLng> _routePoints = [];
  bool _routeLoading = false;
  String? _routeError;
  Timer? _routeDebounce;
  String? _lastRouteKey;

  final MapController mapController = MapController();
  final _createRouteFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _initialLatController = TextEditingController();
  final TextEditingController _initialLongController = TextEditingController();
  final TextEditingController _finalLatController = TextEditingController();
  final TextEditingController _finalLongController = TextEditingController();
  final MultiSelectController<POI> _multiSelectController =
      MultiSelectController<POI>();
  bool _initialPOIsApplied = false;

  // Control de estado del mapa para no usar el controller antes de tiempo
  bool _mapReady = false;
  LatLngBounds? _pendingRouteBounds;

  final Color mainColor = const Color(0xFF4D67AE);

  bool get _isEditing => widget.route != null;

  // Permite signo, enteros y decimales (hasta 8 decimales)
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
    if (_initialLatLng != null && _finalLatLng != null) {
      // Validate within allowed ranges before fetching
      final okInitialLat =
          InputValidators.validateLatitude(_initialLatController.text) == null;
      final okInitialLng =
          InputValidators.validateLongitude(_initialLongController.text) ==
          null;
      final okFinalLat =
          InputValidators.validateLatitude(_finalLatController.text) == null;
      final okFinalLng =
          InputValidators.validateLongitude(_finalLongController.text) == null;

      if (okInitialLat && okInitialLng && okFinalLat && okFinalLng) {
        // Debounce rapid changes while typing
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
        // Inputs out of allowed range; clear route preview
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
    if (_routeLoading) {
      return;
    }
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
      setState(() {
        _routePoints = points;
      });

      if (_routePoints.isNotEmpty) {
        try {
          final clean = _routePoints
              .where(
                (p) =>
                    p.latitude.isFinite &&
                    p.longitude.isFinite &&
                    p.latitude >= -90 &&
                    p.latitude <= 90 &&
                    p.longitude >= -180 &&
                    p.longitude <= 180,
              )
              .toList(growable: false);
          if (clean.isEmpty) {
            // avoid fitting when all points are invalid
            return;
          }
          final bounds = clean.length >= 2
              ? LatLngBounds.fromPoints(clean)
              : LatLngBounds(clean.first, clean.first);
          if (!_mapReady) {
            _pendingRouteBounds =
                bounds; // diferir hasta que el mapa esté listo
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              try {
                mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(24),
                  ),
                );
              } catch (_) {}
            });
          }
        } catch (_) {}
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
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
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
                            autovalidateMode:
                                AutovalidateMode.always, // error al instante
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
                                  subtitle: "Nombre identificador de la ruta",
                                  child: TextFormField(
                                    controller: _nameController,
                                    autocorrect: true,
                                    enableSuggestions: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre de la Ruta',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) =>
                                        InputValidators.validateTextField(
                                          value,
                                          emptyMessage:
                                              'Por favor ingresa un nombre',
                                        ),
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
                                          autocorrect: false,
                                          enableSuggestions: false,
                                          decoration: const InputDecoration(
                                            labelText: 'Latitud',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                                signed: true,
                                              ),
                                          inputFormatters: [
                                            ..._numberFormattersBase,
                                            // Limite Chile (usa tus constantes)
                                            RangeTextInputFormatter(
                                              min: InputValidators
                                                  .minChileLatitude,
                                              max: InputValidators
                                                  .maxChileLatitude,
                                            ),
                                          ],
                                          validator:
                                              InputValidators.validateLatitude,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _initialLongController,
                                          autocorrect: false,
                                          enableSuggestions: false,
                                          decoration: const InputDecoration(
                                            labelText: 'Longitud',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                                signed: true,
                                              ),
                                          inputFormatters: [
                                            ..._numberFormattersBase,
                                            // Limite Chile (usa tus constantes)
                                            RangeTextInputFormatter(
                                              min: InputValidators
                                                  .minChileLongitude,
                                              max: InputValidators
                                                  .maxChileLongitude,
                                            ),
                                          ],
                                          validator:
                                              InputValidators.validateLongitude,
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
                                          autocorrect: false,
                                          enableSuggestions: false,
                                          decoration: const InputDecoration(
                                            labelText: 'Latitud',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                                signed: true,
                                              ),
                                          inputFormatters: [
                                            ..._numberFormattersBase,
                                            RangeTextInputFormatter(
                                              min: InputValidators
                                                  .minChileLatitude,
                                              max: InputValidators
                                                  .maxChileLatitude,
                                            ),
                                          ],
                                          validator:
                                              InputValidators.validateLatitude,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _finalLongController,
                                          autocorrect: false,
                                          enableSuggestions: false,
                                          decoration: const InputDecoration(
                                            labelText: 'Longitud',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                                signed: true,
                                              ),
                                          inputFormatters: [
                                            ..._numberFormattersBase,
                                            RangeTextInputFormatter(
                                              min: InputValidators
                                                  .minChileLongitude,
                                              max: InputValidators
                                                  .maxChileLongitude,
                                            ),
                                          ],
                                          validator:
                                              InputValidators.validateLongitude,
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

                                    final allPOIsMap = <String, POI>{};
                                    for (var poi in routePOIs) {
                                      allPOIsMap[poi.id] = poi;
                                    }
                                    for (var poi in unasignedPOIs) {
                                      allPOIsMap[poi.id] = poi;
                                    }
                                    final allPOIs = allPOIsMap.values.toList();

                                    if (routePOIs.isNotEmpty &&
                                        !_initialPOIsApplied) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            try {
                                              _multiSelectController
                                                  .selectWhere(
                                                    (element) => routePOIs.any(
                                                      (poi) =>
                                                          poi.id ==
                                                          element.value.id,
                                                    ),
                                                  );
                                            } catch (_) {
                                            } finally {
                                              _initialPOIsApplied = true;
                                            }
                                          });
                                    }
                                    if (routePOIs.isEmpty &&
                                        !_initialPOIsApplied) {
                                      _initialPOIsApplied = true;
                                    }

                                    if (allPOIs.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
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
                                        controller: _multiSelectController,
                                        enabled: true,
                                        searchEnabled: true,
                                        fieldDecoration: const FieldDecoration(
                                          labelText: 'Selecciona POIs',
                                          hintText: 'Selecciona POIs',
                                          border: OutlineInputBorder(),
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
                                          style: TextStyle(color: mainColor),
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
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: mainColor,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _isEditing
                                              ? 'Actualizar ruta'
                                              : 'Crear ruta',
                                          style: const TextStyle(
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
                                initialCenter:
                                    _initialLatLng ??
                                    _finalLatLng ??
                                    LatLng(-35.6960, -71.4060),
                                initialZoom: 13,

                                // ⬇️ Control de zoom y restricción de cámara (añadido)
                                minZoom: 4,
                                maxZoom: 18,
                                cameraConstraint: CameraConstraint.contain(
                                  bounds: LatLngBounds(
                                    const LatLng(-90, -180),
                                    const LatLng(90, 180),
                                  ),
                                ),

                                onMapReady: () {
                                  _mapReady = true;
                                  if (_pendingRouteBounds != null) {
                                    final b = _pendingRouteBounds!;
                                    _pendingRouteBounds = null;
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (!mounted) return;
                                          try {
                                            mapController.fitCamera(
                                              CameraFit.bounds(
                                                bounds: b,
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                              ),
                                            );
                                          } catch (_) {}
                                        });
                                  }
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${ApiKeys.maptilerKey}',

                                  // ⬇️ Límites de zoom del mapa base (añadido)
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
                                if (_routePoints.isNotEmpty)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: _routePoints
                                            .where(
                                              (p) =>
                                                  p.latitude.isFinite &&
                                                  p.longitude.isFinite &&
                                                  p.latitude >= -90 &&
                                                  p.latitude <= 90 &&
                                                  p.longitude >= -180 &&
                                                  p.longitude <= 180,
                                            )
                                            .toList(growable: false),
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
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

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
