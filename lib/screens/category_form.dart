import 'package:crud_rutas360/blocs/category_bloc.dart';
import 'package:crud_rutas360/events/category_event.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/services/input_validators.dart';
import 'package:crud_rutas360/states/category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:crud_rutas360/widgets/loading_message.dart';

class CategoryForm extends StatefulWidget {
  const CategoryForm({super.key});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _createCategoryFormKey = GlobalKey<FormState>();

  final TextEditingController _nameEsController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _namePtController = TextEditingController();

  Color textColor = Colors.black;
  Color backgroundColor = Colors.grey;

  bool _initialized = false;
  PoiCategory? _lastCategory;

  final Color mainColor = const Color(0xFF4D67AE);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryOperationSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green)); // 🔧 agregado
        }
      },
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const LoadingMessage();
        }
        PoiCategory? category;
        if (state is CategoryFormState) {
          category = state.category;
          if (category != null && (!_initialized || category != _lastCategory)) {
            _nameEsController.text = category.nombre['es'] ?? '';
            _nameEnController.text = category.nombre['en'] ?? '';
            _namePtController.text = category.nombre['pt'] ?? '';

            // Cargar colores desde HEX almacenado
            textColor = _parseHex(category.textColor) ?? Colors.black;
            backgroundColor = _parseHex(category.backgroundColor) ?? Colors.grey;

            _initialized = true;
            _lastCategory = category;
          }
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título   
                Text(
                  category == null ? "Crear Categoría" : "Actualizar Categoria",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Define una nueva categoría con nombres multiidioma y personalización de colores",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // Fila principal
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 📌 Columna izquierda (formulario)
                      Expanded(
                        flex: 2,
                        child: Form(
                          key: _createCategoryFormKey,
                          child: Column(
                            children: [
                              _buildStepCard(
                                icon: Icons.category,
                                title: "Paso 1: Nombres de la Categoría",
                                subtitle:
                                    "Ingresa el nombre en los idiomas soportados",
                                child: Column(
                                  children: [
                                    _buildLangInput(
                                      "ES",
                                      "Nombre en Español",
                                      "Ej: Restaurantes",
                                      _nameEsController,
                                      true,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLangInput(
                                      "EN",
                                      "Nombre en Inglés",
                                      "Ex: Restaurants",
                                      _nameEnController,
                                      false,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLangInput(
                                      "PT",
                                      "Nombre en Portugués",
                                      "Ex: Restaurantes",
                                      _namePtController,
                                      false,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              //  Paso 2: dos columnas con círculos (sin textfields)
                              _buildStepCard(
                                icon: Icons.color_lens,
                                title: "Paso 2: Personalización de Colores",
                                subtitle:
                                    "Selecciona los colores para el texto y fondo de la categoría",
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
                                          (c) => setState(
                                              () => backgroundColor = c),
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

                      // 📌 Vista previa (encabezado arriba con ícono)
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
                                        vertical: 40,
                                        horizontal: 16,
                                      ),
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
                                            ? "Nombre de la categoría"
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
                                    "Así se verá la categoría en la app",
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

                // BOTONES
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        context.read<CategoryBloc>().add(LoadCategories());
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(120, 40),
                      ),
                      child: const Text("Cancelar"),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_createCategoryFormKey.currentState!.validate()) {
                          // 🛠️ Cambio: conservamos el id original cuando se edita para que el BLoC pueda actualizar la categoría existente.
                          final String categoryId =
                              category?.id ?? _nameEsController.text.trim().toLowerCase();
                          final newCategory = PoiCategory(
                            id: categoryId,
                            nombre: {
                              'es': _nameEsController.text.trim(),
                              'en': _nameEnController.text.trim(),
                              'pt': _namePtController.text.trim(),
                            },
                            textColor: _toHex(textColor),
                            backgroundColor: _toHex(backgroundColor),
                          );

                          if (category == null) {
                            context
                                .read<CategoryBloc>()
                                .add(AddCategory(newCategory));
                          } else {
                            context
                                .read<CategoryBloc>()
                                .add(UpdateCategory(newCategory));
                          }
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        minimumSize: const Size(160, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        category == null ? "Crear Categoría" : "Actualizar",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Helpers UI ----------

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: mainColor, width: 4)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: mainColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLangInput(
    String tag,
    String label,
    String hint,
    TextEditingController controller,
    bool required,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: mainColor,
          child: Text(
            tag,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
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
            // Validamos el texto y evitamos palabras ofensivas en cada idioma.
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

  // Columna de color SOLO con label + círculo
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

  /// 🎨 Modal avanzado con pestañas (Rápido / Avanzado)
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
                  // Chips Tabs
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

                  // Contenido del Picker
                  if (selectedTab == 0)
                    BlockPicker(
                      pickerColor: tempColor,
                      onColorChanged: (c) => setState(() => tempColor = c),
                      availableColors: const [
                        // corporativo
                        Color(0xFF4D67AE),
                        // clásicos
                        Colors.black,
                        Colors.white,
                        Colors.red,
                        Colors.green,
                        Colors.blue,
                        Colors.orange,
                        Colors.purple,
                        Colors.teal,
                        Colors.pink,
                        Colors.yellow,
                        Colors.grey,
                        Colors.brown,
                        // extras
                        Colors.cyan,
                        Colors.indigo,
                        Colors.lime,
                        Colors.amber,
                        Colors.deepOrange,
                        Colors.deepPurple,
                        Colors.lightBlue,
                        Colors.lightGreen,
                        Colors.blueGrey,
                        Colors.pinkAccent,
                        Colors.deepPurpleAccent,
                      ],
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

  // ---------- Utilidades de color ----------

  // Acepta "#RRGGBB" o "#AARRGGBB" (con o sin '#')
  Color? _parseHex(String input) {
    try {
      if (input.isEmpty) return null;
      var hex = input.trim();
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 3) {
        hex = hex.split('').map((c) => '$c$c').join(); // #ABC -> #AABBCC
      }
      if (hex.length == 6) hex = 'FF$hex'; // sin alpha -> alpha FF
      if (hex.length != 8) return null;
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  // Retorna "#RRGGBB" (descarta alpha)
  String _toHex(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}
