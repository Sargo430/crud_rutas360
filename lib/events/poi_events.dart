

import 'package:crud_rutas360/models/poi_model.dart';

abstract class POIEvent {}

class LoadPOIs extends POIEvent {}

class AddPOI extends POIEvent {
  final String routeId;
  final POI poi;
  AddPOI(this.routeId, this.poi);
}
class UpdatePOI extends POIEvent {
  final String routeId;
  final POI poi;
  UpdatePOI(this.routeId, this.poi);
}
class DeletePOI extends POIEvent {
  final String routeId;
  final String poiId;
  DeletePOI(this.routeId, this.poiId);
}

class POIError extends POIEvent {
  final String message;

  POIError(this.message);
}
class SelectPOI extends POIEvent {
  final String routeId;
  final POI? poi;
  SelectPOI({required this.routeId, this.poi});
}
