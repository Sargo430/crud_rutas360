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
  PoiFormState({this.poi});

  PoiFormState copyWith({POI? poi}) {
    return PoiFormState(poi: poi ?? this.poi);
  }
}
