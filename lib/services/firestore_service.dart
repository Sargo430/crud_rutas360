import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/models/route_model.dart';

class FireStoreService {
  final CollectionReference _routesCollection = FirebaseFirestore.instance
      .collection('ruta');

  Future<List<POI>> fetchAllPOIs() async {
    try {
      final routeQuerySnapshot = await FirebaseFirestore.instance
          .collection('ruta')
          .get();
      List<POI> pois = [];
      for (var routeDoc in routeQuerySnapshot.docs) {
        final poiCollection = await _routesCollection
            .doc(routeDoc.id)
            .collection('poi')
            .get();
        for (var doc in poiCollection.docs) {
          final data = doc.data();
          final categorias = await fetchCategories(
          List<String>.from((data['categoria'] ?? ['vacio'])),
        );
        final actividades = await fetchActivities(
          List<String>.from((data['actividades'] ?? ['vacio'])),
        );
          pois.add(
            POI(
              id: doc.id,
              routeId: routeDoc.id,
              routeName: routeDoc.data()['nombre']?.toString() ?? '',
              nombre: data['nombre']?.toString() ?? '',
              descripcion: Map<String, dynamic>.from(data['descripcion'] ?? {}),
              imagen: data['imagen']?.toString() ?? '',
              latitud: (data['latitud'] ?? 0).toDouble(),
              longitud: (data['longitud'] ?? 0).toDouble(),
              categorias: categorias,
              actividades: actividades,
              vistas360: Map<String, dynamic>.from(data['vistas360'] ?? {}),
            ),
          );
        }
      }
      return pois;
    } catch (e) {
      throw Exception('Error fetching POIs: $e');
    }
  }

  Future<List<POI>> fetchRoutesPOIs(String routeId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('ruta')
          .doc(routeId)
          .collection('poi')
          .get();
      List<POI> pois = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        final categorias = await fetchCategories(
          List<String>.from((data['categoria'] ?? ['vacio'])),
        );
        final actividades = await fetchActivities(
          List<String>.from((data['actividades'] ?? ['vacio'])),
        );
        pois.add(
          POI(
            id: doc.id,
            nombre: data['nombre']?.toString() ?? '',
            descripcion: Map<String, dynamic>.from(data['descripcion'] ?? {}),
            imagen: data['imagen']?.toString() ?? '',
            latitud: (data['latitud'] ?? 0).toDouble(),
            longitud: (data['longitud'] ?? 0).toDouble(),
            categorias: categorias,
            actividades: actividades,
            vistas360: Map<String, dynamic>.from(data['vistas360'] ?? {}),
          ),
        );
      }
      return pois;
    } catch (e) {
      throw Exception('Error fetching POIs: $e');
    }
  }

  Future<void> addPOI(POI poi, String routeId) {
    return FirebaseFirestore.instance
        .collection('ruta')
        .doc(routeId)
        .collection('poi')
        .doc(poi.id)
        .set({
          'nombre': poi.nombre,
          'descripcion': poi.descripcion,
          'imagen': poi.imagen,
          'latitud': poi.latitud,
          'longitud': poi.longitud,
          'categoria': poi.categorias.map((cat) => cat.id).toList(),
          'actividades': poi.actividades.map((act) => act.id).toList(),
          'vistas360': poi.vistas360,
        });
  }

  Future<void> updatePOI(POI poi, String routeId) {
    return FirebaseFirestore.instance
        .collection('ruta')
        .doc(routeId)
        .collection('poi')
        .doc(poi.id)
        .update({
          'nombre': poi.nombre,
          'routeId': poi.routeId,
          'descripcion': poi.descripcion,
          'imagen': poi.imagen,
          'latitud': poi.latitud,
          'longitud': poi.longitud,
          'categoria': poi.categorias.map((cat) => cat.id).toList(),
          'actividades': poi.actividades.map((act) => act.id).toList(),
          'vistas360': poi.vistas360,
        });
  }

  Future<void> deletePOI(String poiId, String routeId) {
    return FirebaseFirestore.instance
        .collection('ruta')
        .doc(routeId)
        .collection('poi')
        .doc(poiId)
        .delete();
  }

  Future<List<MapRoute>> fetchRoutes() async {
    try {
      final querySnapshotFull = await _routesCollection.get();
      final querySnapshot = querySnapshotFull.docs.where(
        (doc) => doc.id.toString() != "sin_asignar",
      );
      List<MapRoute> routes = [];

      for (var doc in querySnapshot) {
        final data = doc.data() as Map<String, dynamic>;
        final pois = await fetchRoutesPOIs(
          doc.id,
        ); // await para obtener la lista real

        routes.add(
          MapRoute(
            id: doc.id,
            initialLatitude: (data['latitud_inicio'] ?? 0).toDouble(),
            initialLongitude: (data['longitud_inicio'] ?? 0).toDouble(),
            finalLatitude: (data['latitud_fin'] ?? 0).toDouble(),
            finalLongitude: (data['longitud_fin'] ?? 0).toDouble(),
            name: data['nombre']?.toString() ?? '',
            pois: pois,
          ),
        );
      }
      return routes;
    } catch (e) {
      throw Exception('Error fetching Routes: $e');
    }
  }

  Future<void> addRoute(MapRoute route) {
    return _routesCollection.add({
      'nombre': route.name,
      'latitud_inicio': route.initialLatitude,
      'longitud_inicio': route.initialLongitude,
      'latitud_fin': route.finalLatitude,
      'longitud_fin': route.finalLongitude,
    });
  }

  Future<void> updateRoute(MapRoute route) {
    return _routesCollection.doc(route.id).update({
      'nombre': route.name,
      'latitud_inicio': route.initialLatitude,
      'longitud_inicio': route.initialLongitude,
      'latitud_fin': route.finalLatitude,
      'longitud_fin': route.finalLongitude,
    });
  }

  Future<void> deleteRoute(String routeId) {
    return _routesCollection.doc(routeId).delete();
  }

  Future<List<PoiCategory>> fetchAllCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('categorias')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return PoiCategory(
          id: doc.id,
          nombre: Map<String, dynamic>.from(data['nombre'] ?? {}),
          backgroundColor: data['background_color']?.toString() ?? '',
          textColor: data['text_color']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching Categories: $e');
    }
  }

  Future<void> addCategory(PoiCategory category) {
    return FirebaseFirestore.instance
        .collection('categorias')
        .doc(category.id)
        .set({
          'nombre': category.nombre,
          'background_color': category.backgroundColor,
          'text_color': category.textColor,
        });
  }

  Future<void> updateCategory(PoiCategory category) {
    return FirebaseFirestore.instance
        .collection('categorias')
        .doc(category.id)
        .update({
          'nombre': category.nombre,
          'background_color': category.backgroundColor,
          'text_color': category.textColor,
        });
  }

  Future<void> deleteCategory(String categoryId) {
    return FirebaseFirestore.instance
        .collection('categorias')
        .doc(categoryId)
        .delete();
  }

  Future<List<PoiCategory>> fetchCategories(List<String> list) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('categorias')
          .where(FieldPath.documentId, whereIn: list)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return PoiCategory(
          id: doc.id,
          nombre: Map<String, dynamic>.from(data['nombre'] ?? {}),
          backgroundColor: data['background_color']?.toString() ?? '',
          textColor: data['text_color']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching Categories: $e');
    }
  }

  Future<List<Activity>> fetchAllActivities() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('actividades')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Activity(
          id: doc.id,
          nombre: Map<String, dynamic>.from(data['nombre'] ?? {}),
          backgroundColor: data['background_color']?.toString() ?? '',
          textColor: data['text_color']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching Actividades: $e');
    }
  }

  Future<void> addActivity(Activity activity) {
    return FirebaseFirestore.instance
        .collection('actividades')
        .doc(activity.id)
        .set({
          'nombre': activity.nombre,
          'background_color': activity.backgroundColor,
          'text_color': activity.textColor,
        });
  }

  Future<void> updateActivity(Activity activity) {
    return FirebaseFirestore.instance
        .collection('actividades')
        .doc(activity.id)
        .update({
          'nombre': activity.nombre,
          'background_color': activity.backgroundColor,
          'text_color': activity.textColor,
        });
  }

  Future<void> deleteActivity(String activityId) {
    return FirebaseFirestore.instance
        .collection('categorias')
        .doc(activityId)
        .delete();
  }

  Future<List<Activity>> fetchActivities(List<String> list) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('actividades')
          .where(FieldPath.documentId, whereIn: list)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Activity(
          id: doc.id,
          nombre: Map<String, dynamic>.from(data['nombre'] ?? {}),
          backgroundColor: data['background_color']?.toString() ?? '',
          textColor: data['text_color']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching Activities: $e');
    }
  }
}
