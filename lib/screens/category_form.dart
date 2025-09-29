import 'package:crud_rutas360/blocs/category_bloc.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/states/category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoryForm extends StatefulWidget {
  final POI? category = null;
  const CategoryForm({super.key});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _createCategoryFormKey = GlobalKey<FormState>();

  final TextEditingController _nameEsController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _namePtController = TextEditingController();
  final TextEditingController _textHexColorController = TextEditingController();
  final TextEditingController _backgroundHexColorController =TextEditingController();
  Color textColor = Colors.black;
  Color backgroundColor = Colors.grey;

  void changeTextColor(Color color) {
    setState(() => textColor = color);
  }

  void changeBackgroundColor(Color color) {
    setState(() => backgroundColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        PoiCategory? category;
        if (state is CategoryFormState) {
          category = state.category;
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
                    child: Form(
                      key: _createCategoryFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crear Categoría',
                            style: TextStyle(fontSize: 24, color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameEsController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la categoría',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el nombre de la categoría';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameEnController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre en inglés',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _namePtController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre en portugués',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text("Color del texto"),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ColorPicker(
                                pickerColor: textColor, 
                                onColorChanged: changeTextColor,
                                enableAlpha: false,
                                hexInputController: _textHexColorController,
                                hexInputBar: true,
                                paletteType: PaletteType.hsv,
                                displayThumbColor: true,
                                pickerAreaHeightPercent: 0.7,
                                pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                            ],
                            
                          ),
                          const SizedBox(height: 16),
                          Text("Color del fondo"),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ColorPicker(
                                pickerColor: backgroundColor, 
                                onColorChanged: changeBackgroundColor,
                                enableAlpha: false,
                                hexInputController: _backgroundHexColorController,
                                hexInputBar: true,
                                paletteType: PaletteType.hsv,
                                displayThumbColor: true,
                                pickerAreaHeightPercent: 0.7,
                                pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {},
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
                                    if (_createCategoryFormKey.currentState!
                                        .validate()) {}
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
                Expanded(flex: 1, 
                child: Center(
                  child: Chip(
                    backgroundColor: backgroundColor,
                    label: Text(
                      _nameEsController.text.isEmpty
                          ? 'Nombre de la categoría'
                          : _nameEsController.text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ), 
                    ),
                )
                ),
            )],
            ),
          ),
        );
      },
    );
  }
}
