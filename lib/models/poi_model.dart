import 'package:crud_rutas360/models/activity_model.dart';
import 'package:crud_rutas360/models/category_model.dart';

class POI  {
  final String id;
  final String? routeId;
  final String? routeName;
  final String nombre;
  final Map<String, dynamic> descripcion;
  final String imagen;
  final double latitud;
  final double longitud;
  final List<PoiCategory> categorias;
  final List<Activity> actividades;
  final Map<String, dynamic> vistas360;


  POI({
    required this.id,
    this.routeId,
    this.routeName,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.latitud,
    required this.longitud,
    required this.categorias,
    required this.actividades,
    required this.vistas360,

  });
}