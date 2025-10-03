

import 'package:crud_rutas360/blocs/activity_bloc.dart';
import 'package:crud_rutas360/events/activity_event.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/states/activity_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';

class ActivityForm extends StatefulWidget {
  const ActivityForm({super.key});

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final _createActivityFormKey = GlobalKey<FormState>();

  final TextEditingController _nameEsController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _namePtController = TextEditingController();
  final TextEditingController _textHexColorController = TextEditingController();
  final TextEditingController _backgroundHexColorController =
      TextEditingController();
  Color textColor = Colors.black;
  Color backgroundColor = Colors.grey;
  bool _initialized = false;
  Activity? _lastActivity;

  void changeTextColor(Color color) {
    setState(() => textColor = color);
  }

  void changeBackgroundColor(Color color) {
    setState(() => backgroundColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityBloc, ActivityState>(
      listener: (context, state) {
        if (state is ActivityOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        Activity? activity;
        if (state is ActivityFormState) {
          activity = state.activity;
          if (activity != null && (!_initialized || activity != _lastActivity)) {
            _nameEsController.text = activity.nombre['es'] ?? '';
            _nameEnController.text = activity.nombre['en'] ?? '';
            _namePtController.text = activity.nombre['pt'] ?? '';
            textColor = getColorFromHex(activity.textColor);
            backgroundColor = getColorFromHex(activity.backgroundColor);
            _textHexColorController.text = activity.textColor.replaceAll('#', '');
            _backgroundHexColorController.text = activity.backgroundColor.replaceAll('#', '');
            _initialized = true;
            _lastActivity = activity;
          }
        }
  

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Form(
                          key: _createActivityFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Crear Actividad',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameEsController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre de la actividad',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese el nombre de la actividad';
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Chip(
                          backgroundColor: backgroundColor,
                          label: Text(
                            _nameEsController.text.isEmpty
                                ? 'Nombre de la actividad'
                                : _nameEsController.text,
                            style: TextStyle(color: textColor, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Color del texto"),
                    const SizedBox(height: 16),
                    Wrap(
                      children: [
                        ColorPicker(
                          pickerColor: textColor,
                          onColorChanged: changeTextColor,
                          enableAlpha: false,
                          hexInputController: _textHexColorController,
                          hexInputBar: true,
                          paletteType: PaletteType.hsv,
                          labelTypes: [],
                          displayThumbColor: true,
                          pickerAreaHeightPercent: 0.7,
                          pickerAreaBorderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("Color del fondo"),
                    const SizedBox(height: 16),
                    Wrap(
                      children: [
                        ColorPicker(
                          pickerColor: backgroundColor,
                          onColorChanged: changeBackgroundColor,
                          enableAlpha: false,
                          hexInputController: _backgroundHexColorController,
                          hexInputBar: true,
                          paletteType: PaletteType.hsv,
                          labelTypes: [],
                          displayThumbColor: true,
                          pickerAreaHeightPercent: 0.7,
                          pickerAreaBorderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                context.read<ActivityBloc>().add(LoadActivities());
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
                                if (_createActivityFormKey.currentState!
                                    .validate()) {
                                  if (activity != null) {
                                    // Si activity no es nulo, estamos editando una actividad existente
                                    _fnAddActivity(activity);
                                  } else {
                                    // Si activity es nulo, estamos creando una nueva actividad
                                    _fnAddActivity(null);
                                  }
                                  context.pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4D67AE),
                              ),
                              child: Text(
                                activity == null ? 'Crear' : 'Actualizar',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(flex: 1, child: SizedBox(width: 20)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _fnAddActivity(Activity? activity) {
    final id = _nameEsController.text.trim().toLowerCase();
    final nombre = {
      'es': _nameEsController.text.trim(),
      'en': _nameEnController.text.trim(),
      'pt': _namePtController.text.trim(),
    };
    final colorDelTexto = "#${_textHexColorController.text.trim()}";
    final colorDeFondo = "#${_backgroundHexColorController.text.trim()}";

    Activity newActivity = Activity(
      id: id,
      nombre: nombre,
      textColor: colorDelTexto,
      backgroundColor: colorDeFondo,
    );
    if (activity == null) {
      context.read<ActivityBloc>().add(AddActivity(newActivity));
    } else {
      context.read<ActivityBloc>().add(UpdateActivity(newActivity));
    }
  }

  Color getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor"; // add alpha if missing
      }
      if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
      return Colors.transparent;
    } catch (e) {
      return Colors.transparent;
    }
  }
}
