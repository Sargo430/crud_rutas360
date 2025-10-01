
import 'package:crud_rutas360/blocs/activity_bloc.dart';
import 'package:crud_rutas360/events/activity_event.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/states/activity_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state is ActivityLoaded) {
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
                      'Actividades',
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/actividades/create');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Agregar Actividad',
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
                  child: ActivityDataTable(activities: state.activities),
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

class ActivitySource extends DataTableSource {
  final List activities;
  final BuildContext context;
  ActivitySource(this.activities, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= activities.length) return null;
    final activity = activities[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(activity.id)),
        DataCell(Text(activity.nombre['es'])),
        DataCell(Text(activity.nombre['en'])),
        DataCell(Text(activity.nombre['pt'])),
        DataCell(
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: getColorFromHex(activity.textColor),
                  border: Border.all(color: Colors.black26, width: 1),
                ),
              ),
              SizedBox(width: 8),
              Text(activity.textColor),
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
                  color: getColorFromHex(activity.backgroundColor),
                  border: Border.all(color: Colors.black26, width: 1),
                ),
              ),
              SizedBox(width: 8),
              Text(activity.backgroundColor),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navegar a la pantalla de edición con la actividad como argumento
                  context.go('/actividades/edit/${activity.id}', extra: activity);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Manejar la eliminación de la actividad
                  fnDeleteActivity(activity.id, context);
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
  int get rowCount => activities.length;

  @override
  int get selectedRowCount => 0;

  void fnDeleteActivity(id, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta actividad?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<ActivityBloc>(context).add(DeleteActivity(id));
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

class ActivityDataTable extends StatelessWidget {
  final List<Activity> activities;
  const ActivityDataTable({super.key, required this.activities});

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
        source: ActivitySource(activities, context),
      ),
    );
  }
}
