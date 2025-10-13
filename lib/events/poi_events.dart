




import 'package:crud_rutas360/models/poi_model.dart';
import 'package:file_picker/file_picker.dart';

abstract class POIEvent {}

class LoadPOIs extends POIEvent {}

class AddPOI extends POIEvent {
  final POI poi;
  final PlatformFile image;
  final Map<String, PlatformFile?>? new360Views;
  AddPOI(this.poi, this.image, this.new360Views);
}


class UpdatePOI extends POIEvent {
  final POI poi;
  final PlatformFile? image;
  final Map<String, PlatformFile?>? new360Views;
  UpdatePOI(this.poi, {this.image, this.new360Views});
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

