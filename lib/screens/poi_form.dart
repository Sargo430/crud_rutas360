import 'package:crud_rutas360/blocs/poi_bloc.dart';
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
                                      .map((category) => DropdownItem(
                                          label: category.nombre['es'],
                                          value: category))
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: Text("Vista Previa")),
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
}
