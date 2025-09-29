
import 'package:crud_rutas360/models/category_model.dart';

abstract class CategoryEvent{}

class LoadCategories extends CategoryEvent{}


class AddCategory extends CategoryEvent{
  final PoiCategory category;
  AddCategory(this.category);
}
class UpdateCategory extends CategoryEvent{
  final PoiCategory category;
  UpdateCategory(this.category);
}
class DeleteCategory extends CategoryEvent{
  final String categoryId;
  DeleteCategory(this.categoryId);
}
class SelectCategory extends CategoryEvent{
  final PoiCategory? category;
  SelectCategory({this.category});
}