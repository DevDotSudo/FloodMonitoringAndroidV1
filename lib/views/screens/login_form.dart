import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_monitoring_android/auth/google_signin.dart';
import 'package:flood_monitoring_android/constants/app_colors.dart';
import 'package:flood_monitoring_android/controller/phone_subscriber_controller.dart';
import 'package:flood_monitoring_android/utils/shared_pref_util.dart';
import 'package:flood_monitoring_android/views/main_screen.dart';
import 'package:flood_monitoring_android/views/screens/fillup_page.dart';
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
  final _sharedPref = SharedPrefUtil();
  final _phoneSubscriberController = PhoneSubscriberController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _googleSignin = GoogleFirebaseSignin();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final credentials = await _sharedPref.getLoginCredentials();

    final email = credentials['email'];
    final password = credentials['password'];
    final isGoogleSignIn = credentials['isGoogleSignIn'];

    if (email != null && password != null && !isGoogleSignIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    } else if (isGoogleSignIn) {
      final filledUp = await _sharedPref.isFillup();

      if (filledUp == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => FillUpPage()),
        );
      }
    } else {
      return;
    }
  }

  Future<void> signIntoGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });
    try {
      User? user = await _googleSignin.signInWithGoogle();
      if (mounted && user != null) {
        _sharedPref.saveGoogleSignIn(user.email!);
        bool? filledUp = await _sharedPref.isFillup();
        bool? emailExist = await _googleSignin.isEmailExist(user.uid);

        if (filledUp == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
          return;
        }

        if (emailExist == true ) {
          await _sharedPref.saveFillup();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FillUpPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        await MessageDialog.show(
          context: context,
          title: 'Sign-In Failed',
          message: 'Could not sign in with Google. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> login() async {
    // --- MODIFIED: Added loading state management ---
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isEmailLoading = true;
    });

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      await _phoneSubscriberController.loginSubscriber(email, password);
      if (!mounted) return;
      await _showSuccessDialog();

      if (_rememberMe) {
        _sharedPref.saveLoginCredentials(email, password);
      }
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog();
    } finally {
      if (mounted) {
        setState(() {
          _isEmailLoading = false;
        });
      }
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
                  color: Colors.grey.withOpacity(0.2), // Softer shadow
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
                    color: AppColors.primaryBackground,
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
                        'Banate MDRRMO \nFlood Monitoring System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentBlue,
                          fontSize: 18.0,
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
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
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
                            // Simplified validation for example
                            if (!value.contains('@')) {
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
                          controller: _passwordController,
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
                                  color: AppColors.accentBlue,
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
                          // --- MODIFIED: Login Button with loading animation ---
                          child: ElevatedButton(
                            onPressed: _isEmailLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              shadowColor: Colors.black.withOpacity(0.2),
                              elevation: 4,
                            ),
                            child: _isEmailLoading
                                ? const SizedBox(
                                    height: 24.0,
                                    width: 24.0,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
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
                              text: 'Don\'t have an account? ', // Changed text
                              style: const TextStyle(
                                color: Color(0xFF616161),
                                fontSize: 14.0,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Register',
                                  style: const TextStyle(
                                    color: AppColors.accentBlue,
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
                          // --- MODIFIED: Google Sign-in Button with loading animation ---
                          child: OutlinedButton(
                            onPressed: _isGoogleLoading ? null : signIntoGoogle,
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
                              ),
                            ),
                            child: _isGoogleLoading
                                ? const SizedBox(
                                    height: 24.0,
                                    width: 24.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.accentBlue,
                                      ),
                                    ),
                                  )
                                : Row(
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
                                          color: Color(0xFF3C4043),
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
