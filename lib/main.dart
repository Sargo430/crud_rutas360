import 'package:crud_rutas360/blocs/category_bloc.dart';
import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/category_event.dart';
import 'package:crud_rutas360/firebase_options.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/screens/base.dart';
import 'package:crud_rutas360/screens/category_form.dart';
import 'package:crud_rutas360/screens/category_table.dart';
import 'package:crud_rutas360/screens/create_route.dart';
import 'package:crud_rutas360/models/route_model.dart';
import 'package:crud_rutas360/screens/home.dart';
import 'package:crud_rutas360/screens/rutas_table.dart';
import 'package:crud_rutas360/services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final sectionNavigatorKey = GlobalKey<NavigatorState>();
    final GoRouter router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Base(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              navigatorKey: sectionNavigatorKey,
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/rutas',
                  builder: (context, state) => const TablaRutas(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'create',
                      builder: (context, state) => BlocProvider(
                        create: (context) => RouteBloc(FireStoreService()),
                        child: CreateRoute(
                          rootNavigatorKey: rootNavigatorKey
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'edit/:id',
                      builder: (context, state) {
                        return BlocProvider(
                          create: (context) => RouteBloc(FireStoreService()),
                          child: CreateRoute(
                            rootNavigatorKey: rootNavigatorKey,
                            route: state.extra is MapRoute
                              ? state.extra as MapRoute
                              : null,
                          ),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/pois',
                  builder: (context, state) => const Card(child: Text('POIs')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/categorias',
                  builder: (context, state) => const CategoryTable(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'create',
                      builder: (context, state) {
                        context.read<CategoryBloc>().add(SelectCategory(category: null));
                        return const CategoryForm();
                      },
                    ),
                    GoRoute(
                      path: 'edit/:id',
                      builder: (context, state) {
                        context.read<CategoryBloc>().add(SelectCategory(category: state.extra as PoiCategory ));
                        return const CategoryForm();
                      },
                    )
                  ]
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/actividades',
                  builder: (context, state) => const Card(child: Text('Actividades')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RouteBloc(FireStoreService())),
        BlocProvider(create: (context) => CategoryBloc(FireStoreService())),
      ],
      child: MaterialApp.router(
        title: 'Rutas360',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: router,
      ),
    );
  }
}
