import 'package:cloud_firestore/cloud_firestore.dart';

class AppWarningMessage {
  final _warningRef = FirebaseFirestore.instance.collection('WARNING_MESSAGE');

  Future<String?> getWarningMessage() async {
    try {
      DocumentSnapshot doc = await _warningRef.doc("message").get();
      if (doc.exists) {
        return doc["message"] as String?;
      }
      return null;
    } catch (e) {
      print("Error getting warning message: $e");
      return null;
    }
  }

  Stream<String?> watchWarningMessage() {
    return _warningRef.doc("message").snapshots().map((doc) {
      if (doc.exists) {
        return doc["message"] as String?;
      }
      return null;
    });
  }
}
