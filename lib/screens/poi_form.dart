import 'package:crud_rutas360/blocs/poi_bloc.dart';
import 'package:crud_rutas360/events/poi_events.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/screens/poi_widget.dart';
import 'package:crud_rutas360/services/input_validators.dart';
import 'package:crud_rutas360/states/poi_state.dart';
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

class _PoiFormState extends State<PoiForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Color mainColor = const Color(0xFF4D67AE);

  // Controladores de texto
  final _name = TextEditingController();
  final _descEs = TextEditingController();
  final _descEn = TextEditingController();
  final _descPt = TextEditingController();
  final _lat = TextEditingController();
  final _long = TextEditingController();

  // MultiSelect controllers
  final _categoryCtrl = MultiSelectController<PoiCategory>();
  final _activityCtrl = MultiSelectController<Activity>();

  // Archivos
  PlatformFile? _img;
  PlatformFile? _winter;
  PlatformFile? _spring;
  PlatformFile? _summer;
  PlatformFile? _autumn;

  // Ruta
  String _route = 'sin_asignar';

  // Tabs
  late TabController _tabController;
  bool _initialized = false;

  // Límite de tamaño de imagen
  static const int _maxImageBytes = 10 * 1024 * 1024; // 10 MB

  // Estados de validación visual por pestaña
  bool _errorDatos = false;
  bool _errorMultimedia = false;
  bool _errorAsignaciones = false; // se mantiene para UI, pero no se marcará en rojo

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Listeners para refrescar preview en tiempo real
    for (final c in [_name, _descEs, _descEn, _descPt, _lat, _long]) {
      c.addListener(() {
        if (_errorDatos) setState(() {}); else setState(() {});
      });
    }
    _categoryCtrl.addListener(() => setState(() {}));
    _activityCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_name, _descEs, _descEn, _descPt, _lat, _long]) {
      c.dispose();
    }
    _categoryCtrl.dispose();
    _activityCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: BlocConsumer<PoiBloc, PoiState>(
        listener: (context, state) {
          if (state is PoiOperationSuccess || state is PoiLoadedWithSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text((state as dynamic).message),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/pois');
          }
        },
        builder: (context, state) {
          if (state is PoiFormState) {
            final poi = state.poi;
            if (!_initialized && poi != null) _loadPoi(poi);
            return _buildLayout(context, state, poi);
          }
          return const LoadingMessage();
        },
      ),
    );
  }

  void _loadPoi(POI poi) {
    _name.text = poi.nombre;
    _descEs.text = poi.descripcion['es'] ?? '';
    _descEn.text = poi.descripcion['en'] ?? '';
    _descPt.text = poi.descripcion['pt'] ?? '';
    _lat.text = poi.latitud.toString();
    _long.text = poi.longitud.toString();
    _route = poi.routeId ?? 'sin_asignar';
    _initialized = true;
  }

  Widget _buildLayout(BuildContext context, PoiFormState state, POI? poi) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        // FORM IZQUIERDO
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crear Punto de Interés',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                _buildTabBar(),
                const SizedBox(height: 24),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _tabDatos(context),
                        _tabMultimedia(context, poi),
                        _tabAsignaciones(context, state, poi),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // PREVIEW DERECHO
        Container(
          width: 420,
          height: size.height,
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(child: _preview(poi)),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: mainColor,
      unselectedLabelColor: Colors.black45,
      indicatorColor: mainColor,
      tabs: [
        Tab(
          icon: Icon(
            Icons.info_outline,
            color: _errorDatos ? Colors.red : mainColor,
          ),
          text: _errorDatos ? 'Datos ⚠️' : 'Datos',
        ),
        Tab(
          icon: Icon(
            Icons.photo_library_outlined,
            color: _errorMultimedia ? Colors.red : mainColor,
          ),
          text: _errorMultimedia ? 'Multimedia ⚠️' : 'Multimedia',
        ),
        Tab(
          icon: Icon(
            Icons.link,
            color: _errorAsignaciones ? Colors.red : mainColor,
          ),
          // Asignaciones NO tiene obligatorios; mantenemos texto normal
          text: 'Asignaciones',
        ),
      ],
    );
  }

  // ======================= TAB 1: DATOS =======================
  Widget _tabDatos(BuildContext context) {
    return ListView(
      children: [
        _section(
          "Datos Generales",
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Nombre del Punto de Interés',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                InputValidators.validateTextField(v, emptyMessage: 'Campo requerido'),
          ),
        ),
        const SizedBox(height: 24),
        _section("Descripciones del Punto de Interés", _buildDescripcionFields()),
        const SizedBox(height: 24),
        _section(
          "Ubicación",
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _lat,
                  decoration: const InputDecoration(
                    labelText: 'Latitud',
                    border: OutlineInputBorder(),
                  ),
                  validator: InputValidators.validateLatitude,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _long,
                  decoration: const InputDecoration(
                    labelText: 'Longitud',
                    border: OutlineInputBorder(),
                  ),
                  validator: InputValidators.validateLongitude,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _formButtons(
          onNext: () {
            if (_formKey.currentState!.validate()) {
              setState(() => _errorDatos = false);
              _tabController.animateTo(1);
            } else {
              setState(() => _errorDatos = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor completa los campos obligatorios.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onCancel: _handleCancel,
        ),
      ],
    );
  }

  // Descripciones con icono de idioma
  Widget _buildDescripcionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _langField("ES", "Descripción en Español", _descEs, true),
        const SizedBox(height: 12),
        _langField("EN", "Descripción en Inglés", _descEn, false),
        const SizedBox(height: 12),
        _langField("PT", "Descripción en Portugués", _descPt, false),
      ],
    );
  }

  Widget _langField(
    String code,
    String label,
    TextEditingController controller,
    bool required,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 12, top: 8),
          decoration: BoxDecoration(color: mainColor, shape: BoxShape.circle),
          child: Text(
            code,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ).copyWith(labelText: label),
            validator: (v) => InputValidators.validateDescriptionField(
              v,
              isRequired: required,
              emptyMessage: "Campo obligatorio",
            ),
          ),
        ),
      ],
    );
  }

  // ======================= TAB 2: MULTIMEDIA =======================
  Widget _tabMultimedia(BuildContext context, POI? poi) {
    return ListView(
      children: [
        _section(
          "Imagen Principal",
          _imagePicker(
            "Seleccionar imagen",
            (f) => setState(() => _img = f),
            _img,
          ),
        ),
        const SizedBox(height: 16),
        _section(
          "Vistas 360°",
          Column(
            children: [
              _season("Invierno ❄️", _winter, (f) => setState(() => _winter = f)),
              _season("Primavera 🌸", _spring, (f) => setState(() => _spring = f)),
              _season("Verano ☀️", _summer, (f) => setState(() => _summer = f)),
              _season("Otoño 🍂", _autumn, (f) => setState(() => _autumn = f)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _formButtons(
          onNext: () {
            // Imagen principal obligatoria SOLO en creación
            if (poi == null && _img == null) {
              setState(() => _errorMultimedia = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('La imagen principal es obligatoria (máx. 10 MB).'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            setState(() => _errorMultimedia = false);
            _tabController.animateTo(2);
          },
          onCancel: _handleCancel,
        ),
      ],
    );
  }

  // ======================= TAB 3: ASIGNACIONES =======================
  Widget _tabAsignaciones(BuildContext context, PoiFormState state, POI? poi) {
    return ListView(
      children: [
        _section(
          "Categorías",
          MultiDropdown(
            items: state.categories
                .map((e) => DropdownItem(label: e.nombre['es'], value: e))
                .toList(),
            controller: _categoryCtrl,
            fieldDecoration: const FieldDecoration(
              labelText: "Selecciona categorías",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _section(
          "Actividades",
          MultiDropdown(
            items: state.activities
                .map((e) => DropdownItem(label: e.nombre['es'], value: e))
                .toList(),
            controller: _activityCtrl,
            fieldDecoration: const FieldDecoration(
              labelText: "Selecciona actividades",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _section(
          "Ruta Asociada",
          DropdownMenu<String>(
            expandedInsets: EdgeInsets.zero,
            initialSelection: 'sin_asignar',
            dropdownMenuEntries: state.routes
                .map((r) => DropdownMenuEntry(value: r.id, label: r.name))
                .toList(),
            onSelected: (v) => setState(() => _route = v ?? 'sin_asignar'),
          ),
        ),
        const SizedBox(height: 32),
        _formButtons(
          primaryText: poi == null ? "Crear POI" : "Actualizar POI",
          onNext: () {
            final valid = _validateTabs(poi);
            if (valid) {
              _submit(poi); // Mantiene la lógica original
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor completa los campos obligatorios antes de continuar.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onCancel: _handleCancel,
        ),
      ],
    );
  }

  // ======================= VALIDACIÓN GLOBAL POR TABS =======================
  bool _validateTabs(POI? poi) {
    final datosValid = _formKey.currentState!.validate();
    final multimediaValid = poi != null || _img != null; // si es edición, se permite null

    setState(() {
      _errorDatos = !datosValid;
      _errorMultimedia = !multimediaValid;
      _errorAsignaciones = false; // NO hay requeridos en Asignaciones
    });

    return datosValid && multimediaValid;
  }

  // ======================= SECCIÓN GENÉRICA =======================
  Widget _section(String title, Widget child) => Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4FB),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: mainColor, width: 4)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );

  // ======================= PICKERS Y HELPERS =======================
  Future<PlatformFile?> _pickImageWithValidation(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null) return null;

      final file = result.files.first;

      // Si tienes tu propio validador, puedes reemplazar esta línea por:
      // if (InputValidators.isFileTooLarge(file)) { ... }
      if (file.size > _maxImageBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La imagen supera el tamaño máximo permitido (10 MB).'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
      return file;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Widget _imagePicker(
    String label,
    void Function(PlatformFile?) onPick,
    PlatformFile? file,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () async {
            final selected = await _pickImageWithValidation(context);
            if (selected != null) onPick(selected);
            setState(() {}); // refresca preview
          },
          child: Text(label),
        ),
        const SizedBox(height: 8),
        Text(file != null ? "Seleccionada: ${file.name}" : "No se ha seleccionado imagen"),
      ],
    );
  }

  Widget _season(
    String title,
    PlatformFile? file,
    void Function(PlatformFile?) onPick,
  ) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: mainColor),
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: mainColor.withOpacity(0.3)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: mainColor.withOpacity(0.3)),
        ),
        textColor: mainColor,
        iconColor: mainColor,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          const SizedBox(height: 8),
          _imagePicker("Seleccionar imagen", (f) => onPick(f), file),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ======================= BOTONES REUTILIZABLES =======================
  Widget _formButtons({
    required VoidCallback onNext,
    required VoidCallback onCancel,
    String primaryText = "Siguiente",
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionButton("Cancelar", onCancel, Colors.grey[300]!, Colors.black),
          const SizedBox(width: 12),
          _actionButton(primaryText, onNext, mainColor, Colors.white),
        ],
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onPressed, Color bg, Color fg) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180, minHeight: 45),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  // ======================= PREVIEW =======================
  Widget _preview(POI? poi) {
    return Column(
      children: [
        const Text(
          "Vista previa del POI",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 9 / 16,
          child: PoiScreen(
            _name.text.isNotEmpty ? _name.text : "Ingresa el nombre del POI",
            _img,
            {'es': _descEs.text, 'en': _descEn.text, 'pt': _descPt.text},
            _categoryCtrl.selectedItems.map((i) => i.value).toList(),
            _activityCtrl.selectedItems.map((i) => i.value).toList(),
            {
              'Invierno': _winter,
              'Primavera': _spring,
              'Verano': _summer,
              'Otoño': _autumn,
            },
            imageUrl: poi?.imagen,
            existingVistas360: poi?.vistas360,
          ),
        ),
      ],
    );
  }

  void _handleCancel() {
    // Reload list before leaving so the table regains its data state.
    context.read<PoiBloc>().add(LoadPOIs());
    context.go('/pois');
  }

  // ======================= SUBMIT (MISMA LÓGICA) =======================
  void _submit(POI? poi) {
    final newPoi = POI(
      routeId: _route,
      id: poi?.id ?? '',
      nombre: _name.text,
      descripcion: {'es': _descEs.text, 'en': _descEn.text, 'pt': _descPt.text},
      latitud: double.parse(_lat.text.replaceAll(',', '.')),
      longitud: double.parse(_long.text.replaceAll(',', '.')),
      categorias: _categoryCtrl.selectedItems.map((i) => i.value).toList(),
      actividades: _activityCtrl.selectedItems.map((i) => i.value).toList(),
      imagen: poi?.imagen ?? '',
      vistas360: {},
    );

    if (poi != null) {
      context.read<PoiBloc>().add(
        UpdatePOI(
          newPoi,
          image: _img,
          new360Views: {
            'Invierno': _winter,
            'Primavera': _spring,
            'Verano': _summer,
            'Otoño': _autumn,
          },
        ),
      );
    } else {
      context.read<PoiBloc>().add(
        AddPOI(
          newPoi,
          _img!,
          {
            'Invierno': _winter,
            'Primavera': _spring,
            'Verano': _summer,
            'Otoño': _autumn,
          },
        ),
      );
    }
  }
}
