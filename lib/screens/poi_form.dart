import 'package:crud_rutas360/blocs/poi_bloc.dart';
import 'package:crud_rutas360/events/poi_events.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/screens/poi_widget.dart';
import 'package:crud_rutas360/services/input_validators.dart';
import 'package:crud_rutas360/states/poi_state.dart';
import 'package:crud_rutas360/widgets/build_section.dart';
import 'package:crud_rutas360/widgets/loading_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:file_picker/file_picker.dart';

class PoiForm extends StatefulWidget {
  const PoiForm({super.key});

  @override
  State<PoiForm> createState() => _PoiFormState();
}

class _PoiFormState extends State<PoiForm> {
  final _createPoiFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descEsController = TextEditingController();
  final TextEditingController _descEnController = TextEditingController();
  final TextEditingController _descPtController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final MultiSelectController<PoiCategory> _multiSelectCategoryController =
      MultiSelectController<PoiCategory>();
  final MultiSelectController<Activity> _multiSelectActivityController =
      MultiSelectController<Activity>();
  String dropdownValue = "sin_asignar";
  final Color mainColor = const Color(0xFF4D67AE);
  PlatformFile? _pickedImage;
  PlatformFile? _winter360view;
  PlatformFile? _spring360view;
  PlatformFile? _summer360view;
  PlatformFile? _autumn360view;
  bool _initializedFromPoi = false;

  void _scheduleRebuild() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to text controllers to update preview in real-time
    _nameController.addListener(_scheduleRebuild);
    _descEsController.addListener(_scheduleRebuild);
    _descEnController.addListener(_scheduleRebuild);
    _descPtController.addListener(_scheduleRebuild);
    _latController.addListener(_scheduleRebuild);
    _longController.addListener(_scheduleRebuild);
    
    // Add listeners to multi-select controllers
    _multiSelectCategoryController.addListener(_scheduleRebuild);
    _multiSelectActivityController.addListener(_scheduleRebuild);
  }

  @override
  void dispose() {
    // Clean up listeners
    _nameController.dispose();
    _descEsController.dispose();
    _descEnController.dispose();
    _descPtController.dispose();
    _latController.dispose();
    _longController.dispose();
    _multiSelectCategoryController.dispose();
    _multiSelectActivityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PoiBloc, PoiState>(
      listener: (context, state) {
        if (state is PoiOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          // Navigate back to POI table after successful operation
          context.go('/pois');
        } else if (state is PoiLoadedWithSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          // Navigate back to POI table after successful operation
          context.go('/pois');
        }
      },
      builder: (context, state) {
        POI? poi;
        if (state is PoiFormState) {
          poi = state.poi;
          if (poi != null && !_initializedFromPoi) {
            // Initialize controllers and selections after this build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final p = poi!; // capture non-null value for this callback
              _nameController.text = p.nombre;
              _descEsController.text = p.descripcion['es'] ?? '';
              _descEnController.text = p.descripcion['en'] ?? '';
              _descPtController.text = p.descripcion['pt'] ?? '';
              _latController.text = p.latitud.toString();
              _longController.text = p.longitud.toString();

              if (p.categorias.isNotEmpty) {
                try {
                  _multiSelectCategoryController.selectWhere(
                    (item) => (p.categorias).any(
                      (cat) => cat.id == item.value.id,
                    ),
                  );
                } catch (_) {}
              }

              if (p.actividades.isNotEmpty) {
                try {
                  _multiSelectActivityController.selectWhere(
                    (item) => (p.actividades).any(
                      (act) => act.id == item.value.id,
                    ),
                  );
                } catch (_) {}
              }
              dropdownValue = p.routeId ?? "sin_asignar";
              _initializedFromPoi = true;
              _scheduleRebuild();
            });
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Form(
                              key: _createPoiFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Crear Punto de Interés',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  BuildSection(
                                    mainColor: mainColor,
                                    title: "Nombre del punto de interés",
                                    subtitle:
                                        "Nombre identificador del punto de interés",
                                    child: TextFormField(
                                      controller: _nameController,
                                      autocorrect: true,
                                      enableSuggestions: true,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Nombre del Punto de Interés',
                                        border: OutlineInputBorder(),
                                      ),
                                      // Validamos nombre obligatorio evitando lenguaje ofensivo.
                                      validator: (value) =>
                                          InputValidators.validateTextField(
                                        value,
                                        emptyMessage:
                                            'Por favor ingrese el nombre del punto de interes',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  BuildSection(
                                    mainColor: mainColor,
                                    title: "Descripción del punto de interés",
                                    subtitle:
                                        "Breve descripción del punto de interés",
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: mainColor,
                                              child: Text(
                                                'ES',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _descEsController,
                                                autocorrect: true,
                                                enableSuggestions: true,
                                                decoration: const InputDecoration(
                                                  labelText:
                                                      'Descripción en Español del Punto de Interés',
                                                  border: OutlineInputBorder(),
                                                ),
                                                maxLines: 3,
                                                // Validamos longitud minima y lenguaje en la descripcion principal.
                                                validator: (value) =>
                                                    InputValidators.validateDescriptionField(
                                                  value,
                                                  isRequired: true,
                                                  emptyMessage:
                                                      'Por favor ingrese la descripcion en espanol del punto de interes',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: mainColor,
                                              child: Text(
                                                'EN',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _descEnController,
                                                autocorrect: true,
                                                enableSuggestions: true,
                                                decoration: const InputDecoration(
                                                  labelText:
                                                      'Descripción en Inglés del Punto de Interés',
                                                  border: OutlineInputBorder(),
                                                ),
                                                maxLines: 3,
                                                // Evitamos lenguaje ofensivo y textos muy cortos si se completa.
                                                validator: (value) =>
                                                    InputValidators.validateDescriptionField(
                                                  value,
                                                  isRequired: false,
                                                  emptyMessage:
                                                      'Por favor ingrese la descripcion en ingles del punto de interes',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: mainColor,
                                              child: Text(
                                                'PT',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _descPtController,
                                                autocorrect: true,
                                                enableSuggestions: true,
                                                decoration: const InputDecoration(
                                                  labelText:
                                                      'Descripción en Portugués del Punto de Interés',
                                                  border: OutlineInputBorder(),
                                                ),
                                                maxLines: 3,
                                                // Validamos entradas opcionales evitando lenguaje ofensivo.
                                                validator: (value) =>
                                                    InputValidators.validateDescriptionField(
                                                  value,
                                                  isRequired: false,
                                                  emptyMessage:
                                                      'Por favor ingrese la descripcion en portugues del punto de interes',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  BuildSection(
                                    mainColor: mainColor,
                                    title: "Ubicación",
                                    subtitle:
                                        "Coordenadas del punto de interés",
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _latController,
                                            autocorrect: false,
                                            enableSuggestions: false,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                              decimal: true,
                                              signed: true,
                                            ),
                                            decoration: const InputDecoration(
                                              labelText: 'Latitud',
                                              border: OutlineInputBorder(),
                                            ),
                                            // Validamos que la latitud sea numerica y dentro de Chile.
                                            validator: InputValidators.validateLatitude,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _longController,
                                            autocorrect: false,
                                            enableSuggestions: false,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                              decimal: true,
                                              signed: true,
                                            ),
                                            decoration: const InputDecoration(
                                              labelText: 'Longitud',
                                              border: OutlineInputBorder(),
                                            ),
                                            // Validamos que la longitud respete el rango nacional.
                                            validator: InputValidators.validateLongitude,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  BuildSection(
                                    mainColor: mainColor,
                                    title: "Información adicional",
                                    subtitle:
                                        "Selecciona la ruta asociada, categorías y actividades",
                                    child: Column(
                                      children: [
                                        MultiDropdown(
                                          items: state.categories
                                              .map(
                                                (category) => DropdownItem(
                                                  label: category.nombre['es'],
                                                  value: category,
                                                ),
                                              )
                                              .toList(),
                                          controller:
                                              _multiSelectCategoryController,
                                          enabled: true,
                                          searchEnabled: true,
                                          fieldDecoration: FieldDecoration(
                                            labelText: 'Selecciona categorias',
                                            hintText: 'Selecciona categorias',
                                            border: OutlineInputBorder(),
                                          ),
                                          searchDecoration:
                                              SearchFieldDecoration(
                                                hintText: 'Buscar',
                                                border: OutlineInputBorder(),
                                              ),
                                        ),
                                        const SizedBox(height: 16),
                                        MultiDropdown(
                                          items: state.activities
                                              .map(
                                                (activity) => DropdownItem(
                                                  label: activity.nombre['es'],
                                                  value: activity,
                                                ),
                                              )
                                              .toList(),
                                          controller:
                                              _multiSelectActivityController,
                                          enabled: true,
                                          searchEnabled: true,
                                          fieldDecoration: FieldDecoration(
                                            labelText: 'Selecciona actividades',
                                            hintText: 'Selecciona actividades',
                                            border: OutlineInputBorder(),
                                          ),
                                          searchDecoration:
                                              SearchFieldDecoration(
                                                hintText: 'Buscar',
                                                border: OutlineInputBorder(),
                                              ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: DropdownMenu<String>(
                                            expandedInsets: EdgeInsets.zero,
                                            initialSelection: "sin_asignar",
                                            dropdownMenuEntries: [
                                              ...state.routes.map(
                                                (route) =>
                                                    DropdownMenuEntry<String>(
                                                      value: route.id,
                                                      label: route.name,
                                                    ),
                                              ),
                                            ],
                                            onSelected: (String? newValue) {
                                              if (newValue != null && mounted) {
                                                setState(() {
                                                  dropdownValue = newValue;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  BuildSection(
                                    mainColor: mainColor,
                                    title: "Imágenes",
                                    subtitle:
                                        "Imagen representativa y vistas 360",
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Imagen del Punto de Interés",
                                                ),
                                                if (poi == null) // Show required indicator for new POIs
                                                  Text(
                                                    " *",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                const SizedBox(width: 16),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final picked =
                                                        await _pickImage();
                                                    if (mounted) {
                                                      setState(() {
                                                        _pickedImage = picked;
                                                      });
                                                    }
                                                  },
                                                  child: const Text(
                                                    "Seleccionar Imagen",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            if (_pickedImage != null)
                                              Text(
                                                'Imagen seleccionada: ${_pickedImage!.name}',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            else
                                              Text(
                                                poi == null 
                                                  ? 'No se ha seleccionado imagen (requerido)'
                                                  : 'No se ha seleccionado imagen nueva',
                                                style: TextStyle(
                                                  color: poi == null ? Colors.red : Colors.black54,
                                                  fontWeight: poi == null ? FontWeight.w500 : FontWeight.normal,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Vista 360 de invierno del Punto de Interés",
                                                ),
                                                const SizedBox(width: 16),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final picked =
                                                        await _pickImage();
                                                    if (mounted) {
                                                      setState(() {
                                                        _winter360view = picked;
                                                      });
                                                    }
                                                  },
                                                  child: const Text(
                                                    "Seleccionar Imagen",

                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            if (_winter360view != null)
                                              Text(
                                                'Imagen seleccionada: ${_winter360view!.name}',
                                                style:  TextStyle(color: Colors.green, fontWeight: FontWeight.w500)
                                              )
                                            else if (poi?.vistas360['Invierno'] != null && poi!.vistas360['Invierno'].toString().trim().isNotEmpty)
                                              Text(
                                                'Imagen existente en Firebase disponible',
                                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)
                                              )
                                            else
                                              Text(
                                                'No se ha seleccionado imagen',
                                                style:  TextStyle(color: Colors.black54)
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Vista 360 de primavera del Punto de Interés",
                                                ),
                                                const SizedBox(width: 16),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final picked =
                                                        await _pickImage();
                                                    if (mounted) {
                                                      setState(() {
                                                        _spring360view = picked;
                                                      });
                                                    }
                                                  },
                                                  child: const Text(
                                                    "Seleccionar Imagen",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            if (_spring360view != null)
                                              Text(
                                                'Imagen seleccionada: ${_spring360view!.name}',
                                                style:  TextStyle(color: Colors.green, fontWeight: FontWeight.w500)
                                              )
                                            else if (poi?.vistas360['Primavera'] != null && poi!.vistas360['Primavera'].toString().trim().isNotEmpty)
                                              Text(
                                                'Imagen existente en Firebase disponible',
                                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)
                                              )
                                            else
                                              Text(
                                                'No se ha seleccionado imagen',
                                                style:  TextStyle(color: Colors.black54)
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Vista 360 de verano del Punto de Interés",
                                                ),
                                                const SizedBox(width: 16),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final picked =
                                                        await _pickImage();
                                                    if (mounted) {
                                                      setState(() {
                                                        _summer360view = picked;
                                                      });
                                                    }
                                                  },
                                                  child: const Text(
                                                    "Seleccionar Imagen",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            if (_summer360view != null)
                                              Text(
                                                'Imagen seleccionada: ${_summer360view!.name}',
                                                style:  TextStyle(color: Colors.green, fontWeight: FontWeight.w500)
                                              )
                                            else if (poi?.vistas360['Verano'] != null && poi!.vistas360['Verano'].toString().trim().isNotEmpty)
                                              Text(
                                                'Imagen existente en Firebase disponible',
                                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)
                                              )
                                            else
                                              Text(
                                                'No se ha seleccionado imagen',
                                                style:  TextStyle(color: Colors.black54)
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Vista 360 de otoño del Punto de Interés",
                                                ),
                                                const SizedBox(width: 16),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final picked =
                                                        await _pickImage();
                                                    if (mounted) {
                                                      setState(() {
                                                        _autumn360view = picked;
                                                      });
                                                    }
                                                  },
                                                  child: const Text(
                                                    "Seleccionar Imagen",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            if (_autumn360view != null)
                                              Text(
                                                'Imagen seleccionada: ${_autumn360view!.name}',
                                                style:  TextStyle(color: Colors.green, fontWeight: FontWeight.w500)
                                              )
                                            else if (poi?.vistas360['Otoño'] != null && poi!.vistas360['Otoño'].toString().trim().isNotEmpty)
                                              Text(
                                                'Imagen existente en Firebase disponible',
                                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)
                                              )
                                            else
                                              Text(
                                                'No se ha seleccionado imagen',
                                                style:  TextStyle(color: Colors.black54)
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: () {
                                            context.read<PoiBloc>().add(
                                              LoadPOIs(),
                                            );
                                            context.pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFE0E0E0),
                                          ),
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 16),
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: () async {
                                            if (_createPoiFormKey.currentState!
                                                .validate()) {
                                              // Validate image selection for new POIs
                                              if (poi == null && _pickedImage == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Por favor selecciona una imagen para el POI'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }
                                              
                                              if (poi != null) {
                                                await _fnAddPoi(poi);
                                              } else {
                                                await _fnAddPoi(null);
                                              }
                                             
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF4D67AE),
                                          ),
                                          child: Text(
                                            poi == null
                                                ? 'Crear'
                                                : 'Actualizar',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 803,
                          width: 393,
                          child: PoiScreen(
                            _nameController.text.isNotEmpty
                                ? _nameController.text
                                : 'Ingresa el nombre del POI',
                            _pickedImage,
                            {
                              'es': _descEsController.text,
                              'en': _descEnController.text,
                              'pt': _descPtController.text,
                            },
                            // Show selected categories from controller (real-time updates)
                            _multiSelectCategoryController.selectedItems
                                .map((item) => item.value)
                                .toList(),
                            // Show selected activities from controller (real-time updates)
                            _multiSelectActivityController.selectedItems
                                .map((item) => item.value)
                                .toList(),
                            {
                              'Invierno': _winter360view,
                              'Primavera': _spring360view,
                              'Verano': _summer360view,
                              'Otoño': _autumn360view,
                            },
                            imageUrl: poi?.imagen,
                            existingVistas360: poi?.vistas360,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const LoadingMessage();
        }
      },
    );
  }

  Future<void> _fnAddPoi(POI? poi) async {
    final String name = _nameController.text;
    final String descEs = _descEsController.text;
    final String descEn = _descEnController.text;
    final String descPt = _descPtController.text;
    final double lat = double.parse(_latController.text.replaceAll(',', '.'));
    final double long = double.parse(_longController.text.replaceAll(',', '.'));
    final List<PoiCategory> selectedCategories = _multiSelectCategoryController
        .selectedItems
        .map((item) => item.value)
        .toList();
    final List<Activity> selectedActivities = _multiSelectActivityController
        .selectedItems
        .map((item) => item.value)
        .toList();

    final Map<String, String> descripcion = {
      'es': descEs,
      'en': descEn,
      'pt': descPt,
    };
    String poiId = poi?.id ?? '';

    

    

    if (_pickedImage != null) {
      print('[poi_form] _fnAddPoi: New image selected for update: \\${_pickedImage!.name}');
    } else {
      print('[poi_form] _fnAddPoi: No new image selected for update');
    }
    print('[poi_form] _fnAddPoi: 360 views for update:');
    print('  Invierno: ' + (_winter360view != null ? _winter360view!.name : 'none'));
    print('  Primavera: ' + (_spring360view != null ? _spring360view!.name : 'none'));
    print('  Verano: ' + (_summer360view != null ? _summer360view!.name : 'none'));
    print('  Otoño: ' + (_autumn360view != null ? _autumn360view!.name : 'none'));
    final POI newPoi = POI(
      routeId: dropdownValue,
      id: poiId,
      nombre: name,
      descripcion: descripcion,
      latitud: lat,
      longitud: long,
      categorias: selectedCategories,
      actividades: selectedActivities,
      imagen: poi?.imagen ?? '', // never set to local path
      vistas360: {},
    );

    if (poi != null) {
      context.read<PoiBloc>().add(
        UpdatePOI(
          newPoi,
          image: _pickedImage, // optional
          new360Views: {
            'Invierno': _winter360view,
            'Primavera': _spring360view,
            'Verano': _summer360view,
            'Otoño': _autumn360view,
          },
        ),
      );
    } else {
      context.read<PoiBloc>().add(
        AddPOI(
          newPoi,
          _pickedImage!,
          {
            'Invierno': _winter360view,
            'Primavera': _spring360view,
            'Verano': _summer360view,
            'Otoño': _autumn360view,
          },
        ),
      );
    }
  }

  Future<PlatformFile?> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, // Specify to pick only images
        allowMultiple: false,
        withData: true, // ensure bytes on web
      );

      if (result != null) {
        final selected = result.files.first;
        // Protegemos el formulario ante imagenes mayores a 10 MB.
        if (InputValidators.isFileTooLarge(selected)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La imagen supera el tamaño máximo permitido (10 MB).'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return null;
        }
        return selected;
      } else {
        // User canceled the picker
        return null;
      }
    } catch (e) {
      // Handle any errors that might occur during file picking
      throw Exception('Error picking image: $e');
    }
  }
}

