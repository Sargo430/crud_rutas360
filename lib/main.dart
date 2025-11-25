import 'package:crud_rutas360/blocs/activity_bloc.dart';
import 'package:crud_rutas360/blocs/category_bloc.dart';
import 'package:crud_rutas360/blocs/poi_bloc.dart';
import 'package:crud_rutas360/blocs/route_bloc.dart';
import 'package:crud_rutas360/events/activity_event.dart';
import 'package:crud_rutas360/events/category_event.dart';
import 'package:crud_rutas360/events/poi_events.dart';
import 'package:crud_rutas360/firebase_options.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/screens/activity_form.dart';
import 'package:crud_rutas360/screens/activity_table.dart';
import 'package:crud_rutas360/screens/base.dart';
import 'package:crud_rutas360/screens/category_form.dart';
import 'package:crud_rutas360/screens/category_table.dart';
import 'package:crud_rutas360/screens/create_route.dart';
import 'package:crud_rutas360/models/route_model.dart';
import 'package:crud_rutas360/screens/form_wrappers.dart';
import 'package:crud_rutas360/screens/home.dart';
import 'package:crud_rutas360/screens/login_page.dart';
import 'package:crud_rutas360/screens/poi_form.dart';
import 'package:crud_rutas360/screens/poi_table.dart';
import 'package:crud_rutas360/screens/rutas_table.dart';
import 'package:crud_rutas360/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        GoRoute(path: '/', builder: (context, state) => const LoginPage()),
        StatefulShellRoute.indexedStack(
          redirect: (context, state) {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return '/';
            }
            return null;
          },
          builder: (context, state, navigationShell) {
            return Base(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              navigatorKey: sectionNavigatorKey,
              routes: [
                GoRoute(
                  path: '/home',
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
                        child: CreateRoute(rootNavigatorKey: rootNavigatorKey),
                      ),
                    ),
                    GoRoute(
                      path: 'edit/:id',
                      redirect: (context, state) {
                        final id = state.pathParameters['id'];
                        if (id == null || id.isEmpty) {
                          return '/rutas';
                        }
                        return null;
                      },
                      builder: (context, state) {
                        final routeId = state.pathParameters['id']!;
                        final initialRoute = state.extra is MapRoute
                            ? state.extra as MapRoute
                            : null;
                        return BlocProvider(
                          create: (context) => RouteBloc(FireStoreService()),
                          child: RouteFormWrapper(
                            routeId: routeId,
                            rootNavigatorKey: rootNavigatorKey,
                            initialRoute: initialRoute,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/pois',
                  builder: (context, state) => const PoiTable(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'create',
                      builder: (context, state) {
                        context.read<PoiBloc>().add(SelectPOI(poi: null));
                        return const PoiForm();
                      },
                    ),
                    GoRoute(
                      path: 'edit/:id',
                      redirect: (context, state) {
                        final id = state.pathParameters['id'];
                        if (id == null || id.isEmpty) {
                          return '/pois';
                        }
                        return null;
                      },
                      builder: (context, state) {
                        final poiId = state.pathParameters['id']!;
                        final initialPoi = state.extra is POI
                            ? state.extra as POI
                            : null;
                        return PoiFormWrapper(
                          poiId: poiId,
                          initialPoi: initialPoi,
                        );
                      },
                    ),
                  ],
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
                        context.read<CategoryBloc>().add(
                          SelectCategory(category: null),
                        );
                        return const CategoryForm();
                      },
                    ),
                    GoRoute(
                      path: 'edit/:id',
                      redirect: (context, state) {
                        final id = state.pathParameters['id'];
                        if (id == null || id.isEmpty) {
                          return '/categorias';
                        }
                        return null;
                      },
                      builder: (context, state) {
                        final categoryId = state.pathParameters['id']!;
                        final initialCategory = state.extra is PoiCategory
                            ? state.extra as PoiCategory
                            : null;
                        return CategoryFormWrapper(
                          categoryId: categoryId,
                          initialCategory: initialCategory,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/actividades',
                  builder: (context, state) => const ActivityTable(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'create',
                      builder: (context, state) {
                        context.read<ActivityBloc>().add(
                          SelectActivity(activity: null),
                        );
                        return const ActivityForm();
                      },
                    ),
                    GoRoute(
                      path: 'edit/:id',
                      redirect: (context, state) {
                        final id = state.pathParameters['id'];
                        if (id == null || id.isEmpty) {
                          return '/actividades';
                        }
                        return null;
                      },
                      builder: (context, state) {
                        final activityId = state.pathParameters['id']!;
                        final initialActivity = state.extra is Activity
                            ? state.extra as Activity
                            : null;
                        return ActivityFormWrapper(
                          activityId: activityId,
                          initialActivity: initialActivity,
                        );
                      },
                    ),
                  ],
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
        BlocProvider(create: (context) => ActivityBloc(FireStoreService())),
        BlocProvider(create: (context) => PoiBloc(FireStoreService())),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Rutas360',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: router,
      ),
    );
  }
}
