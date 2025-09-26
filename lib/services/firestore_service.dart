import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/models/route_model.dart';



class FireStoreService {

  final CollectionReference _routesCollection = FirebaseFirestore.instance
      .collection('ruta');

  
  Future<List<POI>> fetchAllPOIs(String routeId) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('ruta')
        .doc(routeId)
        .collection('poi')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return POI(
        id: doc.id,
        nombre: data['nombre']?.toString() ?? '',
        descripcion: Map<String, dynamic>.from(data['descripcion'] ?? {}),
        imagen: data['imagen']?.toString() ?? '',
        latitud: (data['latitud'] ?? 0).toDouble(),
        longitud: (data['longitud'] ?? 0).toDouble(),
        categorias: List<String>.from(data['categoria'] ?? []),
        actividades: List<String>.from(data['actividades'] ?? []),
        vistas360: Map<String,dynamic>.from(data['vistas360'] ?? {}),
      );
    }).toList();
  } catch (e) {
    throw Exception('Error fetching POIs: $e');
  }
}

Future<List<MapRoute>> fetchRoutes() async {
  try {
    final querySnapshot = await _routesCollection.get();

    List<MapRoute> routes = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final pois = await fetchAllPOIs(doc.id); // await para obtener la lista real

      routes.add(MapRoute(
        id: doc.id,
        initialLatitude: (data['latitud_inicio'] ?? 0).toDouble(),
        initialLongitude: (data['longitud_inicio'] ?? 0).toDouble(),
        finalLatitude: (data['latitud_fin'] ?? 0).toDouble(),
        finalLongitude: (data['longitud_fin'] ?? 0).toDouble(),
        name: data['nombre']?.toString() ?? '',
        pois: pois,
      ));
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

}