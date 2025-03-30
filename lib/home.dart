import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/navbaroptions/SavedRecipes.dart';
import 'package:recipe_app/navbaroptions/SearchRecipes.dart';
import 'package:recipe_app/navbaroptions/home_screen.dart';

import 'navbaroptions/GeminiAI/RecipegeneratorAI.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedindex=0;
  var pages=[
    HomeScreen(),
    SearchRecipe(),
    SavedRecipePage(),
    RecipeGenerator()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.black,
          height: 60,
          color: Colors.white,
          animationCurve: Curves.decelerate,
          index: 0,
          onTap: (index){
            setState(() {
              _selectedindex=index;
            });
          },
          items: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home,size: 37,),
            if(_selectedindex!=0) Text('Home',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search,size: 37,),
            if(_selectedindex!=1) Text('Search',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_rounded,size: 37,),
            if(_selectedindex!=2) Text('Saved',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/ai.png',height: 37,width: 37,color: Colors.black,),
            if(_selectedindex!=3) Text('AI',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
          ],
        )
      ]),
      body: pages[_selectedindex],
    );
  }
}
