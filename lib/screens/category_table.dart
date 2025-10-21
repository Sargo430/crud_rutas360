import 'package:crud_rutas360/blocs/category_bloc.dart';
import 'package:crud_rutas360/events/category_event.dart';
import 'package:crud_rutas360/states/category_state.dart';
import 'package:crud_rutas360/widgets/loading_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CategoryTable extends StatefulWidget {
  const CategoryTable({super.key});

  @override
  State<CategoryTable> createState() => _CategoryTableState();
}

class _CategoryTableState extends State<CategoryTable> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<CategoryBloc>();
    if (bloc.state is! CategoryLoaded && bloc.state is! CategoryLoading) {
      bloc.add(LoadCategories());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoaded) {
          const double rowHeight = 60.0;
          const double headerHeight = 52.0;
          final double tableHeight =
              headerHeight + (state.categories.length * rowHeight);

          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== HEADER =====
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Categorías",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF202124),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Gestiona las categorías que definen tu sistema",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.go('/categorias/create');
                              },
                              icon: const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 18),
                              label: const Text(
                                "Agregar categoría",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4D67AE),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                                shadowColor:
                                    const Color(0xFF4D67AE).withValues(alpha:0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: Colors.grey.withValues(alpha:0.2),
                        ),
                      ],
                    ),
                  ),

                  // ===== BARRA CONTEXTUAL =====
                  Container(
                    margin: const EdgeInsets.only(bottom: 28),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline,
                            color: Color(0xFF4D67AE), size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Aquí puedes crear, editar o eliminar categorías del sistema. "
                            "Asegúrate de definir correctamente los colores y nombres en los tres idiomas.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== TABLE CONTAINER =====
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: double.infinity,
                        height: tableHeight,
                        child: DataTableTheme(
                          data: DataTableThemeData(
                            headingRowHeight: headerHeight,
                            dataRowMinHeight: rowHeight,
                            dataRowMaxHeight: rowHeight,
                            headingRowColor: MaterialStateProperty.all(
                                const Color(0xFFF5F6F7)),
                            headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4D67AE),
                              fontSize: 14,
                            ),
                            dataTextStyle: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                          child: DataTable(
                            columnSpacing: 26,
                            horizontalMargin: 22,
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                width: 0.4,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            columns: const [
                              DataColumn(label: Text("ID")),
                              DataColumn(label: Text("Nombre (ES)")),
                              DataColumn(label: Text("Nombre (EN)")),
                              DataColumn(label: Text("Nombre (PT)")),
                              DataColumn(label: Text("Color texto")),
                              DataColumn(label: Text("Color fondo")),
                              DataColumn(label: Text("Acciones")),
                            ],
                            rows: List<DataRow>.generate(
                              state.categories.length,
                              (index) {
                                final category = state.categories[index];
                                final Color zebraColor = index.isEven
                                    ? Colors.white
                                    : const Color(0xFFF9FAFB);

                                return DataRow(
                                  color: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.hovered)) {
                                        return const Color(0xFF4D67AE)
                                            .withValues(alpha:0.08);
                                      }
                                      return zebraColor;
                                    },
                                  ),
                                  cells: [
                                    DataCell(Text(category.id)),
                                    DataCell(
                                        Text(category.nombre['es'] ?? '')),
                                    DataCell(
                                        Text(category.nombre['en'] ?? '')),
                                    DataCell(
                                        Text(category.nombre['pt'] ?? '')),
                                    DataCell(Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: getColorFromHex(
                                              category.textColor),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          category.textColor,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontFamily: 'monospace',
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    )),
                                    DataCell(Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: getColorFromHex(
                                              category.backgroundColor),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          category.backgroundColor,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontFamily: 'monospace',
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    )),
                                    DataCell(Row(
                                      children: [
                                        _ActionIcon(
                                          icon: Icons.edit_outlined,
                                          color: const Color(0xFF4D67AE),
                                          tooltip: "Editar",
                                          onTap: () {
                                            context.go(
                                              '/categorias/edit/${category.id}',
                                              extra: category,
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        _ActionIcon(
                                          icon: Icons.delete_outline,
                                          color: Colors.redAccent,
                                          tooltip: "Eliminar",
                                          onTap: () {
                                            fnDeleteCategory(
                                                category.id, context);
                                          },
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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

  void fnDeleteCategory(String id, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text(
          "Eliminar categoría",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "¿Seguro que deseas eliminar esta categoría?",
          style: TextStyle(fontSize: 14),
        ),
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
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Color getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) hexColor = "FF$hexColor";
      if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
      return Colors.transparent;
    } catch (_) {
      return Colors.transparent;
    }
  }
}

/// Íconos de acción con animación hover elegante
class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: hovered
                  ? widget.color.withValues(alpha:0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(widget.icon, size: 20, color: widget.color),
          ),
        ),
      ),
    );
  }
}
