import 'package:crud_rutas360/events/poi_events.dart';
import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/models/route_model.dart';
import 'package:crud_rutas360/states/poi_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crud_rutas360/services/firestore_service.dart';


class PoiBloc extends Bloc<POIEvent, PoiState> {
  final FireStoreService fireStoreService;

  PoiBloc(this.fireStoreService) : super(PoiInitial()) {
    on<LoadPOIs>((event, emit) async {
      emit(PoiLoading());
      try {
        final pois = await fireStoreService.fetchAllPOIs();
        emit(PoiLoaded(pois));
      } catch (e) {
        emit(PoiError(e.toString()));
      }
    });

    on<AddPOI>((event, emit) async {
      emit(PoiLoading());
      try {
        await fireStoreService.addPOI(event.poi, event.poi.routeId ?? '',event.image, event.new360Views);
        
        // Load the updated POIs first
        final pois = await fireStoreService.fetchAllPOIs();
        emit(PoiLoaded(pois));
        
        // Then emit success message
        emit(PoiOperationSuccess("POI añadida con éxito"));
      } catch (e) {
        emit(PoiError(e.toString()));
      }
    });

    on<UpdatePOI>((event, emit) async {
      emit(PoiLoading());
      try {
        await fireStoreService.updatePOI(
          event.poi,
          event.poi.routeId ?? '',
          image: event.image,
          new360views: event.new360Views,
        );
        final pois = await fireStoreService.fetchAllPOIs();
        emit(PoiLoadedWithSuccess(pois, "POI actualizada con éxito"));
      } catch (e) {
        emit(PoiError(e.toString()));
      }
      });

    on<DeletePOI>((event, emit) async {
      emit(PoiLoading());
      try {
        await fireStoreService.deletePOI(event.poiId, event.routeId);
        
        // Load the updated POIs first
        final pois = await fireStoreService.fetchAllPOIs();
        emit(PoiLoaded(pois));
        
        // Then emit success message
        emit(PoiOperationSuccess("POI eliminada con éxito"));
      } catch (e) {
        emit(PoiError(e.toString()));
      }
    });

    on<SelectPOI>((event, emit) async {
      List<PoiCategory> categories = await fireStoreService.fetchAllCategories();
      List<Activity> activities = await fireStoreService.fetchAllActivities();
      List<MapRoute> routes = await fireStoreService.fetchAllRoutes();
      emit(PoiFormState(poi: event.poi, routes: routes, categories: categories, activities: activities));
    });

  }
}
