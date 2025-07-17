import 'package:flood_monitoring_android/model/water_level_data.dart';
import 'package:flood_monitoring_android/views/widgets/water_level_graph.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section with better spacing
          _buildWelcomeSection(),
          
          const SizedBox(height: 24),
          
          // Status Cards with improved layout
          _buildStatusCards(),
          
          const SizedBox(height: 24),
          
          // Water Level Chart Section
          _buildChartSection(),
        ],
      ),
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
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Eric Dave Cala-or',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        Divider(
          color: Colors.grey[200],
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildStatusCards() {
    return Column(
      children: [
        // First row with River Status and Water Level
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                icon: Icons.warning_rounded,
                iconColor: Colors.orange.shade600,
                title: 'River Status',
                value: 'Warning',
                valueColor: Colors.orange.shade700,
                backgroundColor: Colors.orange.shade50,
                borderColor: Colors.orange.shade200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatusCard(
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blue.shade600,
                title: 'Current Water Level',
                value: '4.5m',
                valueColor: Colors.blue.shade700,
                backgroundColor: Colors.blue.shade50,
                borderColor: Colors.blue.shade200,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Bridge status card - full width
        _buildStatusCard(
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green.shade600,
          title: 'Bridge is passable',
          value: '',
          valueColor: Colors.green.shade700,
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_rounded,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Live Water Level Monitoring',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
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
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
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
                dataPoints: WaterLevelDataPoint.dummyHourlyData,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    required Color backgroundColor,
    required Color borderColor,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}