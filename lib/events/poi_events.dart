

import 'package:crud_rutas360/models/poi_model.dart';

abstract class POIEvent {}

class LoadPOIs extends POIEvent {}

class AddPOI extends POIEvent {
  final POI poi;
  AddPOI(this.poi);
}
class UpdatePOI extends POIEvent {
  final POI poi;
  UpdatePOI(this.poi);
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
  final POI? poi;
  SelectPOI({this.poi});
}

