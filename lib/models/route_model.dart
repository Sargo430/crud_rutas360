import 'package:crud_rutas360/models/poi_model.dart';
import 'package:latlong2/latlong.dart';

class MapRoute{
  final String id;
  final double initialLatitude;
  final double initialLongitude;
  final double finalLatitude;
  final double finalLongitude;
  final String name;
  final List<POI> pois;
  final List<LatLng> geometry;
  MapRoute({
    required this.id,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.finalLatitude,
    required this.finalLongitude,
    required this.name,
    required this.pois,
    required this.geometry,
  });
}