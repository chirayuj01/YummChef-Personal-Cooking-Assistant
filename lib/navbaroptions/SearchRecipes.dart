import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:recipe_app/navbaroptions/recipeAPI/details_recipe.dart';
import 'package:recipe_app/onBoarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

class SearchRecipe extends StatefulWidget {
  const SearchRecipe({super.key});

  @override
  State<SearchRecipe> createState() => _SearchRecipeState();
}

class _SearchRecipeState extends State<SearchRecipe> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  searchRecipes(String query) async {
    if (query.isEmpty) return;
    setState(() => isLoading = true);

    const apiKey = 'a4de1b62137f4b4bb8901346c70805ef';
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?query=$query&apiKey=$apiKey&number=40&addRecipeNutrition=true');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = List<Map<String, dynamic>>.from(data['results'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load recipe data');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            double maxHeight = constraints.maxHeight;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(maxWidth * 0.0001),
                    child: Container(
                        height: 120,
                        width: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(21),
                            child: Image.asset(
                              'assets/images/logoi.png',
                              fit: BoxFit.cover,
                              color: Colors.white,
                            ))),
                  ),
                  SizedBox(height: maxHeight * 0.001),
                  TextField(
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a recipe...',
                      hintStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(maxWidth * 0.07),
                          borderSide:
                          BorderSide(color: Colors.orange, width: 2)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(maxWidth * 0.07),
                          borderSide: BorderSide(color: Colors.white, width: 2)),
                      suffixIcon: Icon(Icons.search, color: Colors.white),
                    ),
                    onChanged: searchRecipes,
                  ),
                  SizedBox(height: maxHeight * 0.03),
                  isLoading
                      ? Expanded(
                    child: Center(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Lottie.asset(
                            'assets/loadinganimation/recipe.json'),
                      ),
                    ),
                  )
                      : Expanded(
                    child: _searchController.text.isEmpty
                        ? Center(
                      child: Text('Search for dishes',
                          style: TextStyle(color: Colors.white)),
                    )
                        : searchResults.isEmpty
                        ? Center(
                      child: Text('No results found',
                          style:
                          TextStyle(color: Colors.white)),
                    )
                        : AnimationLimiter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: maxHeight * 0.02),
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final recipe = searchResults[index];
                            return AnimationConfiguration
                                .staggeredList(
                              position: index,
                              duration: Duration(seconds: 1),
                              delay: Duration(seconds: 1),
                              child: SlideAnimation(
                                horizontalOffset: 50,
                                child: FadeInAnimation(
                                  delay: Duration(seconds: 1),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailsScreen(
                                                dishname:
                                                recipe['title'],
                                                index: index,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(
                                          maxWidth * 0.02),
                                      child: Card(
                                        key: Key('$index'),
                                        color: Colors.white
                                            .withOpacity(0.13),
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                              maxWidth *
                                                  0.04),
                                        ),
                                        elevation: 4,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius
                                                  .vertical(
                                                top: Radius
                                                    .circular(
                                                    maxWidth *
                                                        0.04),
                                              ),
                                              child: recipe[
                                              'image'] !=
                                                  null
                                                  ? Image.network(
                                                recipe[
                                                'image'],
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
                                                color: Colors
                                                    .grey,
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
                                              padding:
                                              EdgeInsets.all(
                                                  maxWidth *
                                                      0.03),
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
                                                        color: Colors
                                                            .white,
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
                                                  vertical:
                                                  8),
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
                  ),
                ].animate()
                    .fade(duration: 100.ms)
                    .scale(delay: 100.ms),
              ),
            );
          },
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