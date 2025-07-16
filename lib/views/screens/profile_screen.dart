import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'User Profile Page',
        style: Theme.of(context).textTheme.titleLarge, // Use theme text style
      ),
    );
  }
}
