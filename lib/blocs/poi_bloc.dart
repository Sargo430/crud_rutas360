import 'package:crud_rutas360/events/poi_events.dart';
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
        await fireStoreService.addPOI(event.poi, event.routeId);
        emit(PoiOperationSuccess("POI añadida con éxito"));
        add(LoadPOIs());
      } catch (e) {
        emit(PoiError(e.toString()));
      }
    });

    on<UpdatePOI>((event, emit) async {
      emit(PoiLoading());
      try {
        await fireStoreService.updatePOI(event.poi, event.routeId);
        emit(PoiOperationSuccess("POI actualizada con éxito"));
        add(LoadPOIs());
      } catch (e) {
        emit(PoiError(e.toString()));
      }
      });

    on<DeletePOI>((event, emit) async {
      emit(PoiLoading());
      try {
        await fireStoreService.deletePOI(event.poiId, event.routeId);
        emit(PoiOperationSuccess("POI eliminada con éxito"));
        add(LoadPOIs());
      } catch (e) {
        emit(PoiError(e.toString()));
      }
    },
    );
    on<SelectPOI>((event, emit) {
      emit(PoiFormState(poi: event.poi));
    });

  }
}
