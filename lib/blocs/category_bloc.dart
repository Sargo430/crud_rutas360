
import 'package:crud_rutas360/services/firestore_service.dart';
import 'package:crud_rutas360/states/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crud_rutas360/events/category_event.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final FireStoreService fireStoreService;

  CategoryBloc(this.fireStoreService) : super(CategoryInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await fireStoreService.fetchCategories();
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<AddCategory>((event, emit) async {
      emit(CategoryLoading());
      try {
        await fireStoreService.addCategory(event.category);
        emit(CategoryOperationSuccess("Categoría añadida con éxito"));
        add(LoadCategories());
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<UpdateCategory>((event, emit) async {
      emit(CategoryLoading());
      try {
        await fireStoreService.updateCategory(event.category);
        emit(CategoryOperationSuccess("Categoría actualizada con éxito"));
        add(LoadCategories());
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<DeleteCategory>((event, emit) async {
      emit(CategoryLoading());
      try {
        await fireStoreService.deleteCategory(event.categoryId);
        emit(CategoryOperationSuccess("Categoría eliminada con éxito"));
        add(LoadCategories());
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    },);
    on<SelectCategory>((event, emit) {
      emit(CategoryFormState(category: event.category));
    });
  }
}

