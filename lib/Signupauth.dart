import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:page_animation_transition/animations/left_to_right_faded_transition.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/MongoDB/MongoDb.dart';
import 'package:recipe_app/Provider/useraccess.dart';
import 'package:recipe_app/Signiinauth.dart';
import 'package:recipe_app/home.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.04),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.03),
                      Container(
                          height: constraints.maxHeight * 0.1,
                          width: constraints.maxWidth * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: Image.asset('assets/images/logoi.png',fit: BoxFit.cover,color: Colors.white,)
                          )
                      ),
                      SizedBox(height: constraints.maxHeight * 0.07),
                      const Text(
                        "Sign up using your email and password  \nand create your new account",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      SignupForm(),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      const NoAccountText(),
                    ].animate().fade(duration: 200.ms).scale(delay: 500.ms),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.white),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);


class SignupForm extends StatefulWidget {

  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool hide=true;


  @override
  Widget build(BuildContext context) {
    var instance=Provider.of<UserDetails>(context,listen: false);
    Future<void> onSignup(String email, String password) async {
      setState(() {
        _isLoading = true;
      });

      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        instance.updateemail(emailController.text);
        var userData = await MongoDatabase.collection.findOne({'user-id': instance.email});
        List<String> userRecipes = userData?['recipes']?.cast<String>() ?? [];
        instance.updateRecipes(userRecipes);
        Navigator.pushReplacement(context,PageAnimationTransition(page: HomePage(), pageAnimationType: RightToLeftFadedTransition()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successfull!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for this email.';
        } else {
          errorMessage = 'An unknown error occurred. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Enter your email",
              labelText: "Email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: const TextStyle(color: Colors.white),
              hintStyle: const TextStyle(color: Colors.white70),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              suffix: SvgPicture.string(
                mailIcon,
                height: 20,
                color: Colors.white70,
              ),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Colors.teal),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email cannot be empty';
              }
              if (!value.contains('@') || value.startsWith('@')) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: TextFormField(
              controller: passwordController,
              obscureText: hide,
              obscuringCharacter: '*',
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your password",
                labelText: "Password",
                labelStyle: const TextStyle(color: Colors.white),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Colors.white70),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                suffix: GestureDetector(
                  onTap: (){
                    setState(() {
                      hide=!hide;
                    });
                  },
                  child: hide==true?FaIcon(
                    FontAwesomeIcons.eyeSlash,
                    color: Colors.grey,
                    size: 25,
                  ):FaIcon(
                    FontAwesomeIcons.eye,
                    color: Colors.grey,
                    size: 25,
                  ),
                ),
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder,
                focusedBorder: authOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Colors.teal),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password cannot be empty';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 8),


          _isLoading
              ? Center(
            child: Container(
              height: 200,
              width: 200,
              child:Lottie.asset('assets/loadinganimation/recipe.json'),
            ),
          )
              : ElevatedButton(
            onPressed: (){
              if (_formKey.currentState!.validate()){
                _formKey.currentState!.save();
                instance.updateemail(emailController.text);
                onSignup(emailController.text.trim(), passwordController.text.trim());


              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Invalid credentials entered',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.teal.shade400,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(21)),
              ),
            ),
            child: const Text(
              "Sign up",
              style: TextStyle(
                fontSize: 25,
                letterSpacing: -0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class SocalCard extends StatelessWidget {
  const SocalCard({
    Key? key,
    required this.icon,
    required this.press,
  }) : super(key: key);

  final Widget icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 56,
        width: 56,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F6F9),
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }
}

class NoAccountText extends StatelessWidget {
  const NoAccountText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, PageAnimationTransition(page: SignInScreen(), pageAnimationType: LeftToRightFadedTransition()));
          },
          child: const Text(
            "Sign in",
            style: TextStyle(
                color: Colors.tealAccent,
                decorationColor: Colors.teal,
                decoration: TextDecoration.underline
            ),
          ),
        ),
      ],
    );
  }
}
