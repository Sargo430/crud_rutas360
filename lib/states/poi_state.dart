import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';
import 'package:crud_rutas360/models/poi_model.dart';

abstract class PoiState {}

class PoiInitial extends PoiState {}

class PoiLoading extends PoiState {}

class PoiLoaded extends PoiState {
  final List<POI> pois;
  PoiLoaded(this.pois);
}



class PoiOperationSuccess extends PoiState {
  final String message;
  PoiOperationSuccess(this.message);
}

class PoiError extends PoiState {
  final String error;
  PoiError(this.error);
}

class PoiFormState extends PoiState {
  final POI? poi;
  final List<PoiCategory> categories;
  final List<Activity> activities;
  PoiFormState({this.poi, required this.categories, required this.activities});

  PoiFormState copyWith({POI? poi, List<PoiCategory>? categories, List<Activity>? activities}) {
    return PoiFormState(
      poi: poi ?? this.poi,
      categories: categories ?? this.categories,
      activities: activities ?? this.activities,
    );
  }
}
