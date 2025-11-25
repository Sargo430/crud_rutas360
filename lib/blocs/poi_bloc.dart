import 'package:crud_rutas360/events/poi_events.dart';
import 'package:crud_rutas360/states/poi_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crud_rutas360/services/firestore_service.dart';

class PoiBloc extends Bloc<POIEvent, PoiState> {
  final FireStoreService fireStoreService;

  PoiBloc(this.fireStoreService) : super(PoiInitial()) {
    // Cargar todos los POIs
    on<LoadPOIs>((event, emit) async {
      emit(PoiLoading());
      try {
        final pois = await fireStoreService.fetchAllPOIs();
        emit(PoiLoaded(pois));
      } catch (e) {
        emit(PoiError('Error cargando POIs: $e'));
      }
    });

    // Agregar nuevo POI
    on<AddPOI>((event, emit) async {
      emit(PoiLoading());
      try {
        final String? routeId = (event.poi.routeId != null &&
                event.poi.routeId!.isNotEmpty)
            ? event.poi.routeId
            : null;

        await fireStoreService.addPOI(
          event.poi,
          routeId, // ✅ se envía null si está sin asignar
          event.image,
          event.new360Views,
        );

        final pois = await fireStoreService.fetchAllPOIs();
        emit(PoiLoadedWithSuccess(pois, "POI agregada con éxito"));
      } catch (e) {
        emit(PoiError("Error agregando POI: $e"));
      }
    });

    // Actualizar POI existente
    on<UpdatePOI>((event, emit) async {
      emit(PoiLoading());
      try {
        final String? routeId = (event.poi.routeId != null &&
                event.poi.routeId!.isNotEmpty)
            ? event.poi.routeId
            : null;

        await fireStoreService.updatePOI(
          event.poi,
          routeId, // ✅ permite sin ruta
          image: event.image,
          new360views: event.new360Views,
        );

        final pois = await fireStoreService.fetchAllPOIs();
        emit(PoiLoadedWithSuccess(pois, "POI actualizada con éxito"));
      } catch (e) {
        emit(PoiError("Error actualizando POI: $e"));
      }
    });

    // Eliminar POI
    on<DeletePOI>((event, emit) async {
      emit(PoiLoading());
      try {
        final String? routeId =
            (event.routeId != null && event.routeId!.isNotEmpty)
                ? event.routeId
                : null;

        await fireStoreService.deletePOI(event.poiId, routeId);

        final pois = await fireStoreService.fetchAllPOIs();
        emit(PoiLoadedWithSuccess(pois, "POI eliminada con éxito"));
      } catch (e) {
        emit(PoiError("Error eliminando POI: $e"));
      }
    });

    // Cargar formulario de POI
    on<SelectPOI>((event, emit) async {
      try {
        final categories = await fireStoreService.fetchAllCategories();
        final activities = await fireStoreService.fetchAllActivities();
        final routes = await fireStoreService.fetchAllRoutes();

        emit(
          PoiFormState(
            poi: event.poi,
            routes: routes,
            categories: categories,
            activities: activities,
          ),
        );
      } catch (e) {
        emit(PoiError("Error cargando datos del formulario: $e"));
      }
    });
  }
}
