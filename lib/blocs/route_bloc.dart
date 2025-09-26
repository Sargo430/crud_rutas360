import 'package:crud_rutas360/events/route_event.dart';
import 'package:crud_rutas360/states/route_state.dart';

import 'package:crud_rutas360/services/firestore_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final FireStoreService fireStoreService;

  RouteBloc(this.fireStoreService) : super(RouteInitial()) {
    on<LoadRoute>((event, emit) async {
      emit(RouteLoading());
      try {
        final routes = await fireStoreService.fetchRoutes();
        emit(RouteLoaded(routes));
      } catch (e) {
        emit(RouteError(e.toString()));
      }
    });

    on<AddRoute>((event, emit) async {
      emit(RouteLoading());
      try {
        await fireStoreService.addRoute(event.route);
        emit(RouteOperationSuccess("Ruta añadida con éxito"));
        add(LoadRoute());
      } catch (e) {
        emit(RouteError(e.toString()));
      }
    });

    on<UpdateRoute>((event, emit) async {
      emit(RouteLoading());
      try {
        await fireStoreService.updateRoute(event.route);
        emit(RouteOperationSuccess("Ruta actualizada con éxito"));
        add(LoadRoute());
      } catch (e) {
        emit(RouteError(e.toString()));
      }
    });

    on<DeleteRoute>((event, emit) async {
      emit(RouteLoading());
      try {
        await fireStoreService.deleteRoute(event.routeId);
        emit(RouteOperationSuccess("Ruta eliminada con éxito"));
        add(LoadRoute());
      } catch (e) {
        emit(RouteError(e.toString()));
      }
    });
  }
}

