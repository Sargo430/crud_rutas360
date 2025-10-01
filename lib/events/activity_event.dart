import 'package:crud_rutas360/models/activity_model.dart';

abstract class ActivityEvent{}

class LoadActivities extends ActivityEvent{}


class AddActivity extends ActivityEvent{
  final Activity activity;
  AddActivity(this.activity);
}
class UpdateActivity extends ActivityEvent{
  final Activity activity;
  UpdateActivity(this.activity);
}
class DeleteActivity extends ActivityEvent{
  final String activityId;
  DeleteActivity(this.activityId);
}
class SelectActivity extends ActivityEvent{
  final Activity? activity;
  SelectActivity({this.activity});
}