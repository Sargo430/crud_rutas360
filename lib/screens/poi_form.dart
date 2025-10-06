import 'package:crud_rutas360/blocs/poi_bloc.dart';
import 'package:crud_rutas360/events/poi_events.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/states/poi_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

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
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PoiBloc, PoiState>(
      listener: (context, state) {
        if (state is PoiOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        POI? poi;
        if (state is PoiFormState) {
          poi = state.poi;
          if (poi != null) {
            _nameController.text = poi.nombre;
            _descEsController.text = poi.descripcion['es'] ?? '';
            _descEnController.text = poi.descripcion['en'] ?? '';
            _descPtController.text = poi.descripcion['pt'] ?? '';
            _latController.text = poi.latitud.toString();
            _longController.text = poi.longitud.toString();

            if (poi.categorias.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  _multiSelectCategoryController.selectWhere(
                    (item) => (poi?.categorias ?? []).any(
                      (cat) => cat.id == item.value.id,
                    ),
                  );
                } catch (_) {
                  // Handle error
                }
              });
            }

           if (poi.actividades.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  _multiSelectActivityController.selectWhere(
                    (item) => (poi?.actividades ?? []).any(
                      (act) => act.id == item.value.id,
                    ),
                  );
                } catch (_) {
                  // Handle error
                }
              });
            }
            dropdownValue = poi.routeId ?? "sin_asignar";
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
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
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre del Punto de Interés',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese el nombre del punto de interés';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descEsController,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Descripción en Español del Punto de Interés',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese la descripción en español del punto de interés';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descEnController,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Descripción en Inglés del Punto de Interés',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descPtController,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Descripción en Portugués del Punto de Interés',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _latController,
                                  decoration: const InputDecoration(
                                    labelText: 'Latitud',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese la latitud';
                                    }
                                    final numValue = double.tryParse(value);
                                    if (numValue == null) {
                                      return 'Ingresa un número válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _longController,
                                  decoration: const InputDecoration(
                                    labelText: 'Longitud',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese la longitud';
                                    }
                                    final numValue = double.tryParse(value);
                                    if (numValue == null) {
                                      return 'Ingresa un número válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                MultiDropdown(
                                  items: state.categories
                                      .map(
                                        (category) => DropdownItem(
                                          label: category.nombre['es'],
                                          value: category,
                                        ),
                                      )
                                      .toList(),
                                  controller: _multiSelectCategoryController,
                                  enabled: true,
                                  searchEnabled: true,
                                  fieldDecoration: FieldDecoration(
                                    labelText: 'Selecciona categorias',
                                    hintText: 'Selecciona categorias',
                                    border: OutlineInputBorder(),
                                  ),
                                  searchDecoration: SearchFieldDecoration(
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
                                  controller: _multiSelectActivityController,
                                  enabled: true,
                                  searchEnabled: true,
                                  fieldDecoration: FieldDecoration(
                                    labelText: 'Selecciona actividades',
                                    hintText: 'Selecciona actividades',
                                    border: OutlineInputBorder(),
                                  ),
                                  searchDecoration: SearchFieldDecoration(
                                    hintText: 'Buscar',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DropdownMenu<String>(
                                  width: double.infinity,
                                  initialSelection: "sin_asignar",
                                  dropdownMenuEntries: [
                                    ...state.routes.map(
                                      (route) => DropdownMenuEntry<String>(
                                        value: route.id,
                                        label: route.name,
                                      ),
                                    ),
                                  ],
                                  onSelected: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        dropdownValue = newValue;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          if (_createPoiFormKey.currentState!
                                              .validate()) {
                                            if (poi != null) {
                                              // Si poi no es nulo, estamos editando un POI existente
                                              _fnAddPoi(poi);
                                            } else {
                                              // Si poi es nulo, estamos creando un nuevo POI
                                              _fnAddPoi(null);
                                            }
                                            context.pop();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF4D67AE),
                                        ),
                                        child: Text(
                                          poi == null ? 'Crear' : 'Actualizar',
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
                  Expanded(flex: 1, child: Text("vista previa")),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _fnAddPoi(POI? poi) {
    final String name = _nameController.text;
    final String descEs = _descEsController.text;
    final String descEn = _descEnController.text;
    final String descPt = _descPtController.text;
    final double lat = double.parse(_latController.text);
    final double long = double.parse(_longController.text);
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
    String poiId = '';
    if (poi != null) {
      poiId = poi.id;
    }

    final POI newPoi = POI(
      routeId: dropdownValue,
      id: poiId,
      nombre: name,
      descripcion: descripcion,
      latitud: lat,
      longitud: long,
      categorias: selectedCategories,
      actividades: selectedActivities,
      imagen: '',
      vistas360: {},
    );

    if (poi != null) {
      context.read<PoiBloc>().add(UpdatePOI(newPoi));
    } else {
      context.read<PoiBloc>().add(AddPOI(newPoi));
    }
  }
}
