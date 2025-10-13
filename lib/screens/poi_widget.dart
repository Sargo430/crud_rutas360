import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class PoiScreen extends StatefulWidget {
  final String name;
  final PlatformFile? _pickedImage;
  final String? imageUrl;
  final Map<String, String> description;
  final List<PoiCategory> selectedCategories;
  final List<Activity> selectedActivities;
  final Map<String, PlatformFile?> vistas360;
  final Map<String, dynamic>? existingVistas360; // URLs from existing POI
  const PoiScreen(
    this.name,
    this._pickedImage,
    this.description,
    this.selectedCategories,
    this.selectedActivities,
    this.vistas360, {
    super.key,
    this.imageUrl,
    this.existingVistas360,
  });

  @override
  State<PoiScreen> createState() => _PoiScreenState();
}

class _PoiScreenState extends State<PoiScreen> {
  String selectedLanguage = 'es';
  Color colbunBlue = const Color(0xFF4D67AE);
  String? valorSeleccionado = 'Otoño';
  final List<String> opciones = ['Otoño', 'Invierno', 'Primavera', 'Verano'];

  // Overlay (info)
  OverlayEntry? _overlayEntry;
  final GlobalKey _iconKey = GlobalKey();

  void _showOverlay() {
    // remove any existing
    _overlayEntry?.remove();
    _overlayEntry = null;

    final renderBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;

    // Compute left but clamp to screen edges
    double left = offset.dx - 110; // center-ish to the left of the icon
    if (left < 8) left = 8;
    if (left + 220 > screenWidth - 8) {
      left = screenWidth - 8 - 220;
      if (left < 8) left = 8;
    }

    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: left,
        top: offset.dy + size.height + 8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: const Text(
              'Incluye vistas modificadas con IA',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== TITULO + BOTON X ====================
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ==================== IMAGEN PRINCIPAL ====================
                const SizedBox(height: 8),
                // Main image: prefer picked image bytes; fallback to network URL; else placeholder
                Builder(builder: (context) {
                  final hasPicked = widget._pickedImage?.bytes != null;
                  final hasUrl = (widget.imageUrl != null && widget.imageUrl!.isNotEmpty);
                  if (hasPicked) {
                    return Image.memory(
                      widget._pickedImage!.bytes!,
                      width: 393,
                      height: 221,
                      fit: BoxFit.cover,
                    );
                  } else if (hasUrl) {
                    return Image.network(
                      widget.imageUrl!,
                      width: 393,
                      height: 221,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 393,
                          height: 221,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    );
                  } else {
                    return Container(
                      width: 393,
                      height: 221,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                    );
                  }
                }),

                // ==================== Categorias y actividades ====================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Lista de chips horizontal
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: Builder(
                            builder: (context) {
                              final items = _fnGetItems();
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: items.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  return ActionChip(
                                    label: Text(
                                      items[index]['nombre'][selectedLanguage]
                                          .toString(),
                                      style: TextStyle(
                                        color:
                                            items[index]['text_color'] ??
                                            Colors.black,
                                      ),
                                    ),
                                    backgroundColor:
                                        items[index]['background_color'] ??
                                        Colors.grey.shade200,
                                    side: BorderSide.none,
                                    onPressed: () {},
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      // Icono de favorito
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.favorite, color: Colors.red),
                      ),
                    ],
                  ),
                ),

                // ==================== DROPDOWN + INFO + VISTA 360 + BOTON EMERGENCIA ====================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Dropdown with rounded black border
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.3),
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white,
                        ),
                        child: DropdownButton<String>(
                          value: valorSeleccionado,
                          underline: SizedBox(),
                          borderRadius: BorderRadius.circular(18),
                          items: opciones.map((String opcion) {
                            IconData icon;
                            Color iconColor;
                            switch (opcion) {
                              case 'Otoño':
                                icon = Icons.park;
                                iconColor = Colors.orange;
                                break;
                              case 'Invierno':
                                icon = Icons.ac_unit;
                                iconColor = Colors.lightBlue;
                                break;
                              case 'Primavera':
                                icon = Icons.eco_outlined;
                                iconColor = Colors.green;
                                break;
                              case 'Verano':
                                icon = Icons.wb_sunny;
                                iconColor = Colors.amber;
                                break;
                              default:
                                icon = Icons.circle;
                                iconColor = Colors.black54;
                            }
                            return DropdownMenuItem<String>(
                              value: opcion,
                              child: Row(
                                children: [
                                  Icon(icon, size: 20, color: iconColor),
                                  const SizedBox(width: 8),
                                  Text(opcion),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? nuevoValor) {
                            setState(() {
                              valorSeleccionado = nuevoValor;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Check for PlatformFile first (new uploads), then existing URLs
                          final platformFile = widget.vistas360[valorSeleccionado];
                          final existingUrl = widget.existingVistas360?[valorSeleccionado];
                          
                          if (platformFile != null) {
                            showPanoramaModal(context, platformFile, null);
                          } else if (existingUrl != null && existingUrl.toString().isNotEmpty) {
                            showPanoramaModal(context, null, existingUrl.toString());
                          } else {
                            showPanoramaModal(context, null, null);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colbunBlue,
                        ),
                        child: Text(
                          "Vista 360°",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        key: _iconKey,
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          if (_overlayEntry == null) {
                            _showOverlay();
                          } else {
                            _overlayEntry?.remove();
                            _overlayEntry = null;
                          }
                        },
                      ),
                      Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.red,
                        ),
                        label: const Icon(Icons.call, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    children: [
                      //=================Estacion actual========================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Temporada actual: Primavera \nClima templado, flora abundante, ideal para trekking",
                            style: TextStyle(fontSize: 16, color: colbunBlue),
                          ),
                        ),
                      ),
                      // ==================== DESCRIPCION ====================
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Descripción",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            FilledButton(
                              onPressed: () {
                                setState(() {
                                  selectedLanguage = 'es';
                                });
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: selectedLanguage == 'es'
                                    ? colbunBlue
                                    : Colors.grey.shade200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                ),
                              ),
                              child: Text(
                                "Es",
                                style: TextStyle(
                                  color: selectedLanguage == 'es'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            FilledButton(
                              onPressed: () {
                                setState(() {
                                  selectedLanguage = 'en';
                                });
                              },
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                backgroundColor: selectedLanguage == 'en'
                                    ? colbunBlue
                                    : Colors.grey.shade200,
                              ),
                              child: Text(
                                "En",
                                style: TextStyle(
                                  color: selectedLanguage == 'en'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            FilledButton(
                              onPressed: () {
                                setState(() {
                                  selectedLanguage = 'pt';
                                });
                              },
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                backgroundColor: selectedLanguage == 'pt'
                                    ? colbunBlue
                                    : Colors.grey.shade200,
                              ),
                              child: Text(
                                "Pt",
                                style: TextStyle(
                                  color: selectedLanguage == 'pt'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          widget.description[selectedLanguage] ??
                              'Ingresa una descripción',

                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      //Tabs Recomendados / Cerca de ti
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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

  List<Map<String, dynamic>> _fnGetItems() {
    List<Map<String, dynamic>> items = [];
    for (var category in widget.selectedCategories) {
      items.add({
        'nombre': category.nombre,
        'background_color': getColorFromHex(category.backgroundColor),
        'text_color': getColorFromHex(category.textColor),
      });
    }
    for (var activity in widget.selectedActivities) {
      items.add({
        'nombre': activity.nombre,
        'background_color': getColorFromHex(activity.backgroundColor),
        'text_color': getColorFromHex(activity.textColor),
      });
    }
    return items;
  }


  Widget _build360Content(PlatformFile? imagePath, String? imageUrl) {
    // Priority: PlatformFile (new upload) > URL (existing) > placeholder
    if (imagePath != null && imagePath.bytes != null) {
      return PanoramaViewer(
        child: Image.memory(
          imagePath.bytes!,
          fit: BoxFit.cover,
        ),
      );
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      return PanoramaViewer(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.panorama,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay vista 360° disponible',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void showPanoramaModal(BuildContext context, PlatformFile? imagePath, String? imageUrl) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Space for header
                      const SizedBox(height: 70),
                      // Content
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: _build360Content(imagePath, imageUrl),
                        ),
                      ),
                    ],
                  ),
                ),
                // Header with close button (positioned on top)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colbunBlue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Vista 360°',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
}
