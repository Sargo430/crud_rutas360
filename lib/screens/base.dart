import 'package:crud_rutas360/blocs/activity_bloc.dart';
import 'package:crud_rutas360/blocs/category_bloc.dart';
import 'package:crud_rutas360/blocs/poi_bloc.dart';
import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/activity_event.dart';
import 'package:crud_rutas360/events/category_event.dart';
import 'package:crud_rutas360/events/poi_events.dart';
import 'package:crud_rutas360/events/route_event.dart';
import 'package:crud_rutas360/states/activity_state.dart';
import 'package:crud_rutas360/states/category_state.dart';
import 'package:crud_rutas360/states/poi_state.dart';
import 'package:crud_rutas360/states/route_state.dart';
import 'package:crud_rutas360/widgets/desktop_only_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';
class Base extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const Base({super.key, required this.navigationShell});

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  late final SidebarXController sidebarController;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarXController(
      selectedIndex: widget.navigationShell.currentIndex,
      extended: true, 
    );
  }

  static const double kSidebarWidthExpanded = 220;
  static const double kSidebarWidthCollapsed = 80;
  static const double kHandleWidth = 28;
  static const double kHandleHeight = 84;
  static const double kHandleOverlap = 12;

  void onItemSelected(int index) {
    widget.navigationShell.goBranch(index, initialLocation: true); //  Cambio: al hacer clic en el botón del sidebar, se redirige a la vista principal del módulo.
    sidebarController.selectIndex(index); //  Ajuste: se resetea el estado para evitar mostrar pantallas de creación o edición anteriores.

    //  Cambio: al activar una pestaña se solicita la data inicial del módulo seleccionado.
    //  Ajuste: se emiten los eventos de carga para restablecer el estado base de cada sección.
    switch (index) {
      case 1:
        final routeBloc = context.read<RouteBloc>();
        final routeState = routeBloc.state;
        if (routeState is! RouteLoaded && routeState is! RouteLoading) {
          // OPTIMIZACION: evitamos consultas redundantes cuando ya se cuenta con datos de rutas.
          routeBloc.add(LoadRoute());
        }
        break;
      case 2:
        final poiBloc = context.read<PoiBloc>();
        final poiState = poiBloc.state;
        if (poiState is! PoiLoaded &&
            poiState is! PoiLoadedWithSuccess &&
            poiState is! PoiLoading) {
          // OPTIMIZACION: solicitamos la lista de POI solo si no esta disponible o cargando.
          poiBloc.add(LoadPOIs());
        }
        break;
      case 3:
        final categoryBloc = context.read<CategoryBloc>();
        final categoryState = categoryBloc.state;
        if (categoryState is! CategoryLoaded &&
            categoryState is! CategoryLoading) {
          // OPTIMIZACION: pedimos categorias unicamente cuando no hay datos activos.
          categoryBloc.add(LoadCategories());
        }
        break;
      case 4:
        final activityBloc = context.read<ActivityBloc>();
        final activityState = activityBloc.state;
        if (activityState is! ActivityLoaded &&
            activityState is! ActivityLoading &&
            activityState is! ActivityLoadedWithSuccess) {
          // OPTIMIZACION: reducimos llamadas a Firestore reutilizando las actividades ya cargadas.
          activityBloc.add(LoadActivities());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bool isMobilePlatform = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final bool isSmallWidth = media.size.width < 720;
    if (isMobilePlatform || isSmallWidth) {
      return const DesktopOnlyMessage();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D67AE),
        elevation: 0,
        title: Row(
          children: const [
            SizedBox(width: 12),
            Text(
              "Rutas Colbún",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              SidebarX(
                controller: sidebarController,
                showToggleButton: false,
                theme: SidebarXTheme(
                  decoration: const BoxDecoration(color: Colors.white),
                  textStyle: TextStyle(color: Colors.black54),
                  selectedTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  itemTextPadding: const EdgeInsets.only(left: 16),
                  selectedItemTextPadding: const EdgeInsets.only(left: 16),
                  itemDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selectedItemDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF4D67AE).withAlpha(30),
                    border: Border.all(
                      color: const Color(0xFF4D67AE).withAlpha(80),
                      width: 1,
                    ),
                  ),
                  iconTheme: const IconThemeData(
                    color: Colors.black54,
                    size: 20,
                  ),
                  selectedIconTheme: const IconThemeData(
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                extendedTheme: const SidebarXTheme(
                  width: kSidebarWidthExpanded,
                  decoration: BoxDecoration(color: Colors.white),
                ),
                headerBuilder: (context, extended) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    child: extended
                        ? const Text(
                            "Navegación",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                },
                footerBuilder: (context, extended) {
                  return GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout,
                            size: 20,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          if (extended)
                            Expanded(
                              child: Text(
                                "Cerrar sesión ",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                items: [
                  SidebarXItem(
                    icon: Icons.home,
                    label: 'Inicio',
                    onTap: () => onItemSelected(0),
                  ),
                  SidebarXItem(
                    icon: Icons.route,
                    label: 'Rutas',
                    onTap: () => onItemSelected(1),
                  ),
                  SidebarXItem(
                    icon: Icons.location_on,
                    label: 'POIs',
                    onTap: () => onItemSelected(2),
                  ),
                  SidebarXItem(
                    icon: Icons.category,
                    label: 'Categorías',
                    onTap: () => onItemSelected(3),
                  ),
                  SidebarXItem(
                    icon: Icons.hiking,
                    label: 'Actividades',
                    onTap: () => onItemSelected(4),
                  ),
                ],
              ),
              Expanded(child: widget.navigationShell),
            ],
          ),

          Positioned.fill(
            child: AnimatedBuilder(
              animation: sidebarController,
              builder: (context, _) {
                final bool isOpen = sidebarController.extended;
                final double targetWidth =
                    isOpen ? kSidebarWidthExpanded : kSidebarWidthCollapsed;

                return Align(
                  alignment: Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    tween: Tween<double>(end: targetWidth),
                    builder: (context, animatedWidth, __) {
                      return Transform.translate(
                        offset: Offset(animatedWidth - kHandleOverlap, 0),
                        child: GestureDetector(
                          onTap: () =>
                              sidebarController.setExtended(!isOpen), 
                          child: Container(
                            width: kHandleWidth,
                            height: kHandleHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1F000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Color(0xFFE6E6EA),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isOpen
                                      ? Icons.chevron_left
                                      : Icons.chevron_right,
                                  key: ValueKey<bool>(isOpen),
                                  size: 20,
                                  color: const Color(0xFF4D67AE),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
