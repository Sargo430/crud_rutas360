
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/models/route_model.dart';
import 'package:crud_rutas360/services/storage_service.dart';
import 'package:file_picker/file_picker.dart';

class FireStoreService {
  final CollectionReference<Map<String, dynamic>> _routesCollection =
      FirebaseFirestore.instance.collection('ruta');
  // OPTIMIZACION: caches en memoria para reutilizar categorias y actividades ya consultadas.
  final Map<String, PoiCategory> _categoryCache = {};
  final Map<String, Activity> _activityCache = {};
  // OPTIMIZACION: listas completas cacheadas para evitar reconsultas globales.
  List<PoiCategory>? _cachedCategoryList;
  List<Activity>? _cachedActivityList;

  Future<List<POI>> fetchAllPOIs() async {
    try {
      final routeQuerySnapshot = await _routesCollection.get();
      if (routeQuerySnapshot.docs.isEmpty) {
        return [];
      }

      final batches = await Future.wait(
        routeQuerySnapshot.docs.map((routeDoc) async {
          final poiSnapshot = await routeDoc.reference.collection('poi').get();
          final routeData = routeDoc.data();
          final poiDocs = poiSnapshot.docs
              .map(
                (doc) => {
                  'id': doc.id,
                  'data': doc.data(),
                },
              )
              .toList();
          return {
            'routeId': routeDoc.id,
            'routeName': routeData['nombre']?.toString() ?? '',
            'poiDocs': poiDocs,
          };
        }),
      );

      final List<Map<String, dynamic>> rawPois = [];
      final Set<String> categoryIds = {};
      final Set<String> activityIds = {};

      for (final batch in batches) {
        final routeId = batch['routeId'] as String;
        final routeName = batch['routeName'] as String;
        final poiDocs =
            List<Map<String, dynamic>>.from(batch['poiDocs'] as List);
        for (final doc in poiDocs) {
          final data = Map<String, dynamic>.from(doc['data'] as Map<String, dynamic>);
          final categoriasIds =
              List<String>.from((data['categoria'] ?? const <String>[]));
          final actividadesIds =
              List<String>.from((data['actividades'] ?? const <String>[]));

          categoryIds.addAll(
            categoriasIds.where(
              (id) => id.isNotEmpty && id != 'vacio',
            ),
          );
          activityIds.addAll(
            actividadesIds.where(
              (id) => id.isNotEmpty && id != 'vacio',
            ),
          );

          rawPois.add({
            'id': doc['id'] as String,
            'routeId': routeId,
            'routeName': routeName,
            'data': data,
            'categoriaIds': categoriasIds,
            'actividadIds': actividadesIds,
          });
        }
      }

      if (rawPois.isEmpty) {
        return [];
      }

      final categoriesFuture = _fetchCategoryMap(categoryIds);
      final activitiesFuture = _fetchActivityMap(activityIds);
      final categoriesById = await categoriesFuture;
      final activitiesById = await activitiesFuture;

      return rawPois.map((raw) {
        final data = raw['data'] as Map<String, dynamic>;
        final categoriasIds =
            List<String>.from(raw['categoriaIds'] as List<String>);
        final actividadesIds =
            List<String>.from(raw['actividadIds'] as List<String>);
        final categorias = categoriasIds
            .where((id) => categoriesById.containsKey(id))
            .map((id) => categoriesById[id]!)
            .toList();
        final actividades = actividadesIds
            .where((id) => activitiesById.containsKey(id))
            .map((id) => activitiesById[id]!)
            .toList();

        return POI(
          id: raw['id'] as String,
          routeId: raw['routeId'] as String,
          routeName: raw['routeName'] as String,
          nombre: data['nombre']?.toString() ?? '',
          descripcion: Map<String, dynamic>.from(data['descripcion'] ?? {}),
          imagen: data['imagen']?.toString() ?? '',
          latitud: (data['latitud'] ?? 0).toDouble(),
          longitud: (data['longitud'] ?? 0).toDouble(),
          categorias: categorias,
          actividades: actividades,
          vistas360: Map<String, dynamic>.from(data['vistas360'] ?? {}),
        );
      }).toList();
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

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final rawPois = <Map<String, dynamic>>[];
      // OPTIMIZACION: acumulamos los IDs necesarios para resolver catalogos con una sola consulta.
      final Set<String> categoryIds = {};
      final Set<String> activityIds = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final categoriasIds =
            List<String>.from((data['categoria'] ?? const <String>[]));
        final actividadesIds =
            List<String>.from((data['actividades'] ?? const <String>[]));

        categoryIds.addAll(
          categoriasIds.where(
            (id) => id.isNotEmpty && id != 'vacio',
          ),
        );
        activityIds.addAll(
          actividadesIds.where(
            (id) => id.isNotEmpty && id != 'vacio',
          ),
        );

        rawPois.add({
          'id': doc.id,
          'data': data,
          'categoriaIds': categoriasIds,
          'actividadIds': actividadesIds,
        });
      }

      final categoriesFuture = _fetchCategoryMap(categoryIds);
      final activitiesFuture = _fetchActivityMap(activityIds);
      final categoriesById = await categoriesFuture;
      final activitiesById = await activitiesFuture;

      return rawPois.map((raw) {
        final data = raw['data'] as Map<String, dynamic>;
        final categoriasIds =
            List<String>.from(raw['categoriaIds'] as List<String>);
        final actividadesIds =
            List<String>.from(raw['actividadIds'] as List<String>);
        final categorias = categoriasIds
            .where((id) => categoriesById.containsKey(id))
            .map((id) => categoriesById[id]!)
            .toList();
        final actividades = actividadesIds
            .where((id) => activitiesById.containsKey(id))
            .map((id) => activitiesById[id]!)
            .toList();

        return POI(
          id: raw['id'] as String,
          routeId: routeId,
          nombre: data['nombre']?.toString() ?? '',
          descripcion: Map<String, dynamic>.from(data['descripcion'] ?? {}),
          imagen: data['imagen']?.toString() ?? '',
          latitud: (data['latitud'] ?? 0).toDouble(),
          longitud: (data['longitud'] ?? 0).toDouble(),
          categorias: categorias,
          actividades: actividades,
          vistas360: Map<String, dynamic>.from(data['vistas360'] ?? {}),
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching POIs: $e');
    }
  }

  Future<void> addPOI(POI poi, String routeId, PlatformFile? image, Map<String, PlatformFile?>? new360views) async {
    try {
      
  
      // Upload main image only if provided with bytes; else keep empty string
      String imageUrl = '';
      if (image != null && image.bytes != null && image.bytes!.isNotEmpty) {
        final baseName = image.name;
        final ext = image.extension ?? 'jpg';
        final normalized = baseName.toLowerCase().endsWith('.$ext')
            ? baseName
            : '$baseName.$ext';
        imageUrl = await StorageService().uploadBytes(
          image.bytes!,
          normalized,
          ext,
        );
      }

      // Upload seasonal 360 only if bytes present; else empty string
      Future<String> uploadOrEmpty(PlatformFile? f, String fallbackName) async {
        if (f != null && f.bytes != null && f.bytes!.isNotEmpty) {
          final ext = f.extension ?? 'jpg';
          final baseName = f.name.isNotEmpty ? f.name : fallbackName;
          final normalized = baseName.toLowerCase().endsWith('.$ext')
              ? baseName
              : '$baseName.$ext';
          return await StorageService().uploadBytes(
            f.bytes!,
            normalized,
            ext,
          );
        }
        return '';
      }

      final Map<String, String> vistas360Urls = {
        'Invierno': await uploadOrEmpty(new360views?['Invierno'], 'invierno'),
        'Primavera': await uploadOrEmpty(new360views?['Primavera'], 'primavera'),
        'Verano': await uploadOrEmpty(new360views?['Verano'], 'verano'),
        'Otoño': await uploadOrEmpty(new360views?['Otoño'], 'otono'),
      };
      
      await FirebaseFirestore.instance
          .collection('ruta')
          .doc(routeId)
          .collection('poi')
          .add({
            'nombre': poi.nombre,
            'descripcion': poi.descripcion,
            'imagen': imageUrl,
            'latitud': poi.latitud,
            'longitud': poi.longitud,
            'categoria': poi.categorias.map((cat) => cat.id).toList(),
            'actividades': poi.actividades.map((act) => act.id).toList(),
            'vistas360': vistas360Urls,
          });
     
    } catch (e) {
      
      throw Exception('Error adding POI: $e');
    }
  }

  Future<void> updatePOI(
    POI poi,
    String routeId, {
    PlatformFile? image,
    Map<String, PlatformFile?>? new360views,
  }) async {
    try {
      
      
      final docRef = FirebaseFirestore.instance
          .collection('ruta')
          .doc(routeId)
          .collection('poi')
          .doc(poi.id);

      
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception('POI not found for update');
      }
      final data = snapshot.data() as Map<String, dynamic>;
      

      // Existing URLs
      String currentImageUrl = (data['imagen'] ?? '').toString();
      final Map<String, dynamic> currentVistas =
          Map<String, dynamic>.from(data['vistas360'] ?? {});

      // Main image: replace if new provided
      String updatedImageUrl = currentImageUrl;
      
      if (image != null && image.bytes != null && image.bytes!.isNotEmpty) {
        
        // delete old if exists
        if (currentImageUrl.isNotEmpty) {
          
          await StorageService().deleteFile(currentImageUrl);
        }
        final ext = image.extension ?? 'jpg';
        final baseName = image.name;
        final normalized = baseName.toLowerCase().endsWith('.$ext')
            ? baseName
            : '$baseName.$ext';
        
        updatedImageUrl = await StorageService()
            .uploadBytes(image.bytes!, normalized, ext);
        
      }

      // Seasons mapping to ensure consistent keys in Firestore
      const seasons = ['Invierno', 'Primavera', 'Verano', 'Otoño'];
      final Map<String, String> updatedVistas = {};

     
      for (final season in seasons) {
        final lower = season.toLowerCase();
        final existingUrl = (currentVistas[season] ?? currentVistas[lower] ?? '')
            .toString();
        String newUrl = existingUrl;

        final PlatformFile? newFile = new360views != null
            ? new360views[season]
            : null;

        
        if (newFile != null && newFile.bytes != null && newFile.bytes!.isNotEmpty) {
          // If replacing, delete existing
          if (existingUrl.isNotEmpty) {
            await StorageService().deleteFile(existingUrl);
          }
          final ext = newFile.extension ?? 'jpg';
          final baseName = newFile.name.isNotEmpty ? newFile.name : lower;
          final normalized = baseName.toLowerCase().endsWith('.$ext')
              ? baseName
              : '$baseName.$ext';
          newUrl = await StorageService()
              .uploadBytes(newFile.bytes!, normalized, ext);
        }

        updatedVistas[season] = newUrl; // keep empty string if none
      }

      await docRef.update({
        'nombre': poi.nombre,
        'routeId': poi.routeId,
        'descripcion': poi.descripcion,
        'imagen': updatedImageUrl,
        'latitud': poi.latitud,
        'longitud': poi.longitud,
        'categoria': poi.categorias.map((cat) => cat.id).toList(),
        'actividades': poi.actividades.map((act) => act.id).toList(),
        'vistas360': updatedVistas,
      });
      
      
    } catch (e) {
      throw Exception('Error updating POI: $e');
    }
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
      final docs = querySnapshot.toList();
      // OPTIMIZACION: resolvemos los POI de cada ruta en paralelo para evitar n llamadas secuenciales.
      final poiFutures = docs.map((doc) => fetchRoutesPOIs(doc.id)).toList();
      final poisPerRoute = await Future.wait(poiFutures);

      final List<MapRoute> routes = [];
      for (var i = 0; i < docs.length; i++) {
        final doc = docs[i];
        final data = doc.data();
        final pois = poisPerRoute[i];
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

  Future<void> addRoute(MapRoute route) async { 
    final docRef = await _routesCollection.add({ 
      'nombre': route.name,
      'latitud_inicio': route.initialLatitude,
      'longitud_inicio': route.initialLongitude,
      'latitud_fin': route.finalLatitude,
      'longitud_fin': route.finalLongitude,
    });
    if (route.pois.isNotEmpty) { 
      await _syncRoutePOIs( 
        routeId: docRef.id, 
        selectedPois: route.pois, 
      ); 
    } 
  }

  Future<void> updateRoute(MapRoute route) async { 
    final docRef = _routesCollection.doc(route.id); 
    await docRef.update({ 
      'nombre': route.name,
      'latitud_inicio': route.initialLatitude,
      'longitud_inicio': route.initialLongitude,
      'latitud_fin': route.finalLatitude,
      'longitud_fin': route.finalLongitude,
    });
    await _syncRoutePOIs( 
      routeId: route.id, 
      selectedPois: route.pois, 
    ); 
  }

  Future<void> _syncRoutePOIs({ 
    required String routeId, 
    required List<POI> selectedPois, 
  }) async { 
    final poiCollection = _routesCollection 
        .doc(routeId) 
        .collection('poi'); 
    final existingSnapshot = await poiCollection.get(); 
    final existingDataById = <String, Map<String, dynamic>>{ 
      for (final doc in existingSnapshot.docs) 
        doc.id: Map<String, dynamic>.from( 
          doc.data() as Map, 
        ), 
    }; 

    final currentIds = existingDataById.keys.toSet(); 
    final selectedIds = selectedPois.map((poi) => poi.id).toSet(); 

    final idsToRemove = currentIds.difference(selectedIds); 
    final idsToAdd = selectedIds.difference(currentIds); 

    final sinAsignarCollection = 
        _routesCollection 
            .doc('sin_asignar') 
            .collection('poi'); 

    for (final id in idsToRemove) { 
      final data = existingDataById[id]; 
      if (data != null) { 
        await sinAsignarCollection.doc(id).set(data); 
      } 
      await poiCollection.doc(id).delete(); 
    } 

    for (final id in idsToAdd) { 
      final sinAsignarDoc = sinAsignarCollection.doc(id); 
      final sinAsignarSnapshot = await sinAsignarDoc.get(); 

      Map<String, dynamic>? poiData; 
      bool removeFromSinAsignar = false; 
      DocumentReference? sourceDocRef; 

      if (sinAsignarSnapshot.exists) { 
        poiData = Map<String, dynamic>.from( 
          sinAsignarSnapshot.data() as Map, 
        ); 
        removeFromSinAsignar = true; 
      } else { 
        POI? selectedPoi; 
        for (final poi in selectedPois) { 
          if (poi.id == id) { 
            selectedPoi = poi; 
            break; 
          } 
        } 

        if (selectedPoi != null && 
            selectedPoi.routeId != null && 
            selectedPoi.routeId!.isNotEmpty && 
            selectedPoi.routeId != routeId) { 
          sourceDocRef = _routesCollection 
              .doc(selectedPoi.routeId) 
              .collection('poi') 
              .doc(id); 
          final sourceSnapshot = await sourceDocRef.get(); 
          if (sourceSnapshot.exists) { 
            poiData = Map<String, dynamic>.from( 
              sourceSnapshot.data() as Map, 
            ); 
          } 
        } 
      } 

      if (poiData != null) { 
        await poiCollection.doc(id).set(poiData); 
        if (removeFromSinAsignar) { 
          await sinAsignarDoc.delete(); 
        } 
        if (sourceDocRef != null) { 
          await sourceDocRef.delete(); 
        } 
      } 
    } 
  } 

  Future<void> deleteRoute(String routeId) {
    return _routesCollection.doc(routeId).delete();
  }

  Future<List<PoiCategory>> fetchAllCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCategoryList != null) {
      // OPTIMIZACION: devolvemos una copia de la cache para evitar reconsultas completas.
      return List<PoiCategory>.from(_cachedCategoryList!);
    }
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('categorias')
          .get();

      final categories = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return PoiCategory(
          id: doc.id,
          nombre: Map<String, dynamic>.from(data['nombre'] ?? {}),
          backgroundColor: data['background_color']?.toString() ?? '',
          textColor: data['text_color']?.toString() ?? '',
        );
      }).toList();
      // OPTIMIZACION: persistimos los resultados en cache para reutilizarlos en futuras lecturas.
      for (final category in categories) {
        _categoryCache[category.id] = category;
      }
      _cachedCategoryList = categories;
      return List<PoiCategory>.from(categories);
    } catch (e) {
      throw Exception('Error fetching Categories: $e');
    }
  }

  Future<void> addCategory(PoiCategory category) async {
    await FirebaseFirestore.instance
        .collection('categorias')
        .doc(category.id)
        .set({
          'nombre': category.nombre,
          'background_color': category.backgroundColor,
          'text_color': category.textColor,
        });
    // OPTIMIZACION: actualizamos la cache tras mutar la coleccion.
    _cachedCategoryList = null;
    _categoryCache[category.id] = category;
  }

  Future<void> updateCategory(PoiCategory category) async {
    await FirebaseFirestore.instance
        .collection('categorias')
        .doc(category.id)
        .update({
          'nombre': category.nombre,
          'background_color': category.backgroundColor,
          'text_color': category.textColor,
        });
    // OPTIMIZACION: sincronizamos la cache con los nuevos datos.
    _cachedCategoryList = null;
    _categoryCache[category.id] = category;
  }

  Future<void> deleteCategory(String categoryId) async {
    await FirebaseFirestore.instance
        .collection('categorias')
        .doc(categoryId)
        .delete();
    // OPTIMIZACION: removemos la entrada cacheada para evitar devolver datos obsoletos.
    _cachedCategoryList = null;
    _categoryCache.remove(categoryId);
  }

  Future<List<PoiCategory>> fetchCategories(List<String> list) async {
    try {
      if (list.isEmpty || (list.length == 1 && list.first == 'vacio')) {
        return [];
      }

      final filtered = list
          .where((id) => id.isNotEmpty && id != 'vacio')
          .toList();
      if (filtered.isEmpty) {
        return [];
      }

      final missing = filtered
          .where((id) => !_categoryCache.containsKey(id))
          .toList();

      if (missing.isNotEmpty) {
        const int chunkSize = 10;
        for (var i = 0; i < missing.length; i += chunkSize) {
          final end = (i + chunkSize) > missing.length ? missing.length : i + chunkSize;
          final chunk = missing.sublist(i, end);
          final querySnapshot = await FirebaseFirestore.instance
              .collection('categorias')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          for (var doc in querySnapshot.docs) {
            final data = doc.data();
            final category = PoiCategory(
              id: doc.id,
              nombre: Map<String, dynamic>.from(data['nombre'] ?? {}),
              backgroundColor: data['background_color']?.toString() ?? '',
              textColor: data['text_color']?.toString() ?? '',
            );
            // OPTIMIZACION: guardamos cada resultado intermedio en cache.
            _categoryCache[category.id] = category;
          }
        }
      }

      return filtered
          .where((id) => _categoryCache.containsKey(id))
          .map((id) => _categoryCache[id]!)
          .toList();
    } catch (e) {
      throw Exception('Error fetching Categories: $e');
    }
  }

  Future<List<Activity>> fetchAllActivities({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedActivityList != null) {
      // OPTIMIZACION: reutilizamos la lista cacheada para evitar lecturas completas.
      return List<Activity>.from(_cachedActivityList!);
    }
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('actividades')
          .get();

      final activities = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Activity(
          id: doc.id,
          nombre: Map<String, dynamic>.from(data['nombre'] ?? {}),
          backgroundColor: data['background_color']?.toString() ?? '',
          textColor: data['text_color']?.toString() ?? '',
        );
      }).toList();
      for (final activity in activities) {
        _activityCache[activity.id] = activity;
      }
      _cachedActivityList = activities;
      return List<Activity>.from(activities);
    } catch (e) {
      throw Exception('Error fetching Actividades: $e');
    }
  }

  Future<void> addActivity(Activity activity) async {
    await FirebaseFirestore.instance
        .collection('actividades')
        .doc(activity.id)
        .set({
          'nombre': activity.nombre,
          'background_color': activity.backgroundColor,
          'text_color': activity.textColor,
        });
    // OPTIMIZACION: invalidamos la cache para que la proxima consulta use los nuevos datos.
    _cachedActivityList = null;
    _activityCache[activity.id] = activity;
  }

  Future<void> updateActivity(Activity activity) async {
    await FirebaseFirestore.instance
        .collection('actividades')
        .doc(activity.id)
        .update({
          'nombre': activity.nombre,
          'background_color': activity.backgroundColor,
          'text_color': activity.textColor,
        });
    // OPTIMIZACION: refrescamos la entrada cacheada tras la actualizacion.
    _cachedActivityList = null;
    _activityCache[activity.id] = activity;
  }

  Future<void> deleteActivity(String activityId) async {
    await FirebaseFirestore.instance
        .collection('actividades')
        .doc(activityId)
        .delete();
    // OPTIMIZACION: eliminamos la entrada correspondiente para no servir datos obsoletos.
    _cachedActivityList = null;
    _activityCache.remove(activityId);
  }

  Future<List<Activity>> fetchActivities(List<String> list) async {
    try {
      if (list.isEmpty || (list.length == 1 && list.first == 'vacio')) {
        return [];
      }

      final filtered = list
          .where((id) => id.isNotEmpty && id != 'vacio')
          .toList();
      if (filtered.isEmpty) {
        return [];
      }

      final missing = filtered
          .where((id) => !_activityCache.containsKey(id))
          .toList();

      if (missing.isNotEmpty) {
        const int chunkSize = 10;
        for (var i = 0; i < missing.length; i += chunkSize) {
          final end = (i + chunkSize) > missing.length ? missing.length : i + chunkSize;
          final chunk = missing.sublist(i, end);
          final querySnapshot = await FirebaseFirestore.instance
              .collection('actividades')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          for (var doc in querySnapshot.docs) {
            final data = doc.data();
            final activity = Activity(
              id: doc.id,
              nombre: Map<String, dynamic>.from(data['nombre'] ?? {}),
              backgroundColor: data['background_color']?.toString() ?? '',
              textColor: data['text_color']?.toString() ?? '',
            );
            // OPTIMIZACION: guardamos en cache los resultados del lote solicitado.
            _activityCache[activity.id] = activity;
          }
        }
      }

      return filtered
          .where((id) => _activityCache.containsKey(id))
          .map((id) => _activityCache[id]!)
          .toList();
    } catch (e) {
      throw Exception('Error fetching Activities: $e');
    }
  }

  Future<Map<String, PoiCategory>> _fetchCategoryMap(
    Set<String> ids,
  ) async {
    final filtered = ids
        .where((id) => id.isNotEmpty && id != 'vacio')
        .toList();
    if (filtered.isEmpty) {
      return {};
    }

    final categories = await fetchCategories(filtered);
    return {
      for (final category in categories) category.id: category,
    };
  }

  Future<Map<String, Activity>> _fetchActivityMap(
    Set<String> ids,
  ) async {
    final filtered = ids
        .where((id) => id.isNotEmpty && id != 'vacio')
        .toList();
    if (filtered.isEmpty) {
      return {};
    }

    final activities = await fetchActivities(filtered);
    return {
      for (final activity in activities) activity.id: activity,
    };
  }

  Future<List<MapRoute>> fetchAllRoutes() async {
    try {
      final querySnapshot = await _routesCollection.get();
      List<MapRoute> routes = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        routes.add(
          MapRoute(
            id: doc.id,
            initialLatitude: (data['latitud_inicio'] ?? 0).toDouble(),
            initialLongitude: (data['longitud_inicio'] ?? 0).toDouble(),
            finalLatitude: (data['latitud_fin'] ?? 0).toDouble(),
            finalLongitude: (data['longitud_fin'] ?? 0).toDouble(),
            name: data['nombre']?.toString() ?? '',
            pois: [],
          ),
        );
      }
      return routes;
    } catch (e) {
      throw Exception('Error fetching Routes: $e');
    }
  }

}
