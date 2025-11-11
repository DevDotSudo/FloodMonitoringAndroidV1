import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_monitoring_android/constants/app_colors.dart';
import 'package:flood_monitoring_android/controller/phone_subscriber_controller.dart';
import 'package:flood_monitoring_android/controller/water_level_controller.dart';
import 'package:flood_monitoring_android/model/water_level_data.dart';
import 'package:flood_monitoring_android/services/app_warning_message.dart';
import 'package:flood_monitoring_android/services/fcm_handler.dart';
import 'package:flood_monitoring_android/views/widgets/water_level_graph.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final _waterLevelController = WaterLevelDataController();
  final _appWarningMessage = AppWarningMessage();
  final controller = PhoneSubscriberController();
  User? user = FirebaseAuth.instance.currentUser;
  String? displayName;
  String? _message;

  @override
  void initState() {
    updateToken();
    displayFullName();
    super.initState();
  }

  Future<void> displayFullName() async {
    if (user != null) {
      String? fullName = await controller.getSubscriberFullName(
        user?.uid ?? '',
      );
      
      setState(() {
        final fullNameGoogleSignin = user?.displayName ?? '';
        final fullNameEmailAndPassword = fullName;
        displayName = checkNullOrNot(
          fullNameGoogleSignin,
          fullNameEmailAndPassword,
        );
      });
    }
  }

  String? checkNullOrNot(String? googleSignIn, String? emailAndPassword) {
    if (googleSignIn!.isEmpty) {
      return emailAndPassword;
    } else {
      return googleSignIn;
    }
  }

  Future<void> updateToken() async {
    await FCMHandler().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WaterLevelDataPoint>>(
      stream: _waterLevelController.watchWaterLevels(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];
        _waterLevelController.liveWaterLevelData = data;
        final currentLevel = _waterLevelController.currentWaterLevel;
        final status = _waterLevelController.riverStatus;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatusCards(status, currentLevel),
              const SizedBox(height: 24),
              _buildChartSection(data, _waterLevelController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayName ?? '',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
      ],
    );
  }

  Widget _buildStatusCards(String status, double currentLevel) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.warning_rounded,
                iconColor: _getStatusColor(status),
                label: 'River Status',
                value: status,
                bgColor: _getStatusColor(status).withOpacity(0.08),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.water_drop_rounded,
                iconColor: AppColors.statusInfoText,
                label: 'Current Water Level',
                value: '${currentLevel}ft',
                bgColor: AppColors.accentBlue.withOpacity(0.08),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMessageCard(
          context: context,
          icon: Icons.message_rounded,
          iconColor: Colors.green.shade600,
          label: 'Message from MDRRMO Banate',
          value: _message ?? '',
          bgColor: Colors.green.withOpacity(0.08),
        ),
      ],
    );
  }

  Widget _buildChartSection(
    List<WaterLevelDataPoint> data,
    WaterLevelDataController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 20,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              'Live Water Level Monitoring',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 250,
              child: WaterLevelGraph(
                dataPoints: data,
                waterLevelDataController: controller,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return StreamBuilder<String?>(
      stream: _appWarningMessage.watchWarningMessage(),
      builder: (context, snapshot) {
        String message = snapshot.data ?? value;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  message.isNotEmpty ? message : "No message yet.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    if (status.isEmpty || status.contains('No readings.')) return Colors.blue;
    return status == "Normal"
        ? const Color.fromARGB(255, 226, 205, 16)
        : status == "Warning"
        ? AppColors.warningStatus
        : AppColors.criticalStatus;
  }
}
