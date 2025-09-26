import 'package:crud_rutas360/models/poi_model.dart';
import 'package:crud_rutas360/models/route_model.dart';

abstract class RouteState{}

class RouteInitial extends RouteState{}

class RouteLoading extends RouteState{}

class RouteCreating extends RouteState{
  final List<POI> unasignedPOIs;
  RouteCreating(this.unasignedPOIs);
}

class RouteLoaded extends RouteState{
  final List<MapRoute> routes;
  RouteLoaded(this.routes);
}

class RouteOperationSuccess extends RouteState{
  final String message;
  RouteOperationSuccess(this.message);
}

class RouteError extends RouteState{
  final String error;
  RouteError(this.error);
}