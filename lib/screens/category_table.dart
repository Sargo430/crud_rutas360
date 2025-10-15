import 'package:crud_rutas360/blocs/category_bloc.dart';
import 'package:crud_rutas360/events/category_event.dart';
import 'package:crud_rutas360/states/category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crud_rutas360/widgets/loading_message.dart';

class CategoryTable extends StatefulWidget {
  const CategoryTable({super.key});

  @override
  State<CategoryTable> createState() => _CategoryTableState();
}

class _CategoryTableState extends State<CategoryTable> {
  @override
  void initState() {
    BlocProvider.of<CategoryBloc>(context).add(LoadCategories());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoaded) {
          const double rowHeight = 56.0;
          const double headerHeight = 50.0;
          final double tableHeight =
              headerHeight + (state.categories.length * rowHeight);

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Categorías",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Gestiona las categorías del sistema",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/categorias/create');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Agregar Categoría",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D67AE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Tabla de categorías
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: SizedBox(
                    width: double.infinity,
                    height: tableHeight,
                    child: DataTableTheme(
                      data: DataTableThemeData(
                        headingRowHeight: headerHeight,
                        dataRowMinHeight: rowHeight,
                        dataRowMaxHeight: rowHeight,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF3F4F6),
                        ),
                      ),
                      child: DataTable(
                        columnSpacing: 24,
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            width: 0.3,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        columns: const [
                          DataColumn(label: Text("ID")),
                          DataColumn(label: Text("Nombre (ES)")),
                          DataColumn(label: Text("Nombre (EN)")),
                          DataColumn(label: Text("Nombre (PT)")),
                          DataColumn(label: Text("Color del Texto")),
                          DataColumn(label: Text("Color de Fondo")),
                          DataColumn(label: Text("Acciones")),
                        ],
                        rows: state.categories.map((category) {
                          return DataRow(
                            cells: [
                              DataCell(Text(category.id)),
                              DataCell(Text(category.nombre['es'] ?? '')),
                              DataCell(Text(category.nombre['en'] ?? '')),
                              DataCell(Text(category.nombre['pt'] ?? '')),

                              // 🎨 Color del texto
                              DataCell(Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        getColorFromHex(category.textColor),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(category.textColor,
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              )),

                              // 🎨 Color del fondo
                              DataCell(Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        getColorFromHex(category.backgroundColor),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(category.backgroundColor,
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              )),

                              // Acciones
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    tooltip: "Editar",
                                    icon: const Icon(Icons.edit,
                                        color: Color(0xFF4D67AE)),
                                    onPressed: () {
                                      context.go(
                                        '/categorias/edit/${category.id}',
                                        extra: category,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    tooltip: "Eliminar",
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      fnDeleteCategory(category.id, context);
                                    },
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const LoadingMessage();
        }
      },
    );
  }

  void fnDeleteCategory(String id, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Confirmar eliminación"),
        content:
            const Text("¿Estás seguro de que deseas eliminar esta categoría?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<CategoryBloc>(context).add(DeleteCategory(id));
              Navigator.of(context).pop();
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
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
}

