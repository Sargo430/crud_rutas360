import 'package:crud_rutas360/models/activity_model.dart';

abstract class ActivityState {}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<Activity> activities;
  ActivityLoaded(this.activities);
}

class ActivityLoadedWithSuccess extends ActivityLoaded {
  final String message;
  ActivityLoadedWithSuccess(List<Activity> activities, this.message)
      : super(activities);
}

class ActivityOperationSuccess extends ActivityState {
  final String message;
  ActivityOperationSuccess(this.message);
}

class ActivityError extends ActivityState {
  final String error;
  ActivityError(this.error);
}

class ActivityFormState extends ActivityState {
  final Activity? activity;
  ActivityFormState({this.activity});

  ActivityFormState copyWith({Activity? activity}) {
    return ActivityFormState(activity: activity ?? this.activity);
  }
}
