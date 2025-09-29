
import 'package:crud_rutas360/models/category_model.dart';


abstract class CategoryState{}

class CategoryInitial extends CategoryState{}

class CategoryLoading extends CategoryState{}

class CategoryLoaded extends CategoryState{
  final List<PoiCategory> categories;
  CategoryLoaded(this.categories);
}

class CategoryOperationSuccess extends CategoryState{
  final String message;
  CategoryOperationSuccess(this.message);
}

class CategoryError extends CategoryState{
  final String error;
  CategoryError(this.error);
}
  class CategoryFormState extends CategoryState{
    final PoiCategory? category;
    CategoryFormState({this.category});

CategoryFormState copyWith({PoiCategory? category}){
  return CategoryFormState(
    category: category ?? this.category,
  );
}
}