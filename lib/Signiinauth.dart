import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/MongoDB/MongoDb.dart';
import 'package:recipe_app/Provider/useraccess.dart';
import 'package:recipe_app/Signupauth.dart';
import 'package:recipe_app/home.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String email = '';
  bool isloading = false;
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google sign-in canceled")),
        );
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      setState(() {
        isloading = true;
      });

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      email = (userCredential.user?.email) ?? '';
      Navigator.pushReplacement(
          context,
          PageAnimationTransition(
              page: HomePage(),
              pageAnimationType: RightToLeftFadedTransition()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome, ${userCredential.user?.displayName}!")),
      );

      return userCredential;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during sign-in: $error")),
      );
      return null;
    }
  }

  Future<UserCredential?> signInWithGithub() async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      setState(() {
        isloading = true;
      });
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithProvider(githubProvider);
      email = (userCredential.user?.email) ?? '';
      Navigator.pushReplacement(
          context,
          PageAnimationTransition(
              page: HomePage(),
              pageAnimationType: RightToLeftFadedTransition()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome, ${userCredential.user?.email}!")),
      );
      return userCredential;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${e.toString()}")),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<UserDetails>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: isloading == true
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.orange,
          ),
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.04),
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
                              child: Image.asset(
                                'assets/images/logoi.png',
                                fit: BoxFit.cover,
                                color: Colors.white,
                              ))),
                      SizedBox(height: constraints.maxHeight * 0.07),
                      Text(
                        "Sign in with your email and password\nor continue with social media",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      const SignInForm(),
                      SizedBox(height: constraints.maxHeight * 0.09),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await signInWithGoogle();
                              instance.updateemail(email);
                              var userData = await MongoDatabase.collection
                                  .findOne({'user-id': instance.email});
                              List<String> userRecipes =
                                  userData?['recipes']?.cast<String>() ??
                                      [];
                              instance.updateRecipes(userRecipes);
                              print(instance.savedrecipes.toString());
                            },
                            child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                child: FaIcon(FontAwesomeIcons.google,
                                    color: Colors.red, size: 25)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: GestureDetector(
                              onTap: () async {
                                await signInWithGithub();
                                instance.updateemail(email);
                                var userData =
                                await MongoDatabase.collection.findOne(
                                    {'user-id': instance.email});
                                List<String> userRecipes =
                                    userData?['recipes']?.cast<String>() ??
                                        [];
                                instance.updateRecipes(userRecipes);
                                print(instance.savedrecipes.toString());
                              },
                              child: const CircleAvatar(
                                radius: 27,
                                backgroundColor: Colors.white,
                                child: FaIcon(
                                  FontAwesomeIcons.github,
                                  color: Colors.black,
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
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

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;
  bool hide = true;
  Future<void> onSignIn(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
          context,
          PageAnimationTransition(
              page: HomePage(),
              pageAnimationType: RightToLeftFadedTransition()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Signin successful!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No user found for that email.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Invalid password for this email.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Invalid credentials'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<UserDetails>(context, listen: false);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            onChanged: (value) {
              email = value;
            },
            onSaved: (value) {
              email = value!;
            },
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Enter your email",
              labelText: "Email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: const TextStyle(color: Colors.white),
              hintStyle: const TextStyle(color: Colors.white70),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
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
              onSaved: (value) {
                password = value ?? '';
              },
              obscureText: hide,
              obscuringCharacter: '*',
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your password",
                labelText: "Password",
                labelStyle: const TextStyle(color: Colors.white),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Colors.white70),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffix: GestureDetector(
                  onTap: () {
                    setState(() {
                      hide = !hide;
                    });
                  },
                  child: hide == true
                      ? FaIcon(
                    FontAwesomeIcons.eyeSlash,
                    color: Colors.grey,
                    size: 25,
                  )
                      : FaIcon(
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
            child: CircularProgressIndicator(
              color: Colors.orange,
            ),
          )
              : ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                onSignIn(email, password);
                instance.updateemail(email);
                var userData = await MongoDatabase.collection
                    .findOne({'user-id': instance.email});
                List<String> userRecipes =
                    userData?['recipes']?.cast<String>() ?? [];
                instance.updateRecipes(userRecipes);
                print(instance.email);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid credentials entered',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
              "Sign in",
              style: TextStyle(
                fontSize: 25,
                letterSpacing: -0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: email,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Password reset email sent!',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Some error occured')),
                );
              }
            },
            child: Text(
              'Reset password',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
              ),
            ),
          )
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
          "Don’t have an account? ",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                PageAnimationTransition(
                    page: SignupScreen(),
                    pageAnimationType: RightToLeftFadedTransition()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
                color: Colors.tealAccent,
                decorationColor: Colors.teal,
                decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}

// Icons
const mailIcon =
'''<svg width="18" height="13" viewBox="0 0 18 13" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M15.3576 3.39368C15.5215 3.62375 15.4697 3.94447 15.2404 4.10954L9.80876 8.03862C9.57272 8.21053 9.29421 8.29605 9.01656 8.29605C8.7406 8.29605 8.4638 8.21138 8.22775 8.04204L2.76041 4.11039C2.53201 3.94618 2.47851 3.62546 2.64154 3.39454C2.80542 3.16362 3.12383 3.10974 3.35223 3.27566L8.81872 7.20645C8.93674 7.29112 9.09552 7.29197 9.2144 7.20559L14.6469 3.27651C14.8753 3.10974 15.1937 3.16447 15.3576 3.39368ZM16.9819 10.7763C16.9819 11.4366 16.4479 11.9745 15.7932 11.9745H2.20765C1.55215 11.9745 1.01892 11.4366 1.01892 10.7763V2.22368C1.01892 1.56342 1.55215 1.02632 2.20765 1.02632H15.7932C16.4479 1.02632 16.9819 1.56342 16.9819 2.22368V10.7763ZM15.7932 0H2.20765C0.990047 0 0 0.998092 0 2.22368V10.7763C0 12.0028 0.990047 13 2.20765 13H15.7932C17.01 13 18 12.0028 18 10.7763V2.22368C18 0.998092 17.01 0 15.7932 0Z" fill="#757575"/>
</svg>''';

const googleIcon =
'''<svg width="16" height="17" viewBox="0 0 16 17" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M15.9988 8.3441C15.9988 7.67295 15.9443 7.18319 15.8265 6.67529H8.1626V9.70453H12.6611C12.5705 10.4573 12.0807 11.5911 10.9923 12.3529L10.9771 12.4543L13.4002 14.3315L13.5681 14.3482C15.1099 12.9243 15.9988 10.8292 15.9988 8.3441Z" fill="#4285F4"/>
<path d="M8.16265 16.3254C10.3666 16.3254 12.2168 15.5998 13.5682 14.3482L10.9924 12.3528C10.3031 12.8335 9.37796 13.1691 8.16265 13.1691C6.00408 13.1691 4.17202 11.7452 3.51894 9.7771L3.42321 9.78523L0.903556 11.7352L0.870605 11.8268C2.2129 14.4933 4.9701 16.3254 8.16265 16.3254Z" fill="#34A853"/>
<path d="M3.519 9.77716C3.34668 9.26927 3.24695 8.72505 3.24695 8.16275C3.24695 7.6004 3.34668 7.05624 3.50994 6.54834L3.50537 6.44017L0.954141 4.45886L0.870669 4.49857C0.317442 5.60508 0 6.84765 0 8.16275C0 9.47785 0.317442 10.7204 0.870669 11.8269L3.519 9.77716Z" fill="#FBBC05"/>
<path d="M8.16265 3.15623C9.69541 3.15623 10.7293 3.81831 11.3189 4.3716L13.6226 2.12231C12.2077 0.807206 10.3666 0 8.16265 0C4.9701 0 2.2129 1.83206 0.870605 4.49853L3.50987 6.54831C4.17202 4.58019 6.00408 3.15623 8.16265 3.15623Z" fill="#EB4335"/>
</svg>''';