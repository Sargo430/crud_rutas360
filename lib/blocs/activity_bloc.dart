

import 'package:crud_rutas360/events/activity_event.dart';
import 'package:crud_rutas360/states/activity_state.dart';
import 'package:crud_rutas360/services/firestore_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final FireStoreService fireStoreService;

  ActivityBloc(this.fireStoreService) : super(ActivityInitial()) {
    on<LoadActivities>((event, emit) async {
      emit(ActivityLoading());
      try {
        final activities = await fireStoreService.fetchAllActivities();
        emit(ActivityLoaded(activities));
      } catch (e) {
        emit(ActivityError(e.toString()));
      }
    });

    on<AddActivity>((event, emit) async {
      emit(ActivityLoading());
      try {
        await fireStoreService.addActivity(event.activity);
        emit(ActivityOperationSuccess("Actividad añadida con éxito"));
        add(LoadActivities());
      } catch (e) {
        emit(ActivityError(e.toString()));
      }
    });

    on<UpdateActivity>((event, emit) async {
      emit(ActivityLoading());
      try {
        await fireStoreService.updateActivity(event.activity);
        emit(ActivityOperationSuccess("Actividad actualizada con éxito"));
        add(LoadActivities());
      } catch (e) {
        emit(ActivityError(e.toString()));
      }
    });

    on<DeleteActivity>((event, emit) async {
      emit(ActivityLoading());
      try {
        await fireStoreService.deleteActivity(event.activityId);
        emit(ActivityOperationSuccess("Actividad eliminada con éxito"));
        add(LoadActivities());
      } catch (e) {
        emit(ActivityError(e.toString()));
      }
    },);
    on<SelectActivity>((event, emit) {
      emit(ActivityFormState(activity: event.activity));
    });
  }
}