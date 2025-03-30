import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:recipe_app/onBoarding.dart';

import 'home.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var instance = FirebaseAuth.instance;
  bool islogin = false;
  isloggedin() async {
    var curruser = await instance.currentUser;
    islogin = (curruser != null) ? true : false;
    setState(() {
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isloggedin();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(

        animationDuration: Duration(milliseconds: 1500),
        backgroundColor: Colors.white,
        splash: 'assets/images/logo.jpg',
        splashIconSize: 250,
        nextScreen: islogin ? HomePage() : OnboardingScreen(),
        splashTransition: SplashTransition.rotationTransition,
        centered: true,
    );
  }
}
