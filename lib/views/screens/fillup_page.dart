import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_monitoring_android/constants/app_colors.dart';
import 'package:flood_monitoring_android/controller/phone_subscriber_controller.dart';
import 'package:flood_monitoring_android/model/app_subscriber.dart';
import 'package:flood_monitoring_android/utils/shared_pref_util.dart';
import 'package:flood_monitoring_android/views/main_screen.dart';
import 'package:flood_monitoring_android/views/widgets/message_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FillUpPage extends StatefulWidget {
  const FillUpPage({super.key});

  @override
  State<FillUpPage> createState() => _FillUpPageState();
}

class _FillUpPageState extends State<FillUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _phoneSubscriberController = PhoneSubscriberController();
  final _sharedPref = SharedPrefUtil();
  String? selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  // --- ADDED: State variable to track loading status ---
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await _showErrorDialog();
      print("User is empty");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // --- MODIFIED: Set loading state to true ---
    setState(() {
      _isLoading = true;
    });

    try {
      final phoneSubs = AppSubscriber(
        id: user.uid,
        fullName: _fullNameController.text.trim(),
        address: _addressController.text.trim(),
        gender: selectedGender ?? 'Other',
        age: _ageController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        registeredDate: DateFormat(
          'MMMM d, yyyy - h:mm a',
        ).format(DateTime.now()),
        viaSMS: 'No',
        viaApp: 'Yes',
      );

      await _phoneSubscriberController.saveFillup(phoneSubs);
      if (!mounted) return;
      await _sharedPref.saveFillup();
      await _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    await MessageDialog.show(
      context: context,
      title: 'Form Submitted',
      message: 'Your information has been successfully saved.',
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      ),
    );
  }

  Future<void> _showErrorDialog() async {
    // --- MODIFIED: Made error message more generic ---
    await MessageDialog.show(
      context: context,
      title: 'Submission Failed',
      message: 'An error occurred. Please try again later.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Fill Up Form'),
        backgroundColor: AppColors.primaryBackground,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Please provide your details below.',
                      style: TextStyle(
                        color: Color(0xFF616161),
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // Full Name
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _fullNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter full name.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
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
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Address
                    const Text(
                      'Address',
                      style: TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _addressController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your address',
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
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Gender
                    const Text(
                      'Gender',
                      style: TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      validator: (value) =>
                          value == null ? 'Please select a gender' : null,
                      value: selectedGender,
                      hint: const Text('Select Gender'),
                      decoration: InputDecoration(
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
                      ),
                      items: _genderOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGender = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Age
                    const Text(
                      'Age',
                      style: TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _ageController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age.';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter your age',
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
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Phone Number
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _phoneNumberController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Enter your phone number',
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
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    SizedBox(
                      width: double.infinity,
                      // --- MODIFIED: Submit Button with loading animation ---
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          shadowColor: Colors.black.withOpacity(0.2),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'SUBMIT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
  }
}