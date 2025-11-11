import 'package:flood_monitoring_android/constants/app_colors.dart';
import 'package:flood_monitoring_android/controller/phone_subscriber_controller.dart';
import 'package:flood_monitoring_android/model/app_subscriber.dart';
import 'package:flood_monitoring_android/utils/shared_pref_util.dart';
import 'package:flood_monitoring_android/views/screens/login_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _sharedPref = SharedPrefUtil();
  final _controller = PhoneSubscriberController();
  AppSubscriber? subscriber;
  bool isLoading = true;
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  String receiveAppAlerts = "Yes";
  String receiveSMSAlerts = "No";

  @override
  void initState() {
    super.initState();
    _loadSubscriberInfo();
  }

  Future<void> _loadSubscriberInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fetched = await _controller.getSubscriberInfo(user.uid);
        if (fetched != null) {
          setState(() {
            subscriber = fetched;
            _emailController.text = user.email ?? "";
            _nameController.text = fetched.fullName;
            _ageController.text = fetched.age;
            _genderController.text = fetched.gender;
            _addressController.text = fetched.address;
            _phoneController.text = fetched.phoneNumber;
            receiveAppAlerts = fetched.viaApp;
            receiveSMSAlerts = fetched.viaSMS;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading subscriber info: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fetched = await _controller.getSubscriberInfo(user.uid);
        subscriber = fetched;

        if (fetched != null) {
          final updated = AppSubscriber(
            id: user.uid,
            fullName: _nameController.text.trim(),
            age: _ageController.text.trim(),
            gender: _genderController.text.trim(),
            address: _addressController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            registeredDate: fetched.registeredDate,
            viaApp: receiveAppAlerts,
            viaSMS: receiveSMSAlerts,
          );
          await _controller.updateSubscriberInfo(updated);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.textDark),
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.accentBlue),
            onPressed: _saveProfile,
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subscriber == null
          ? const Center(child: Text("No subscriber info found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Profile Information'),
                  _buildEditableCard(
                    title: 'Email',
                    controller: _emailController,
                    icon: Icons.email,
                    isEditable: false,
                  ),
                  _buildEditableCard(
                    title: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person,
                  ),
                  _buildEditableCard(
                    title: 'Age',
                    controller: _ageController,
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                  _buildEditableCard(
                    title: 'Gender',
                    controller: _genderController,
                    icon: Icons.transgender,
                  ),
                  _buildEditableCard(
                    title: 'Address',
                    controller: _addressController,
                    icon: Icons.home,
                  ),
                  _buildEditableCard(
                    title: 'Contact Number',
                    controller: _phoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Alert Preferences'),
                  _buildPreferenceSwitch(
                    title: 'Receive App Notifications',
                    value: receiveAppAlerts,
                    icon: Icons.notifications,
                    onChanged: (value) {
                      setState(() => receiveAppAlerts = value);
                    },
                  ),
                  _buildPreferenceSwitch(
                    title: 'Receive SMS Alerts',
                    value: receiveSMSAlerts,
                    icon: Icons.sms,
                    onChanged: (value) {
                      setState(() => receiveSMSAlerts = value);
                    },
                  ),

                  const SizedBox(height: 24),

                  _buildSectionHeader('Account Actions'),
                  _buildActionButton(
                    title: 'Change Password',
                    icon: Icons.lock,
                    color: AppColors.accentBlue,
                    onTap: _showChangePasswordDialog,
                  ),
                  _buildActionButton(
                    title: 'Delete Account',
                    icon: Icons.delete,
                    color: AppColors.errorRed,
                    onTap: _showDeleteAccountDialog,
                  ),
                  _buildActionButton(
                    title: 'Logout',
                    icon: Icons.logout,
                    color: AppColors.statusAlertText,
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildEditableCard({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    bool isEditable = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accentBlue),
        title: TextField(
          controller: controller,
          enabled: isEditable,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: title,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.accentBlue),
      title: Text(title),
      value: value == "Yes",
      onChanged: (val) async {
        final newValue = val ? "Yes" : "No";
        setState(() => onChanged(newValue));

        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final fetched = await _controller.getSubscriberInfo(user.uid);
            if (fetched != null) {
              final updated = AppSubscriber(
                id: user.uid,
                email: _emailController.text.trim(),
                fullName: _nameController.text.trim(),
                age: _ageController.text.trim(),
                gender: _genderController.text.trim(),
                address: _addressController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                registeredDate: fetched.registeredDate,
                viaApp: title == "Receive App Notifications"
                    ? newValue
                    : receiveAppAlerts,
                viaSMS: title == "Receive SMS Alerts"
                    ? newValue
                    : receiveSMSAlerts,
              );
              await _controller.updateSubscriberInfo(updated);
            }
          }
        } catch (e) {
          debugPrint("Error updating preference: $e");
        }
      },
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog() {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
              validator: (val) => val == null || val.isEmpty
                  ? 'Enter your current password'
                  : null,
            ),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
              validator: (val) => val != null && val.length < 6
                  ? 'Password must be at least 6 chars'
                  : null,
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              validator: (val) => val != newPasswordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Change'),
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;

            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              final cred = EmailAuthProvider.credential(
                email: user.email!,
                password: currentPasswordController.text.trim(),
              );
              await user.reauthenticateWithCredential(cred);

              await user.updatePassword(newPasswordController.text.trim());

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              }
            } on FirebaseAuthException catch (e) {
              String msg = 'Failed to change password';
              if (e.code == 'wrong-password') {
                msg = 'The current password is incorrect';
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              }
            }
          },
        ),
      ],
    ),
  );
}


  Future<void> _reauthenticateAndDelete(User user) async {
    try {
      if (user.providerData.any((info) => info.providerId == 'password')) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: await _askPassword(),
        );
        await user.reauthenticateWithCredential(cred);
      } else if (user.providerData.any(
        (info) => info.providerId == 'google.com',
      )) {
        final googleUser = await GoogleSignIn().signIn();
        final googleAuth = await googleUser!.authentication;
        final cred = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        await user.reauthenticateWithCredential(cred);
      }

      await user.delete();
    } catch (e) {
      throw Exception("Reauthentication failed: $e");
    }
  }

  Future<String> _askPassword() async {
    String password = '';
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Confirm Password"),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Enter your password"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                password = controller.text.trim();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    return password;
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              try {
                await _reauthenticateAndDelete(user!);
                await PhoneSubscriberController().delete(user!.uid);
                await _sharedPref.clearCredentials();
                await _sharedPref.clearFillup();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              } catch (e) {
                debugPrint("Delete error: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Logout'),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await _sharedPref.clearCredentials();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
