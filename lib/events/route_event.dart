import 'package:crud_rutas360/models/route_model.dart';

abstract class RouteEvent{}

class LoadRoute extends RouteEvent{}

class AddRoute extends RouteEvent{
  final MapRoute route;
  AddRoute(this.route);
}

class UpdateRoute extends RouteEvent{
  final MapRoute route;
  UpdateRoute(this.route);
}

class DeleteRoute extends RouteEvent{
  final String routeId;
  DeleteRoute(this.routeId);
}