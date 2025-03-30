import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_app/navbaroptions/recipeAPI/details_recipe.dart';

class MealDetailsTab extends StatefulWidget {
  final String mealType;

  const MealDetailsTab({Key? key, required this.mealType}) : super(key: key);

  @override
  State<MealDetailsTab> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsTab> {
  int limit = 10;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> mealList = [];
  bool isLoading = true;
  bool isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    fetchMealDetails();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchMealDetails() async {
    const apiKey = 'a4de1b62137f4b4bb8901346c70805ef';
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?type=${widget.mealType}&apiKey=$apiKey&addRecipeNutrition=true&number=$limit');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mealList = List<Map<String, dynamic>>.from(data['results'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load meal data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text('No internet connection')
        ),
      );
    }
  }

  Future<void> fetchMoreMeals() async {
    if (isFetchingMore) return;

    setState(() {
      isFetchingMore = true;
      limit += 10;
    });

    await fetchMealDetails();

    setState(() {
      isFetchingMore = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchMoreMeals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: Container(
              height: 200,
              width: 200,
              child: Lottie.asset('assets/loadinganimation/recipe.json'),
            ),
          )
        : mealList.isEmpty
            ? Center(
                child: Text(
                  'No recipes found for ${widget.mealType}',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification &&
                      _scrollController.position.pixels ==
                          _scrollController.position.maxScrollExtent) {
                    fetchMoreMeals();
                  }
                  return false;
                },
                child: LayoutBuilder(
                  builder: (context,constraints){
                    double width=constraints.maxWidth;
                    double height=constraints.maxHeight;
                    return ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: mealList.length,
                      itemBuilder: (context, index) {
                        final meal = mealList[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(seconds: 1),
                          child: SlideAnimation(
                            verticalOffset: 50,
                            child: FadeInAnimation(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsScreen(
                                        dishname: meal['title'],
                                        index: index,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: width*0.8,
                                  margin: const EdgeInsets.all(3),
                                  child: Card(
                                    key: Key('$index'),
                                    color: Colors.white.withOpacity(0.13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          child: meal['image'] != null
                                              ? Image.network(
                                            meal['image'],
                                            width: double.infinity,
                                            height: height*0.55,
                                            fit: BoxFit.fill,
                                          )
                                              : Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              height: height*0.55,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.fastfood,
                                                  size: 50),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              meal['title'] != null
                                                  ? Text(
                                                meal['title'],
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                TextOverflow.ellipsis,
                                              )
                                                  : Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                Colors.grey[100]!,
                                                child: Container(
                                                  height: 20,
                                                  width: double.infinity,
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  meal['aggregateLikes'] != null
                                                      ? Row(
                                                    children: [
                                                      Icon(
                                                        Icons.favorite_sharp,
                                                        color: Colors.red,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        '${meal['aggregateLikes']} people loved it',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white70),
                                                      ),
                                                    ],
                                                  )
                                                      : Shimmer.fromColors(
                                                    baseColor:
                                                    Colors.grey[300]!,
                                                    highlightColor:
                                                    Colors.grey[100]!,
                                                    child: Container(
                                                      height: 20,
                                                      width: 150,
                                                      color: Colors.grey[300],
                                                    ),
                                                  ),
                                                  meal['nutrition'] != null
                                                      ? Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .local_fire_department,
                                                        color: Colors.orange,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        '${meal['nutrition']['nutrients'][0]['amount']} kcal',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white70),
                                                      ),
                                                    ],
                                                  )
                                                      : Shimmer.fromColors(
                                                    baseColor:
                                                    Colors.grey[300]!,
                                                    highlightColor:
                                                    Colors.grey[100]!,
                                                    child: Container(
                                                      height: 20,
                                                      width: 100,
                                                      color: Colors.grey[300],
                                                    ),
                                                  ),
                                                  meal['readyInMinutes'] != null
                                                      ? Row(
                                                    children: [
                                                      Icon(
                                                        Icons.access_time,
                                                        color: Colors.blue,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        '${meal['readyInMinutes']} mins',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white70),
                                                      ),
                                                    ],
                                                  )
                                                      : Shimmer.fromColors(
                                                    baseColor:
                                                    Colors.grey[300]!,
                                                    highlightColor:
                                                    Colors.grey[100]!,
                                                    child: Container(
                                                      height: 20,
                                                      width: 100,
                                                      color: Colors.grey[300],
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
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
  }
}
