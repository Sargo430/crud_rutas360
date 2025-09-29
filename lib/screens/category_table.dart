import 'package:crud_rutas360/blocs/category_bloc.dart';
import 'package:crud_rutas360/events/category_event.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/states/category_state.dart';
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
    BlocProvider.of<CategoryBloc>(context).add(LoadCategories());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoaded) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Categorías',
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/categorias/create');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Agregar Categoría',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D67AE),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: CategoryDataTable(categories: state.categories),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class CategorySource extends DataTableSource {
  final List categories;
  final BuildContext context;
  CategorySource(this.categories, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= categories.length) return null;
    final category = categories[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(category.id)),
        DataCell(Text(category.nombre['es'])),
        DataCell(Text(category.nombre['en'])),
        DataCell(Text(category.nombre['pt'])),
        DataCell(
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: getColorFromHex(category.backgroundColor),
                  border: Border.all(color: Colors.black26, width: 1),
                ),
              ),
              SizedBox(width: 8),
              Text(category.textColor),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: getColorFromHex(category.backgroundColor),
                  border: Border.all(color: Colors.black26, width: 1),
                ),
              ),
              SizedBox(width: 8),
              Text(category.backgroundColor),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navegar a la pantalla de edición con la categoría como argumento
                  context.go('/categorias/edit', extra: category);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Manejar la eliminación de la categoría
                  fnDeleteCategory(category.id, context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => categories.length;

  @override
  int get selectedRowCount => 0;

  void fnDeleteCategory(id, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta categoría?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<CategoryBloc>(context).add(DeleteCategory(id));
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor"; // agrega alpha si falta
      }
      if (hexColor.length == 8) {
        return Color(int.parse("0x$hexColor", radix: 16));
      }
      // fallback for invalid length
      return Colors.transparent;
    } catch (e) {
      return Colors.transparent;
    }
  }
}

class CategoryDataTable extends StatelessWidget {
  final List<PoiCategory> categories;
  const CategoryDataTable({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: PaginatedDataTable(
        rowsPerPage: 10,
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('es')),
          DataColumn(label: Text('en')),
          DataColumn(label: Text('pt')),
          DataColumn(label: Text('Color del texto')),
          DataColumn(label: Text('Color de fondo')),
          DataColumn(label: Text('Acciones')),
        ],
        source: CategorySource(categories, context),
      ),
    );
  }
}
