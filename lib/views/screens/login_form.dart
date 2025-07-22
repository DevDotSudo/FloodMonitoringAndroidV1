import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_monitoring_android/auth/google_signin.dart';
import 'package:flood_monitoring_android/controller/phone_subscriber_controller.dart';
import 'package:flood_monitoring_android/model/app_subscriber.dart';
import 'package:flood_monitoring_android/views/main_screen.dart';
import 'package:flood_monitoring_android/views/screens/register_form.dart';
import 'package:flood_monitoring_android/views/widgets/message_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneSubscriberController = PhoneSubscriberController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _googleSignin = GoogleFirebaseSignin();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  Future<void> signIntoGoogle() async {
    User? user = await _googleSignin.signInWithGoogle();
    if (mounted && user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );  
    }
  }

  Future<void> login() async {
    try {
      final phoneLogin = AppSubscriber.credentials(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      await _phoneSubscriberController.loginSubscriber(phoneLogin);
      if (!mounted) return;
      await _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog();
    }
  }

  Future<void> _showSuccessDialog() async {
    await MessageDialog.show(
      context: context,
      title: 'Login Successful',
      message: 'Your account has been login successfully.',
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      ),
    );
  }

  Future<void> _showErrorDialog() async {
    await MessageDialog.show(
      context: context,
      title: 'Login Failed',
      message: 'Incorrect username or password. Please try again.',
      onPressed: () => {
        _emailController.clear(),
        _passwordController.clear(),
        Navigator.pop(context),
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF3F51B5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3F51B5),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 32),
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: Image(
                          image: AssetImage(
                            'assets/images/app_icon_android.png',
                          ),
                          width: 170,
                          height: 170,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Real-time water level monitoring and alert system for subscribers',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          height: 1.4, // Line height
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: Color(0xFF212121),
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Please login your account.',
                          style: TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: Color(0xFF212121),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            filled: true,
                            fillColor: const Color(
                              0xFFF5F5F5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.0,
                              ), // Light border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF3F51B5),
                                width: 2.0,
                              ), // Blue focus border
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email.';
                            }
                            if (!value.contains('@gmail.com')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Password',
                          style: TextStyle(
                            color: Color(0xFF212121),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF3F51B5),
                                width: 2.0,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF757575), // Grey icon
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24.0, // Standard checkbox size
                                  height: 24.0,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        _rememberMe = newValue!;
                                      });
                                    },
                                    activeColor: const Color(
                                      0xFF3F51B5,
                                    ), // Blue checkbox
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        4.0,
                                      ), // Slightly rounded checkbox
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                    ), // Border color
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: Color(0xFF616161),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle forgot password
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Color(0xFF3F51B5),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle login
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF3F51B5,
                              ), // Blue button
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              shadowColor: Colors.black.withOpacity(
                                0.2,
                              ), // Shadow
                              elevation: 4, // Shadow depth
                            ),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Align(
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              text: 'Create new admin account? ',
                              style: const TextStyle(
                                color: Color(0xFF616161),
                                fontSize: 14.0,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Register',
                                  style: const TextStyle(
                                    color: Color(0xFF3F51B5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RegisterPage(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: signIntoGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFDADCE0),
                                width: 1.0,
                              ), // Light grey border
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/google_icon.svg',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 10.0),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    color: Color(0xFF3C4043), // Dark grey text
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
