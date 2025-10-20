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

  Future<DashboardMetrics> fetchDashboardMetrics() async {
    try {
      final routesFuture = _fireStoreService.fetchAllRoutes();
      final poisFuture = _fireStoreService.fetchAllPOIs();
      final categoriesFuture = _fireStoreService.fetchAllCategories();
      final activitiesFuture = _fireStoreService.fetchAllActivities();

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
      throw Exception('Falló la carga de las métricas del dashboard.: $e');
    }
  }
}
