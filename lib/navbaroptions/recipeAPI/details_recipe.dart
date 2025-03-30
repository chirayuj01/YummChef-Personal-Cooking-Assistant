import 'dart:convert';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html/parser.dart' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/MongoDB/MongoDb.dart';
import 'package:recipe_app/Provider/useraccess.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';

class DetailsScreen extends StatefulWidget {
  var index;
  final String dishname;
  DetailsScreen({required this.dishname, this.index});
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int playingindex = 0;
  bool isSpeaking = false;
  GoogleTranslator translator = GoogleTranslator();
  String language = 'en-US';
  bool isplaying = false;
  double speed = 0.5;
  FlutterTts _flutterTts = FlutterTts();

  bool issaved=false;
  var ingredients = [];
  var details = [];
  var recipeSteps = [];

  List<dynamic> ischecked = [];
  double rating = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchdetails();
      checksavedrecipe();
    });
    initTTS();
  }

  void initTTS() {
    _flutterTts.setLanguage(language);
    _flutterTts.setSpeechRate(speed);
  }

  checksavedrecipe() {
    String key = 'a4de1b62137f4b4bb8901346c70805ef';
    String url =
        'https://api.spoonacular.com/recipes/complexSearch?query=${widget.dishname}&apiKey=${key}&addRecipeNutrition=true';
    var instance = Provider.of<UserDetails>(context, listen: false);
    if (instance.savedrecipes.contains(url))
      issaved = true;
    else
      issaved = false;
    print(instance.email);
  }

  fetchRecipeSteps(int recipeId) async {
    String apiKey = 'a4de1b62137f4b4bb8901346c70805ef';
    String url =
        'https://api.spoonacular.com/recipes/$recipeId/analyzedInstructions?apiKey=$apiKey';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          recipeSteps = data.isNotEmpty ? data[0]['steps'] : [];
          ischecked = List.filled(recipeSteps.length, false);
        });
      } else {
        throw Exception('Failed to load recipe steps');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error : ${e.toString()}')));
    }
  }

  fetchdetails() async {
    String apiKey = 'a4de1b62137f4b4bb8901346c70805ef';
    String dish = widget.dishname;
    String url =
        'https://api.spoonacular.com/recipes/complexSearch?query=${dish}&apiKey=${apiKey}&addRecipeNutrition=true';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          details = data['results'] ?? [];
          if (details.isNotEmpty) {
            if (details[0].containsKey('spoonacularScore')) {
              rating = (details[0]['spoonacularScore'] as num).toDouble();
              rating = (rating / 100) * 5;
            }
            fetchIngredients(details[0]['id']);
            fetchRecipeSteps(details[0]['id']);
          }
        });
      } else {
        throw Exception('Failed to load meal data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error : ${e.toString()}')));
    }
  }

  fetchIngredients(int recipeId) async {
    String apiKey = 'a4de1b62137f4b4bb8901346c70805ef';
    String url =
        'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=$apiKey&includeNutrition=true';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          ingredients = data['extendedIngredients'] ?? [];
        });
      } else {
        throw Exception('Failed to load ingredients');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error : ${e.toString()}')));
    }
  }

  String cleanSummary(String summary) {
    var document = html.parse(summary);
    String plainText = document.body?.text ?? '';

    plainText = plainText
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#39;'), "'");

    plainText = plainText.replaceAll(RegExp(r'http\S+'), '[Link removed]');
    return plainText;
  }

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<UserDetails>(context, listen: false);
    addrecipe() async {
      String key = 'a4de1b62137f4b4bb8901346c70805ef';
      String email = instance.email;
      String url =
          'https://api.spoonacular.com/recipes/complexSearch?query=${widget.dishname}&apiKey=${key}&addRecipeNutrition=true';
      if (instance.savedrecipes.contains(url) == false) instance.addRecipe(url);
      print(instance.savedrecipes.toString());
      await MongoDatabase.collection.updateOne(
        {'user-id': email},
        {
          '\$addToSet': {'recipes': url}
        },
        upsert: true,
      );
      print(MongoDatabase.collection.find().toString());
    }

    removerecipe() async {
      String key = 'a4de1b62137f4b4bb8901346c70805ef';
      String email = instance.email;
      String url =
          'https://api.spoonacular.com/recipes/complexSearch?query=${widget.dishname}&apiKey=${key}&addRecipeNutrition=true';
      instance.removeRecipe(url);
      print(instance.savedrecipes.toString());
      await MongoDatabase.collection.updateOne(
        {'user-id': email},
        {
          '\$pull': {'recipes': url}
        },
      );
    }

    return SafeArea(child: LayoutBuilder(builder: (context, constraints) {
      double h = constraints.maxHeight;
      double w = constraints.maxHeight;
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                issaved = !issaved;
                SnackBar message;
                if (issaved == true) {
                  addrecipe();
                  message = const SnackBar(
                    content: Text('Recipe saved successfully',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    backgroundColor: Colors.teal,
                    duration: Duration(seconds: 2),
                  );
                } else {
                  removerecipe();
                  message = const SnackBar(
                    content: Text(
                      'Recipe unsaved successfully',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    backgroundColor: Colors.white,
                    dismissDirection: DismissDirection.horizontal,
                    duration: Duration(seconds: 2),
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(message);
              });
            },
            backgroundColor: Colors.white,
            shape: CircleBorder(side: BorderSide(color: Colors.teal, width: 4)),
            child: issaved == false
                ? Icon(Icons.bookmark_border, size: 40, weight: 10)
                : const Icon(
                    Icons.bookmark,
                    size: 40,
                    weight: 10,
                    color: Colors.teal,
                  ),
          ),
        ),
        backgroundColor: Colors.black,
        body: DefaultTabController(
          length: 2,
          child: details.isEmpty
              ? Center(
                child: Container(
                  height: 200,
                  width: 200,
                  child:
                      Lottie.asset('assets/loadinganimation/recipe.json'),
                ),
              )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(21)),
                            height: h * 0.35,
                            width: double.infinity,
                            child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(21),
                                    bottomLeft: Radius.circular(21)),
                                child: Image.network(details[0]['image'],
                                    fit: BoxFit.fill)),
                          ),
                          Positioned(
                            top: h * 0.01,
                            left: w * 0.02,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: CircleAvatar(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.arrow_back_ios_new,
                                    size: 30, weight: 40),
                                radius: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                                height: 3,
                                width: w * 0.25,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.01),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            SizedBox(width: w * 0.01),
                            Container(
                              width: 380,
                              child: Text(
                                '${details[0]['title']}',
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time, color: Colors.blue),
                              SizedBox(
                                height: 4,
                              ),
                              Text('${details[0]['readyInMinutes']} mins',
                                  style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.local_fire_department,
                                  color: Colors.orange),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                '${details[0]['nutrition']['nutrients'][0]['amount']} Kcal',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              SizedBox(
                                height: 4,
                              ),
                              Text('${rating.toStringAsFixed(1)}/5',
                                  style: TextStyle(color: Colors.white70)),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: w * 0.01, top: 20, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(' Description',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontSize: 23)),
                            SizedBox(
                              height: h * 0.01,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: (context),
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor:
                                            Colors.white.withOpacity(1),
                                        title: Center(
                                            child: Text(
                                          'Description',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins'),
                                        )),
                                        content: Text(
                                          cleanSummary(
                                              details[0]['summary'].toString()),
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      );
                                    });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(11)),
                                height: h * 0.16,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cleanSummary(
                                            details[0]['summary'].toString()),
                                        maxLines: 4,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        '... Click here for full description',
                                        style: TextStyle(
                                            color:
                                                Colors.white70.withOpacity(0.6),
                                            fontSize: 15),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: h * 0.01, left: w * 0.01),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Ingredients ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontSize: 23,
                                        ),
                                      ),
                                      Text(
                                        '(Servings: ${details[0]['servings']})',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontFamily: 'Poppins',
                                            fontSize: 20),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.01,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: ingredients.isEmpty
                                      ? Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.orange),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: ingredients.length,
                                          itemBuilder: (context, index) {
                                            final ingredient =
                                                ingredients[index];
                                            final String imageUrl =
                                                'https://spoonacular.com/cdn/ingredients_100x100/${ingredient['image']}';

                                            return Card(
                                              color:
                                                  Colors.white.withOpacity(0.1),
                                              child: ListTile(
                                                minTileHeight: 70,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: w * 0.01),
                                                selectedColor: Colors.white70,
                                                leading: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: w * 0.06,
                                                    height: h * 0.06,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                title: Text(
                                                  '${ingredient['name']}',
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                trailing: Text(
                                                  '${ingredient['amount'].toStringAsFixed(1)} ${ingredient['unit']}',
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: w * 0.01,
                                      top: h * 0.02,
                                      right: w * 0.01),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Recipe ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontSize: 25,
                                        ),
                                      ),
                                      SizedBox(
                                        width: w * 0.015,
                                      ),
                                      if (isplaying == false) Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(27),
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 2)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: AnimationLimiter(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: List.generate(
                                                1,
                                                    (index) => AnimationConfiguration.staggeredList(
                                                  position: index,
                                                  duration: const Duration(milliseconds: 500),
                                                  child: FadeInAnimation(
                                                    child: Column(
                                                      children: [
                                                        AnimatedButton(
                                                          height: h * 0.06,
                                                          width: w * 0.2,
                                                          animatedOn: AnimatedOn.onTap,
                                                          transitionType: TransitionType.LEFT_TO_RIGHT,
                                                          selectedBackgroundColor: Colors.teal,
                                                          backgroundColor: Colors.white,
                                                          selectedTextColor: Colors.white,
                                                          borderColor: Colors.teal,
                                                          borderWidth: 3,
                                                          borderRadius: 21,
                                                          animationDuration: const Duration(seconds: 1),
                                                          isReverse: true,
                                                          textStyle: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'Poppins',
                                                          ),
                                                          text: isplaying ? 'Read Mode' : 'Voice Mode',
                                                          onPress: () async {
                                                            setState(() => isplaying = !isplaying);
                                                            if (isplaying) {
                                                              isSpeaking = false;
                                                            } else {
                                                              await _flutterTts.stop();
                                                              isSpeaking = false;
                                                            }
                                                            setState(() {});
                                                          },
                                                        ),
                                                        if (isplaying) SizedBox(height: h * 0.01),

                                                        if (isplaying)
                                                          FadeInAnimation(
                                                            child: Column(
                                                              children: [
                                                                Text('Speed: ${speed.toStringAsFixed(1)}x',
                                                                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                                                Slider(
                                                                  activeColor: Colors.orange,
                                                                  secondaryActiveColor: Colors.teal,
                                                                  value: speed,
                                                                  min: 0.0,
                                                                  max: 1.0,
                                                                  divisions: 10,
                                                                  label: '${speed.toStringAsFixed(1)}x',
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      speed = value;
                                                                      _flutterTts.setSpeechRate(speed);
                                                                    });
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                        if (isplaying)
                                                          FadeInAnimation(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    if (playingindex > 0) {
                                                                      playingindex--;
                                                                    } else {
                                                                      playingindex = 0;
                                                                    }
                                                                    isSpeaking = false;
                                                                    setState(() {});
                                                                  },
                                                                  child: Column(
                                                                    children: [
                                                                      CircleAvatar(
                                                                        backgroundColor: Colors.white,
                                                                        child: Icon(Icons.skip_previous, size: w * 0.05),
                                                                      ),
                                                                      SizedBox(height: h * 0.01),
                                                                      const Text('Previous', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () async {
                                                                    if (isSpeaking) {
                                                                      await _flutterTts.pause();
                                                                    } else {
                                                                      await _flutterTts.setSpeechRate(speed);
                                                                      await _flutterTts.speak(recipeSteps[playingindex]['step']);
                                                                    }
                                                                    setState(() => isSpeaking = !isSpeaking);
                                                                    _flutterTts.setCompletionHandler(() {
                                                                      isSpeaking = false;
                                                                      setState(() {});
                                                                    });
                                                                  },
                                                                  child: Column(
                                                                    children: [
                                                                      CircleAvatar(
                                                                        backgroundColor: Colors.white,
                                                                        child: FaIcon(
                                                                          isSpeaking ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: h * 0.01),
                                                                      Text(
                                                                        isSpeaking ? 'Pause' : 'Play',
                                                                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    if (playingindex < recipeSteps.length - 1) {
                                                                      playingindex++;
                                                                    } else {
                                                                      playingindex = 0;
                                                                    }
                                                                    isSpeaking = false;
                                                                    setState(() {});
                                                                  },
                                                                  child: Column(
                                                                    children: [
                                                                      CircleAvatar(
                                                                        backgroundColor: Colors.white,
                                                                        child: Icon(Icons.skip_next, size: w * 0.05),
                                                                      ),
                                                                      SizedBox(height: h * 0.01),
                                                                      const Text('Next', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    playingindex = 0;
                                                                    isSpeaking = false;
                                                                    setState(() {});
                                                                  },
                                                                  child: Column(
                                                                    children: [
                                                                      CircleAvatar(
                                                                        backgroundColor: Colors.white,
                                                                        child: Icon(Icons.restart_alt, size: w * 0.04),
                                                                      ),
                                                                      SizedBox(height: h * 0.01),
                                                                      const Text('Restart', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          ,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: w * 0.01),
                                  child: recipeSteps.isEmpty
                                      ? Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.orange,
                                          ),
                                        )
                                      : recipeSteps == null
                                          ? Center(
                                              child: Text(
                                                'No recipe found',
                                                style: TextStyle(
                                                    color: Colors.white70),
                                              ),
                                            )
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: recipeSteps.length,
                                              itemBuilder: (context, index) {
                                                final step = recipeSteps[index];
                                                return index !=
                                                        recipeSteps.length - 1
                                                    ? Column(
                                                        children: [
                                                          Card(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.1),
                                                            child: ListTile(
                                                              leading:
                                                                  CircleAvatar(
                                                                      backgroundColor: ischecked[index] ==
                                                                              true
                                                                          ? Colors
                                                                              .orange
                                                                          : Colors
                                                                              .white,
                                                                      child: Checkbox(
                                                                          shape: CircleBorder(),
                                                                          activeColor: ischecked[index] == true ? Colors.orange : Colors.white,
                                                                          value: ischecked[index],
                                                                          onChanged: (val) {
                                                                            ischecked[index] =
                                                                                val;
                                                                            setState(() {});
                                                                          })),
                                                              title: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                  step['step'],
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: h * 0.02,
                                                            width: 2,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      )
                                                    : Column(
                                                        children: [
                                                          Card(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.1),
                                                            child: ListTile(
                                                              leading:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    ischecked[index] ==
                                                                            true
                                                                        ? Colors
                                                                            .orange
                                                                        : Colors
                                                                            .white,
                                                                child: Checkbox(
                                                                    activeColor: ischecked[index] ==
                                                                            true
                                                                        ? Colors
                                                                            .orange
                                                                        : Colors
                                                                            .white,
                                                                    shape:
                                                                        CircleBorder(),
                                                                    value: ischecked[
                                                                        index],
                                                                    onChanged:
                                                                        (val) {
                                                                      ischecked[
                                                                              index] =
                                                                          val;
                                                                      setState(
                                                                          () {});
                                                                    }),
                                                              ),
                                                              title: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                  step['step'],
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: h * 0.01,
                                                          ),
                                                          ischecked.every(
                                                                  (element) =>
                                                                      element)
                                                              ? Container(
                                                                  width: double
                                                                      .infinity,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              16),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .teal,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child:
                                                                      const Text(
                                                                    'WooHoo meal is Ready !!',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14.7,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          'Poppins',
                                                                      color: Colors
                                                                          .white,
                                                                      letterSpacing:
                                                                          1.2,
                                                                      // Center the text
                                                                    ),
                                                                  ),
                                                                )
                                                              : SizedBox(),
                                                          SizedBox(
                                                            height: h * 0.01,
                                                          )
                                                        ],
                                                      );
                                              },
                                            ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }));
  }
}
