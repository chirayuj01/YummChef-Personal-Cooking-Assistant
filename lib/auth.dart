import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:recipe_app/Signiinauth.dart';
import 'package:recipe_app/Signupauth.dart';

class SigninOrSignupScreen extends StatelessWidget {
  const SigninOrSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.04), // Responsive padding
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    height: constraints.maxHeight * 0.2,
                    width: constraints.maxWidth * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: Image.asset('assets/images/logoi.png', fit: BoxFit.cover, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          PageAnimationTransition(
                              page: SignInScreen(),
                              pageAnimationType: RightToLeftFadedTransition()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, constraints.maxHeight * 0.08), // Responsive height
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02), // Responsive spacing
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          PageAnimationTransition(
                              page: SignupScreen(),
                              pageAnimationType: RightToLeftFadedTransition()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: Size(double.infinity, constraints.maxHeight * 0.08), // Responsive height
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(flex: 2),
                ].animate().fade(duration: 200.ms).scale(delay: 500.ms),
              ),
            );
          },
        ),
      ),
    );
  }
}