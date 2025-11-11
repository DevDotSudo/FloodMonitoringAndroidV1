import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_monitoring_android/model/water_level_data.dart';

class WaterLevelService {
  final _waterLevelsRef = FirebaseFirestore.instance.collection('WATER_LEVEL');
  String? _lastStatus;

  Stream<List<WaterLevelDataPoint>> watchWaterLevels() {
    return _waterLevelsRef
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;

          final latestDocs = docs.length > 5
              ? docs.sublist(docs.length - 5)
              : docs;

          return latestDocs.map((doc) {
            return WaterLevelDataPoint(
              time: doc['hour'],
              level: (doc['level'] ?? 0).toDouble(),
              status: doc['status'],
            );
          }).toList();
        });
  }

  void startListening() {
    watchWaterLevels().listen((data) {
      if (data.isEmpty) return;
      final status = data.last.status;

      if (status != _lastStatus) {
        _lastStatus = status;
      }
    });
  }
}
