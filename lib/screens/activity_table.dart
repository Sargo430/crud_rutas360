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
    super.initState();
    final bloc = context.read<ActivityBloc>();
    if (bloc.state is! ActivityLoaded && bloc.state is! ActivityLoading) {
      bloc.add(LoadActivities());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityBloc, ActivityState>(
      listener: (context, state) {
        if (state is ActivityLoadedWithSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ActivityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ActivityLoaded) {
          const double rowHeight = 60.0;
          const double headerHeight = 52.0;
          final double tableHeight =
              headerHeight + (state.activities.length * rowHeight);

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
                                  "Actividades",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF202124),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Gestiona las actividades del sistema",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.go('/actividades/create');
                              },
                              icon: const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 18),
                              label: const Text(
                                "Agregar actividad",
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
                            "Aquí puedes crear, editar o eliminar actividades del sistema. "
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

                  // ===== TABLA DE ACTIVIDADES =====
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
                            headingRowColor: WidgetStateProperty.all(
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
                              state.activities.length,
                              (index) {
                                final activity = state.activities[index];
                                final Color zebraColor = index.isEven
                                    ? Colors.white
                                    : const Color(0xFFF9FAFB);

                                return DataRow(
                                  color: WidgetStateProperty.resolveWith<
                                      Color?>((Set<WidgetState> states) {
                                    if (states
                                        .contains(WidgetState.hovered)) {
                                      return const Color(0xFF4D67AE)
                                          .withValues(alpha:0.08);
                                    }
                                    return zebraColor;
                                  }),
                                  cells: [
                                    DataCell(Text(activity.id)),
                                    DataCell(Text(activity.nombre['es'] ?? '')),
                                    DataCell(Text(activity.nombre['en'] ?? '')),
                                    DataCell(Text(activity.nombre['pt'] ?? '')),
                                    DataCell(Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: getColorFromHex(
                                              activity.textColor),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          activity.textColor,
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
                                              activity.backgroundColor),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          activity.backgroundColor,
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
                                        IconButton(
                                          tooltip: "Editar",
                                          icon: const Icon(Icons.edit_outlined,
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
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.redAccent),
                                          onPressed: () {
                                            fnDeleteActivity(
                                                activity.id, context);
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

  void fnDeleteActivity(String id, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text(
          "Eliminar actividad",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "¿Seguro que deseas eliminar esta actividad?",
          style: TextStyle(fontSize: 14),
        ),
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
