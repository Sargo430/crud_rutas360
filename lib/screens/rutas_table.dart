import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/route_event.dart';
import 'package:crud_rutas360/models/route_model.dart';
import 'package:crud_rutas360/states/route_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crud_rutas360/widgets/loading_message.dart';

// 👇 Importa el bloc/estado de POI para escuchar éxitos y refrescar rutas
import 'package:crud_rutas360/blocs/poi_bloc.dart';
import 'package:crud_rutas360/states/poi_state.dart';

class TablaRutas extends StatefulWidget {
  const TablaRutas({super.key});

  @override
  State<TablaRutas> createState() => _TablaRutasState();
}

class _TablaRutasState extends State<TablaRutas> {
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<RouteBloc>();
    if (bloc.state is! RouteLoaded && bloc.state is! RouteLoading) {
      bloc.add(LoadRoute());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<RouteBloc>().add(LoadRoute());
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PoiBloc, PoiState>(
          listener: (context, state) {
            if (state is PoiLoadedWithSuccess || state is PoiOperationSuccess) {
              context.read<RouteBloc>().add(LoadRoute());
            }
          },
        ),
      ],
      child: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          if (state is RouteLoaded) {
            const double rowHeight = 60.0;
            const double headerHeight = 52.0;

            return Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 30.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======= HEADER =======
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
                                    "Rutas",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF202124),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Gestiona las rutas registradas en el sistema",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.go('/rutas/create');
                                },
                                icon: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text(
                                  "Crear ruta",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4D67AE),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                  shadowColor: const Color(
                                    0xFF4D67AE,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                    ),

                    // ======= BARRA CONTEXTUAL =======
                    Container(
                      margin: const EdgeInsets.only(bottom: 28),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF4D67AE),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Aquí puedes crear, editar o eliminar rutas. "
                              "Cada ruta define coordenadas de inicio y fin, y puede asociar múltiples puntos de interés.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======= TABLA DE RUTAS =======
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Scrollbar(
                            controller: _verticalController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            radius: const Radius.circular(6),
                            thickness: 8,
                            child: SingleChildScrollView(
                              controller: _verticalController,
                              scrollDirection: Axis.vertical,
                              child: DataTableTheme(
                                data: DataTableThemeData(
                                  headingRowHeight: headerHeight,
                                  dataRowMinHeight: rowHeight,
                                  dataRowMaxHeight: rowHeight,
                                  headingRowColor: WidgetStateProperty.all(
                                    const Color(0xFFF5F6F7),
                                  ),
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
                                  columnSpacing: 24,
                                  horizontalMargin: 22,
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                      width: 0.4,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  columns: const [
                                    DataColumn(label: Text("Nombre")),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 80,
                                        child: Text(
                                          "Latitud\ninicio",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 90,
                                        child: Text(
                                          "Longitud\ninicio",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 80,
                                        child: Text(
                                          "Latitud\nfin",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 90,
                                        child: Text(
                                          "Longitud\nfin",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 220,
                                        child: Text(
                                          "Puntos de interés",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(label: Text("Acciones")),
                                  ],
                                  rows: List<DataRow>.generate(
                                    state.routes.length,
                                    (index) {
                                      final route = state.routes[index];
                                      final Color zebraColor = index.isEven
                                          ? Colors.white
                                          : const Color(0xFFF9FAFB);

                                      return DataRow(
                                        color:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((Set<WidgetState> states) {
                                              if (states.contains(
                                                WidgetState.hovered,
                                              )) {
                                                return const Color(
                                                  0xFF4D67AE,
                                                ).withValues(alpha: 0.08);
                                              }
                                              return zebraColor;
                                            }),
                                        cells: [
                                          DataCell(
                                            Text(
                                              route.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              route.initialLatitude
                                                  .toStringAsFixed(5),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              route.initialLongitude
                                                  .toStringAsFixed(5),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              route.finalLatitude
                                                  .toStringAsFixed(5),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              route.finalLongitude
                                                  .toStringAsFixed(5),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              route.pois
                                                  .map((e) => e.nombre)
                                                  .join(', '),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                IconButton(
                                                  tooltip: "Editar",
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    color: Color(0xFF4D67AE),
                                                  ),
                                                  onPressed: () {
                                                    context.go(
                                                      '/rutas/edit/${route.id}',
                                                      extra: route,
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  tooltip: "Eliminar",
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.redAccent,
                                                  ),
                                                  onPressed: () {
                                                    _confirmDeleteRouteConDobleCheck(
                                                      context,
                                                      route,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
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
      ),
    );
  }

  //Showdialog de confirmación doble antes de eliminar una ruta
  Future<void> _confirmDeleteRouteConDobleCheck(
    BuildContext context,
    MapRoute route,
  ) async {
    // ====== 🧩 Primer diálogo: advertencia inicial ======
    final bool quiereContinuar =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 80,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ), // 👈 Limita el ancho del diálogo
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFE5E5),
                          radius: 20,
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Eliminar ruta",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF202124),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "¿Seguro que deseas eliminar la ruta \"${route.name}\"?",
                      style: const TextStyle(
                        fontSize: 15.5,
                        height: 1.4,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Esta acción no se puede deshacer y eliminará todos los datos asociados a esta ruta.",
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4D67AE),
                          ),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text("Continuar"),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;

    if (!quiereContinuar) return;

    // ====== 🧭 Segundo diálogo: detalle de POIs ======
    final bool confirmaEliminacion =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 60,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 22.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======= Header visual =======
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFE8EAFB),
                          radius: 24,
                          child: Icon(
                            Icons.map_rounded,
                            color: Color(0xFF4D67AE),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Puntos de interés asociados",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF202124),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ======= Mensaje de advertencia contextual =======
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.deepOrangeAccent,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              route.pois.isEmpty
                                  ? "Esta ruta no tiene puntos de interés asociados. La eliminación no afectará otros elementos del sistema."
                                  : "Si eliminas esta ruta, se desvincularán los siguientes puntos de interés y ya no estarán asociados a ninguna ruta.",
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ======= Lista de POIs =======
                    if (route.pois.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: Scrollbar(
                          radius: const Radius.circular(10),
                          thumbVisibility: true,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: route.pois.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 12,
                              color: Colors.transparent,
                            ),
                            itemBuilder: (_, index) {
                              final poi = route.pois[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.place_outlined,
                                      color: Color(0xFF4D67AE),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            poi.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Color(0xFF202124),
                                            ),
                                          ),
                                          if (poi.descripcion.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 3,
                                              ),
                                              child: Text(
                                                poi.descripcion['es']
                                                        ?.toString() ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 22),

                    // ======= Texto final explicativo =======
                    Text(
                      route.pois.isEmpty
                          ? "Puedes eliminar esta ruta con seguridad."
                          : "Los puntos de interés permanecerán en el sistema, pero sin asociación a ninguna ruta.",
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ======= Botones =======
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4D67AE),
                          ),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.delete_forever_rounded,
                            size: 18,
                          ),
                          label: const Text("Eliminar definitivamente"),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;

    if (!confirmaEliminacion || !context.mounted) return;

    // 🟢 Evento DeleteRoute al bloc
    context.read<RouteBloc>().add(DeleteRoute(route.id));
  }
}
