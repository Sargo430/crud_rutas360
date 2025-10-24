import 'package:crud_rutas360/blocs/activity_bloc.dart';
import 'package:crud_rutas360/blocs/category_bloc.dart';
import 'package:crud_rutas360/blocs/poi_bloc.dart';
import 'package:crud_rutas360/events/activity_event.dart';
import 'package:crud_rutas360/events/category_event.dart';
import 'package:crud_rutas360/events/poi_events.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/models/route_model.dart';
import 'package:crud_rutas360/screens/activity_form.dart';
import 'package:crud_rutas360/screens/category_form.dart';
import 'package:crud_rutas360/screens/create_route.dart';
import 'package:crud_rutas360/screens/poi_form.dart';
import 'package:crud_rutas360/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ActivityFormWrapper extends StatefulWidget {
  final String activityId;
  final Activity? initialActivity;

  const ActivityFormWrapper({
    super.key,
    required this.activityId,
    this.initialActivity,
  });

  @override
  State<ActivityFormWrapper> createState() => _ActivityFormWrapperState();
}

class _ActivityFormWrapperState extends State<ActivityFormWrapper> {
  final FireStoreService _service = FireStoreService();
  bool _initialized = false;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureActivity());
  }

  Future<void> _ensureActivity() async {
    if (_initialized || !mounted) {
      return;
    }
    _initialized = true;

    final bloc = context.read<ActivityBloc>();

    if (widget.initialActivity != null) {
      bloc.add(SelectActivity(activity: widget.initialActivity));
      return;
    }

    final activity = await _service.fetchActivityById(widget.activityId);
    if (!mounted) {
      return;
    }
    if (activity == null) {
      _redirect(
        '/actividades',
        'No se encontro la actividad seleccionada. Se redirigio al listado.',
      );
      return;
    }
    bloc.add(SelectActivity(activity: activity));
  }

  void _redirect(String path, String message) {
    if (_redirected || !mounted) {
      return;
    }
    _redirected = true;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return const ActivityForm();
  }
}

class CategoryFormWrapper extends StatefulWidget {
  final String categoryId;
  final PoiCategory? initialCategory;

  const CategoryFormWrapper({
    super.key,
    required this.categoryId,
    this.initialCategory,
  });

  @override
  State<CategoryFormWrapper> createState() => _CategoryFormWrapperState();
}

class _CategoryFormWrapperState extends State<CategoryFormWrapper> {
  final FireStoreService _service = FireStoreService();
  bool _initialized = false;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureCategory());
  }

  Future<void> _ensureCategory() async {
    if (_initialized || !mounted) {
      return;
    }
    _initialized = true;

    final bloc = context.read<CategoryBloc>();

    if (widget.initialCategory != null) {
      bloc.add(SelectCategory(category: widget.initialCategory));
      return;
    }

    final category = await _service.fetchCategoryById(widget.categoryId);
    if (!mounted) {
      return;
    }
    if (category == null) {
      _redirect(
        '/categorias',
        'No se encontro la categoria seleccionada. Se redirigio al listado.',
      );
      return;
    }
    bloc.add(SelectCategory(category: category));
  }

  void _redirect(String path, String message) {
    if (_redirected || !mounted) {
      return;
    }
    _redirected = true;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return const CategoryForm();
  }
}

class PoiFormWrapper extends StatefulWidget {
  final String poiId;
  final POI? initialPoi;

  const PoiFormWrapper({super.key, required this.poiId, this.initialPoi});

  @override
  State<PoiFormWrapper> createState() => _PoiFormWrapperState();
}

class _PoiFormWrapperState extends State<PoiFormWrapper> {
  final FireStoreService _service = FireStoreService();
  bool _initialized = false;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePoi());
  }

  Future<void> _ensurePoi() async {
    if (_initialized || !mounted) {
      return;
    }
    _initialized = true;

    final bloc = context.read<PoiBloc>();

    if (widget.initialPoi != null) {
      bloc.add(SelectPOI(poi: widget.initialPoi));
      return;
    }

    final poi = await _service.fetchPoiById(widget.poiId);
    if (!mounted) {
      return;
    }
    if (poi == null) {
      _redirect(
        '/pois',
        'No se encontro el punto de interes seleccionado. Se redirigio al listado.',
      );
      return;
    }
    bloc.add(SelectPOI(poi: poi));
  }

  void _redirect(String path, String message) {
    if (_redirected || !mounted) {
      return;
    }
    _redirected = true;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return const PoiForm();
  }
}

class RouteFormWrapper extends StatefulWidget {
  final String routeId;
  final MapRoute? initialRoute;
  final GlobalKey<NavigatorState> rootNavigatorKey;

  const RouteFormWrapper({
    super.key,
    required this.routeId,
    required this.rootNavigatorKey,
    this.initialRoute,
  });

  @override
  State<RouteFormWrapper> createState() => _RouteFormWrapperState();
}

class _RouteFormWrapperState extends State<RouteFormWrapper> {
  final FireStoreService _service = FireStoreService();
  MapRoute? _route;
  bool _initialized = false;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _route = widget.initialRoute;
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureRoute());
  }

  Future<void> _ensureRoute() async {
    if (_initialized || !mounted) {
      return;
    }
    _initialized = true;

    if (_route != null) {
      return;
    }

    final route = await _service.fetchRouteById(widget.routeId);
    if (!mounted) {
      return;
    }
    if (route == null) {
      _redirect(
        '/rutas',
        'No se encontro la ruta seleccionada. Se redirigio al listado.',
      );
      return;
    }
    setState(() {
      _route = route;
    });
  }

  void _redirect(String path, String message) {
    if (_redirected || !mounted) {
      return;
    }
    _redirected = true;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    if (_redirected) {
      return const SizedBox.shrink();
    }
    if (_route == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return CreateRoute(
      rootNavigatorKey: widget.rootNavigatorKey,
      route: _route,
    );
  }
}
