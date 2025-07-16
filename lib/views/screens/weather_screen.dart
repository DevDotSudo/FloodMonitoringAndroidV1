import 'package:flutter/material.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Weather Details Page',
        style: Theme.of(context).textTheme.titleLarge, // Use theme text style
      ),
    );
  }
}