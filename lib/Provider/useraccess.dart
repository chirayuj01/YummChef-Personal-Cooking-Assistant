import 'package:flutter/cupertino.dart';

class UserDetails extends ChangeNotifier{
  String email='';
  var savedrecipes=[];
  updateemail(String emailID){
    email=emailID;
    notifyListeners();
  }
  addRecipe(String url){
    savedrecipes.add(url);
    notifyListeners();
  }
  removeRecipe(String url){
    savedrecipes.remove(url);
    notifyListeners();
  }
  clearlist(){
    savedrecipes.clear();
    notifyListeners();
  }
  updateRecipes(List<String> recipes){
    savedrecipes=recipes;
    notifyListeners();
  }
}