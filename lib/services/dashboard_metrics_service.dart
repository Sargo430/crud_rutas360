import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_rutas360/services/firestore_service.dart';

class DashboardMetrics {
  const DashboardMetrics({
    required this.routes,
    required this.pois,
    required this.categories,
    required this.activities,
  });

  final int routes;
  final int pois;
  final int categories;
  final int activities;
}

class DashboardMetricsService {
  DashboardMetricsService({FireStoreService? fireStoreService})
      : _fireStoreService = fireStoreService ?? FireStoreService();

  final FireStoreService _fireStoreService;

  StreamController<DashboardMetrics>? _metricsController;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _routesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _categoriesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activitiesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _poisSub;
  bool _metricsListenersActive = false;
  bool _isEmittingMetrics = false;
  bool _pendingMetricsEmission = false;

  Future<DashboardMetrics> fetchDashboardMetrics() async {
    try {
      final routesFuture = _fireStoreService.fetchAllRoutes();
      final poisFuture = _fireStoreService.fetchAllPOIs();
      final categoriesFuture =
          _fireStoreService.fetchAllCategories(forceRefresh: true);
      final activitiesFuture =
          _fireStoreService.fetchAllActivities(forceRefresh: true);

      final routes = await routesFuture;
      final pois = await poisFuture;
      final categories = await categoriesFuture;
      final activities = await activitiesFuture;

      return DashboardMetrics(
        routes: routes.length,
        pois: pois.length,
        categories: categories.length,
        activities: activities.length,
      );
    } catch (e) {
      throw Exception('Fallo la carga de las metricas del dashboard: $e');
    }
  }

  Stream<DashboardMetrics> watchDashboardMetrics() {
    _metricsController ??=
        StreamController<DashboardMetrics>.broadcast(onListen: () {
      _attachMetricsListeners();
    }, onCancel: () async {
      await _detachMetricsListeners();
    });
    return _metricsController!.stream;
  }

  void requestMetricsRefresh() {
    _scheduleMetricsEmission();
  }

  void _attachMetricsListeners() {
    if (_metricsListenersActive) return;
    _metricsListenersActive = true;
    _routesSub = FirebaseFirestore.instance
        .collection('ruta')
        .snapshots()
        .listen((_) => _scheduleMetricsEmission(), onError: _handleStreamError);
    _categoriesSub = FirebaseFirestore.instance
        .collection('categorias')
        .snapshots()
        .listen((_) => _scheduleMetricsEmission(), onError: _handleStreamError);
    _activitiesSub = FirebaseFirestore.instance
        .collection('actividades')
        .snapshots()
        .listen((_) => _scheduleMetricsEmission(), onError: _handleStreamError);
    _poisSub = FirebaseFirestore.instance
        .collectionGroup('poi')
        .snapshots()
        .listen((_) => _scheduleMetricsEmission(), onError: _handleStreamError);
    _scheduleMetricsEmission();
  }

  Future<void> _detachMetricsListeners() async {
    if (!_metricsListenersActive) return;
    await _routesSub?.cancel();
    await _categoriesSub?.cancel();
    await _activitiesSub?.cancel();
    await _poisSub?.cancel();
    _routesSub = null;
    _categoriesSub = null;
    _activitiesSub = null;
    _poisSub = null;
    _metricsListenersActive = false;
  }

  void _scheduleMetricsEmission() {
    if (_metricsController == null) return;
    if (_isEmittingMetrics) {
      _pendingMetricsEmission = true;
      return;
    }
    _emitMetricsInternal();
  }

  Future<void> _emitMetricsInternal() async {
    if (_metricsController == null) return;
    _isEmittingMetrics = true;
    do {
      _pendingMetricsEmission = false;
      try {
        final metrics = await fetchDashboardMetrics();
        _metricsController?.add(metrics);
      } catch (e, stackTrace) {
        _metricsController?.addError(e, stackTrace);
      }
    } while (_pendingMetricsEmission);
    _isEmittingMetrics = false;
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    _metricsController?.addError(error, stackTrace);
  }
}

