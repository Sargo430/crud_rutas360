import 'package:crud_rutas360/blocs/activity_bloc.dart';
import 'package:crud_rutas360/events/activity_event.dart';
import 'package:crud_rutas360/states/activity_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crud_rutas360/widgets/loading_message.dart';

class ActivityTable extends StatefulWidget {
  const ActivityTable({super.key});

  @override
  State<ActivityTable> createState() => _ActivityTableState();
}

class _ActivityTableState extends State<ActivityTable> {
  @override
  void initState() {
    BlocProvider.of<ActivityBloc>(context).add(LoadActivities());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityBloc, ActivityState>(
      listener: (context, state) {
        if (state is ActivityLoadedWithSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green), 
          );
        } else if (state is ActivityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red), 
          );
        }
      },
      builder: (context, state) {
        if (state is ActivityLoaded) {
          const double rowHeight = 56.0;
          const double headerHeight = 50.0;
          final double tableHeight =
              headerHeight + (state.activities.length * rowHeight);

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
                          "Actividades",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Gestiona las actividades del sistema",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/actividades/create');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Agregar Actividad",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D67AE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tabla de actividades
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
                        rows: state.activities.map((activity) {
                          return DataRow(
                            cells: [
                              DataCell(Text(activity.id)),
                              DataCell(Text(activity.nombre['es'] ?? '')),
                              DataCell(Text(activity.nombre['en'] ?? '')),
                              DataCell(Text(activity.nombre['pt'] ?? '')),

                              // 🎨 Color del texto
                              DataCell(Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor:
                                        getColorFromHex(activity.textColor),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(activity.textColor),
                                ],
                              )),

                              // 🎨 Color del fondo
                              DataCell(Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor:
                                        getColorFromHex(activity.backgroundColor),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(activity.backgroundColor),
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
                                        '/actividades/edit/${activity.id}',
                                        extra: activity,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    tooltip: "Eliminar",
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      fnDeleteActivity(activity.id, context);
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

  void fnDeleteActivity(String id, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Confirmar eliminación"),
        content:
            const Text("¿Estás seguro de que deseas eliminar esta actividad?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<ActivityBloc>(context).add(DeleteActivity(id));
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
