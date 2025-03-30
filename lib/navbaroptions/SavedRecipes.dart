import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:recipe_app/Provider/useraccess.dart';
import 'package:recipe_app/navbaroptions/recipeAPI/details_recipe.dart';
import 'package:shimmer/shimmer.dart';

class SavedRecipePage extends StatefulWidget {
  const SavedRecipePage({super.key});

  @override
  State<SavedRecipePage> createState() => _SavedRecipePageState();
}

class _SavedRecipePageState extends State<SavedRecipePage> {
  List<Map<String, dynamic>> savedRecipes = [];

  @override
  void initState() {
    super.initState();
    loadSavedRecipes();
  }

  Future<void> loadSavedRecipes() async {
    var instance = Provider.of<UserDetails>(context, listen: false);
    var savedList = instance.savedrecipes;

    try {
      List<Future<http.Response>> fetchRequests =
      savedList.map((url) => http.get(Uri.parse(url))).toList();

      List<http.Response> responses = await Future.wait(fetchRequests);

      List<Map<String, dynamic>> tempRecipes = responses
          .where((res) => res.statusCode == 200)
          .map((res) => json.decode(res.body) as Map<String, dynamic>)
          .toList();

      if (mounted) {
        setState(() {
          savedRecipes = tempRecipes.reversed.toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await loadSavedRecipes();
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = constraints.maxWidth;
                double maxHeight = constraints.maxHeight;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Saved Recipes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 30,
                            fontFamily: 'Poppins',
                            letterSpacing: -1.5,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      endIndent: 5,
                      indent: 5,
                      color: Colors.white70,
                      thickness: 1.5,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: savedRecipes.isEmpty
                          ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.orange,
                        ),
                      )
                          : AnimationLimiter(
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: savedRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = savedRecipes[index]['results'][0];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(seconds: 2),
                              child: SlideAnimation(
                                horizontalOffset: maxWidth * 0.2,
                                child: FadeInAnimation(
                                  delay: Duration(seconds: 1),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailsScreen(
                                                dishname: recipe['title'],
                                                index: index,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin:
                                      EdgeInsets.all(maxWidth * 0.02),
                                      child: Card(
                                        key: Key('$index'),
                                        color: Colors.white
                                            .withOpacity(0.13),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              maxWidth * 0.04),
                                        ),
                                        elevation: 4,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.vertical(
                                                top: Radius.circular(
                                                    maxWidth * 0.04),
                                              ),
                                              child:
                                              recipe['image'] != null
                                                  ? Image.network(
                                                recipe['image'],
                                                width: double
                                                    .infinity,
                                                height:
                                                maxHeight *
                                                    0.25,
                                                fit: BoxFit
                                                    .cover,
                                              )
                                                  : Container(
                                                height:
                                                maxHeight *
                                                    0.25,
                                                color:
                                                Colors.grey,
                                                child: Icon(
                                                    Icons
                                                        .fastfood,
                                                    size:
                                                    maxWidth *
                                                        0.1,
                                                    color: Colors
                                                        .white70),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(
                                                  maxWidth * 0.03),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    recipe['title'] ??
                                                        'N/A',
                                                    style: TextStyle(
                                                        fontSize:
                                                        maxWidth *
                                                            0.05,
                                                        color:
                                                        Colors.white,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                    maxLines: 1,
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  maxWidth *
                                                      0.03,
                                                  vertical: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  _buildMealInfoRow(Icons.favorite_sharp, Colors.red, recipe['aggregateLikes'] != null ? '${recipe['aggregateLikes']} people loved it' : null, maxWidth),
                                                  _buildMealInfoRow(Icons.local_fire_department, Colors.orange, recipe['nutrition'] != null ? '${recipe['nutrition']['nutrients'][0]['amount']} kcal' : null, maxWidth),
                                                  _buildMealInfoRow(Icons.access_time, Colors.blue, recipe['readyInMinutes'] != null ? '${recipe['readyInMinutes']} mins' : null, maxWidth),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ].animate().fade(duration: 100.ms).scale(delay: 100.ms),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealInfoRow(IconData icon, Color color, String? text, double maxWidth) {
    return text != null
        ? Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 12),
        Text(text, style: TextStyle(color: Colors.white70)),
      ],
    )
        : Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 20,
        width: maxWidth * 0.3,
        color: Colors.grey[300],
      ),
    );
  }
}