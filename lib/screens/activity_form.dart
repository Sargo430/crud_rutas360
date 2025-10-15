import 'package:crud_rutas360/blocs/activity_bloc.dart';
import 'package:crud_rutas360/events/activity_event.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/services/input_validators.dart';
import 'package:crud_rutas360/states/activity_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:crud_rutas360/widgets/loading_message.dart';

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

  Color textColor = Colors.black;
  Color backgroundColor = Colors.grey;

  bool _initialized = false;
  Activity? _lastActivity;

  final Color mainColor = const Color(0xFF4D67AE);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityBloc, ActivityState>(
      listener: (context, state) {
        if (state is ActivityLoadedWithSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is ActivityOperationSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is ActivityLoading) {
          return const LoadingMessage();
        }
        Activity? activity;
        if (state is ActivityFormState) {
          activity = state.activity;
          if (activity != null && (!_initialized || activity != _lastActivity)) {
            _nameEsController.text = activity.nombre['es'] ?? '';
            _nameEnController.text = activity.nombre['en'] ?? '';
            _namePtController.text = activity.nombre['pt'] ?? '';
            textColor = _parseHex(activity.textColor) ?? Colors.black;
            backgroundColor = _parseHex(activity.backgroundColor) ?? Colors.grey;
            _initialized = true;
            _lastActivity = activity;
          }
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Crear Actividad",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Define una nueva actividad con nombres multiidioma y personalización de colores",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),

                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Form(
                          key: _createActivityFormKey,
                          child: Column(
                            children: [
                              _buildStepCard(
                                icon: Icons.flag,
                                title: "Paso 1: Nombres de la Actividad",
                                subtitle:
                                    "Ingresa el nombre en los idiomas soportados",
                                child: Column(
                                  children: [
                                    _buildLangInput("ES", "Nombre en Español",
                                        "Ej: Taller", _nameEsController, true),
                                    const SizedBox(height: 16),
                                    _buildLangInput("EN", "Nombre en Inglés",
                                        "Ex: Workshop", _nameEnController, false),
                                    const SizedBox(height: 16),
                                    _buildLangInput("PT", "Nombre en Portugués",
                                        "Ex: Oficina", _namePtController, false),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              _buildStepCard(
                                icon: Icons.color_lens,
                                title: "Paso 2: Colores",
                                subtitle:
                                    "Selecciona colores para el texto y el fondo",
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildColorCircleOnly(
                                        label: "Color del Texto",
                                        currentColor: textColor,
                                        onTap: () => _openColorPicker(
                                          context,
                                          textColor,
                                          (c) => setState(() => textColor = c),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    Expanded(
                                      child: _buildColorCircleOnly(
                                        label: "Color del Fondo",
                                        currentColor: backgroundColor,
                                        onTap: () => _openColorPicker(
                                          context,
                                          backgroundColor,
                                          (c) =>
                                              setState(() => backgroundColor = c),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 24),

                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.remove_red_eye, color: mainColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Vista Previa",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: mainColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 40, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        _nameEsController.text.isEmpty
                                            ? "Nombre de la actividad"
                                            : _nameEsController.text,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Center(
                                  child: Text(
                                    "Así se verá la actividad en la app",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Botones alineados a la derecha, como en CategoryForm
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        context.read<ActivityBloc>().add(LoadActivities());
                        context.pop();
                      },
                      child: const Text("Cancelar"),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_createActivityFormKey.currentState!.validate()) {
                          // 🛠️ Cambio: usamos el id existente en modo edición para que el flujo de actualización funcione correctamente.
                          final String activityId =
                              activity?.id ?? _nameEsController.text.trim().toLowerCase();
                          final newActivity = Activity(
                            id: activityId,
                            nombre: {
                              'es': _nameEsController.text.trim(),
                              'en': _nameEnController.text.trim(),
                              'pt': _namePtController.text.trim(),
                            },
                            textColor: _toHex(textColor),
                            backgroundColor: _toHex(backgroundColor),
                          );

                          if (activity == null) {
                            context
                                .read<ActivityBloc>()
                                .add(AddActivity(newActivity));
                          } else {
                            context
                                .read<ActivityBloc>()
                                .add(UpdateActivity(newActivity));
                          }
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        activity == null ? "Crear Actividad" : "Actualizar",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Helpers ----------

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: mainColor, width: 4)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: mainColor),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLangInput(String tag, String label, String hint,
      TextEditingController controller, bool required) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: mainColor,
          child: Text(tag,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            // Validamos texto y evitamos palabras ofensivas incluso en campos opcionales.
            validator: (value) =>
                InputValidators.validateTextField(
              value,
              emptyMessage: "Campo obligatorio",
              isRequired: required,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorCircleOnly({
    required String label,
    required Color currentColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: currentColor,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openColorPicker(
    BuildContext context,
    Color initial,
    ValueChanged<Color> onConfirmed,
  ) {
    Color tempColor = initial;
    int selectedTab = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: mainColor.withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.color_lens, color: mainColor),
                  const SizedBox(width: 8),
                  Text(
                    "Selecciona un color",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Rápido"),
                        selected: selectedTab == 0,
                        onSelected: (_) => setState(() => selectedTab = 0),
                        selectedColor: mainColor.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text("Avanzado"),
                        selected: selectedTab == 1,
                        onSelected: (_) => setState(() => selectedTab = 1),
                        selectedColor: mainColor.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (selectedTab == 0)
                    BlockPicker(
                      pickerColor: tempColor,
                      onColorChanged: (c) => setState(() => tempColor = c),
                    )
                  else
                    ColorPicker(
                      pickerColor: tempColor,
                      onColorChanged: (c) => setState(() => tempColor = c),
                      portraitOnly: true,
                      enableAlpha: false,
                      displayThumbColor: true,
                      paletteType: PaletteType.hsvWithHue,
                      labelTypes: const [
                        ColorLabelType.hex,
                        ColorLabelType.rgb,
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                onPressed: () {
                  onConfirmed(tempColor);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Aceptar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color? _parseHex(String input) {
    try {
      if (input.isEmpty) return null;
      var hex = input.trim();
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 3) {
        hex = hex.split('').map((c) => '$c$c').join();
      }
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length != 8) return null;
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  String _toHex(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}
