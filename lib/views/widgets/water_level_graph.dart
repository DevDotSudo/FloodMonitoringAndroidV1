import 'package:flood_monitoring_android/model/water_level_data.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WaterLevelGraph extends StatelessWidget {
  final List<WaterLevelDataPoint> dataPoints;

  const WaterLevelGraph({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: LineChart(_buildChartData(dataPoints)),
      ),
    );
  }

  LineChartData _buildChartData(List<WaterLevelDataPoint> data) {
    if (data.isEmpty) {
      return LineChartData(
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [],
      );
    }

    final maxY = data.map((e) => e.level).reduce((a, b) => a > b ? a : b) * 1.2;
    final status = WaterLevelDataPoint.getWaterStatus();
    final lineColor = status == "Normal"
        ? Colors.green.shade600
        : status == "Warning"
            ? Colors.orange.shade600
            : Colors.red.shade600;

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItems: (spots) => spots.map((spot) {
            return LineTooltipItem(
              '${data[spot.x.toInt()].time}\n',
              const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text: '${spot.y.toStringAsFixed(1)}m',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          // Handle touch events if needed
        },
        handleBuiltInTouches: true,
      ),
      
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _calculateLeftInterval(maxY < 5 ? 5 : maxY),
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.shade200,
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      ),
      
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: _calculateBottomInterval(data.length),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= data.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  data[index].time,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameSize: 28,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: _calculateLeftInterval(maxY < 5 ? 5 : maxY),
            getTitlesWidget: (value, meta) {
              if (value < 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${value.toInt()}m',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      
      minX: 0,
      maxX: data.length.toDouble() - 1,
      minY: 0,
      maxY: maxY < 5 ? 5 : maxY,
      
      lineBarsData: [
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.level))
              .toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          color: lineColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: lineColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                lineColor.withOpacity(0.3),
                lineColor.withOpacity(0.1),
                lineColor.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _calculateBottomInterval(int dataLength) {
    if (dataLength <= 8) return 1;
    if (dataLength <= 12) return 2;
    if (dataLength <= 24) return 3;
    return (dataLength / 6).ceil().toDouble();
  }

  double _calculateLeftInterval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    return (maxY / 5).ceil().toDouble();
  }
}