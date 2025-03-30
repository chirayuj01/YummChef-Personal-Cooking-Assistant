import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:page_animation_transition/animations/left_to_right_faded_transition.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/Provider/useraccess.dart';
import 'package:recipe_app/navbaroptions/SearchRecipes.dart';
import 'package:recipe_app/navbaroptions/recipeAPI/MealTab.dart';
import 'package:recipe_app/onBoarding.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String username = '';

  @override
  void initState() {
    super.initState();
    if (user != null && user!.displayName != null) {
      username = user!.displayName!.split(' ').first;
      print(username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 5),
        child: DefaultTabController(
          length: 5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Let\'s cook some \ngood stuff,  ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontSize: constraints.maxWidth * 0.065,
                                  fontFamily: 'Poppins',
                                  letterSpacing: -1.2,
                                ),
                              ),
                              TextSpan(
                                text: (username.toUpperCase() == '' ? 'BRO' : username.toUpperCase()) + ' !!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: constraints.maxWidth * 0.07,
                                  fontFamily: 'Poppins',
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          _showLogoutDialog(context);
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 15),
                            Icon(Icons.logout, color: Colors.white70, size: 32),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1,
                                  color: Colors.white70,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Container(
                          width: double.infinity,
                          height: constraints.maxHeight * 0.3, // Responsive height
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(21),
                            child: Image.asset('assets/images/img.png', fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Positioned(
                        top: constraints.maxHeight * 0.25,
                        left: constraints.maxWidth * 0.45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.6),
                            fixedSize: Size(constraints.maxWidth * 0.53, constraints.maxHeight * 0.06), // Responsive button size
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageAnimationTransition(
                                page: SearchRecipe(),
                                pageAnimationType: RightToLeftFadedTransition(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                'Explore Dishes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  fontSize: constraints.maxWidth * 0.04, // Responsive font size
                                ),
                              ),
                              const SizedBox(width: 8),
                              const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 22),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02), // Responsive spacing
                  const TabBar(
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    labelColor: Colors.orange,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.orange,
                    tabs: [
                      Tab(icon: Icon(Icons.free_breakfast), text: 'Breakfast'),
                      Tab(icon: Icon(Icons.fastfood), text: 'Starters'),
                      Tab(icon: Icon(Icons.restaurant), text: 'Main course'),
                      Tab(icon: Icon(Icons.donut_small), text: 'Dessert'),
                      Tab(icon: Icon(Icons.wine_bar), text: 'Beverages'),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        MealDetailsTab(mealType: 'Breakfast'),
                        MealDetailsTab(mealType: 'starters'),
                        MealDetailsTab(mealType: 'Main course'),
                        MealDetailsTab(mealType: 'dessert'),
                        MealDetailsTab(mealType: 'beverage'),
                      ],
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.01), // Responsive spacing
                ].animate().fade(duration: 100.ms).scale(delay: 100.ms),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Are you sure you want to log out?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Log Out', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              onPressed: () async {
                Navigator.of(context).pop();
                _performLogout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Expanded(
        child: Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: LoadingIndicator(indicatorType: Indicator.pacman, colors: [Colors.orange, Colors.white]),
          ),
        ),
      ),
    );
    await FirebaseAuth.instance.signOut();
    Provider.of<UserDetails>(context, listen: false).clearlist();
    Navigator.of(context).pushReplacement(
      PageAnimationTransition(page: const OnboardingScreen(), pageAnimationType: LeftToRightFadedTransition()),
    );
  }
}