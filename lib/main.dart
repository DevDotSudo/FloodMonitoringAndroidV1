import 'package:firebase_core/firebase_core.dart';
import 'package:flood_monitoring_android/services/water_level_service.dart';
import 'package:flood_monitoring_android/views/screens/login_form.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const FloodMonitoring());
  WaterLevelService().startListening();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((_) {
        print("Firebase initialized successfully");
      })
      .catchError((error) {
        print("Firebase initialization error: $error");
      });
}

class FloodMonitoring extends StatelessWidget {
  const FloodMonitoring({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flood Monitoring',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
    );
  }
}
