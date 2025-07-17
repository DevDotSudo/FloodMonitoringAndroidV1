class WaterLevelDataPoint {
  final String time;
  final double level;
  final String status;

  WaterLevelDataPoint({
    required this.time,
    required this.level,
    required this.status,
  });

  static double getCurrentWaterLevel() {
    if (dummyHourlyData.isEmpty) return 0.0;
    return dummyHourlyData.last.level;
  }

  static String getWaterStatus() {
    if (dummyHourlyData.isEmpty) return 'No readings.';
    return dummyHourlyData.last.status;
  }

  static List<WaterLevelDataPoint> dummyHourlyData = [
    WaterLevelDataPoint(time: '1 AM', level: 1.9, status: 'Normal'),
    WaterLevelDataPoint(time: '4 AM', level: 1.8, status: 'Normal'),
    WaterLevelDataPoint(time: '7 AM', level: 1.6, status: 'Normal'),
    WaterLevelDataPoint(time: '10 AM', level: 2.5, status: 'Warning'),
    WaterLevelDataPoint(time: '1 PM', level: 1.4, status: 'Normal'),
    WaterLevelDataPoint(time: '4 PM', level: 1.3, status: 'Normal'),
    WaterLevelDataPoint(time: '7 PM', level: 1.2, status: 'Normal'),
    WaterLevelDataPoint(time: '10 PM', level: 4.5, status: 'Warning'),
  ];
}
