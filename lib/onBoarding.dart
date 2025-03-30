import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:recipe_app/Signiinauth.dart';
import 'package:recipe_app/auth.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (currentPage + 1) % demoData.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
        setState(() {
          currentPage = nextPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  flex: 14,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: demoData.length,
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                    },
                    itemBuilder: (context, index) => OnboardContent(
                      illustration: demoData[index]["illustration"],
                      title: demoData[index]["title"],
                      text: demoData[index]["text"],
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    demoData.length,
                        (index) => DotIndicator(isActive: index == currentPage),
                  ),
                ),
                const Spacer(flex: 2),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.04),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          PageAnimationTransition(
                              page: SigninOrSignupScreen(),
                              pageAnimationType: RightToLeftFadedTransition()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade400,
                        foregroundColor: Colors.black,
                        elevation: 10,
                        shadowColor: Colors.grey,
                        minimumSize: Size(
                            double.infinity, constraints.maxHeight * 0.08),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(21))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Let\'s Cook",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                wordSpacing: 5,
                                letterSpacing: -3,
                                fontSize: 35,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 22,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.02),
              ].animate().fade(duration: 200.ms).scale(delay: 500.ms),
            );
          },
        ),
      ),
    );
  }
}

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });

  final String? illustration, title, text;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(illustration!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 25,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.01),
              Text(
                text!,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
    this.activeColor = Colors.teal,
    this.inActiveColor = const Color(0xFF868686),
  });

  final bool isActive;
  final Color activeColor, inActiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16 / 2),
      height: 8,
      width: 10,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inActiveColor.withOpacity(0.25),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}

List<Map<String, dynamic>> demoData = [
  {
    "illustration": "https://i.postimg.cc/cCHsbVxX/pexels-photo-376464.jpg",
    "title": "Discover Recipes",
    "text":
    "Explore thousands of recipes from different cuisines\nand find your next favorite dish.",
  },
  {
    "illustration": "https://i.postimg.cc/vTx6KPvF/pexels-photo-4686825.jpg",
    "title": "Step-by-Step Cooking",
    "text":
    "Follow easy step-by-step instructions with images\nand cook like a pro.",
  },
  {
    "illustration": "https://i.postimg.cc/3rtSQWCt/pexels-photo-1279330.jpg",
    "title": "Save Your Favorites",
    "text":
    "Bookmark recipes you love and easily access them\nanytime from your saved list.",
  },
];