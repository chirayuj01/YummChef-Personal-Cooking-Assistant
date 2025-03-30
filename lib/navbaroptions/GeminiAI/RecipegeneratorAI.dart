import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:lottie/lottie.dart';

class RecipeGenerator extends StatefulWidget {
  const RecipeGenerator({super.key});

  @override
  State<RecipeGenerator> createState() => _RecipeGeneratorState();
}

class _RecipeGeneratorState extends State<RecipeGenerator> {
  bool isloading = false;
  var gemini = Gemini.instance;
  String reciperesponse = "";
  TextEditingController tagController = TextEditingController();
  var random = Random();
  List<String> tagsList = [];

  void _removeTag(int index) {
    setState(() {
      tagsList.removeAt(index);
      if (tagsList.isEmpty) {
        reciperesponse = "";
      }
    });
  }

  Color _getRandomLightColor() {
    return Color.fromRGBO(
      random.nextInt(156) + 100,
      random.nextInt(156) + 100,
      random.nextInt(156) + 100,
      1,
    );
  }

  generateRecipe() {
    setState(() {
      isloading = true;
    });
    if (tagsList.isEmpty) {
      setState(() {
        isloading = false;
        return;
      });
    }
    String prompt =
        "Generate a recipe using these ingredients: ${tagsList.join(", ")} and formatted properly and everything text fontweight is normal no text bold. and structure should be like recipe name then nutrients data then ingredients then servings then recipe points number wise and equally spaced all. If the ingredients entered by user is not related to food category then simply return invalid ingredients entered,please enter valid ingredients";

    gemini.prompt(parts: [
      Part.text(prompt),
    ]).then((value) {
      setState(() {
        isloading = false;
        reciperesponse = value?.output ?? "";
      });
      print(reciperesponse);
    }).catchError((e) {
      setState(() {
        isloading = false;
        reciperesponse = 'error generating recipe';
      });
    });
  }

  @override
  void initState() {
    super.initState();
    tagsList.clear();
  }

  @override
  void dispose() {
    super.dispose();
    tagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double h = constraints.maxHeight;
            double w = constraints.maxWidth;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Create recipe that satisfy your cravings!!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextField(
                            controller: tagController,
                            cursorColor: Colors.white,
                            cursorOpacityAnimates: true,
                            keyboardAppearance: Brightness.light,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelStyle: TextStyle(color: Colors.white70),
                              labelText: 'Enter the ingredients ....',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                                borderSide: BorderSide(
                                  color: Colors.tealAccent,
                                  width: 2.0,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: w * 0.02),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (tagController.text.isNotEmpty &&
                                    !tagsList.contains(tagController.text)) {
                                  tagsList.add(tagController.text);
                                }
                                tagController.clear();
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: Center(
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.006),
                  Wrap(
                    children: [
                      for (int i = 0; i < tagsList.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Chip(
                            label: Text(
                              tagsList[i],
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            backgroundColor: _getRandomLightColor(),
                            deleteIcon: Icon(
                              Icons.close_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                            onDeleted: () => _removeTag(i),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: h * 0.01),
                  Expanded(
                    child: SingleChildScrollView(
                      child: tagsList.isEmpty
                          ? null
                          : Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            color: Colors.white.withOpacity(0.2)),
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        child: isloading == true
                            ? Center(
                          child: Container(
                            height: h * 0.7,
                            width: 200,
                            child: Lottie.asset(
                                'assets/loadinganimation/recipe.json'),
                          ),
                        )
                            : Center(
                          child: AnimatedTextKit(
                              displayFullTextOnTap: true,
                              isRepeatingAnimation: false,
                              animatedTexts: [
                                TypewriterAnimatedText(
                                    speed:
                                    Duration(milliseconds: 10),
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins'),
                                    reciperesponse),
                              ]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  AnimatedButton(
                    animatedOn: AnimatedOn.onTap,
                    transitionType: TransitionType.CENTER_ROUNDER,
                    selectedBackgroundColor: Colors.teal,
                    backgroundColor: Colors.white,
                    selectedTextColor: Colors.white,
                    borderColor: Colors.teal,
                    borderWidth: 5,
                    borderRadius: 11,
                    animationDuration: Duration(seconds: 1),
                    height: 60,
                    isReverse: true,
                    width: double.infinity,
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    text: 'Create Recipe',
                    onPress: () => generateRecipe(),
                  ),
                  SizedBox(height: h * 0.02),
                ].animate().fade(duration: 100.ms).scale(delay: 100.ms),
              ),
            );
          },
        ),
      ),
    );
  }
}