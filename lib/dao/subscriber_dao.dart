import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_monitoring_android/model/app_subscriber.dart';

class SubscriberDao {
  final CollectionReference _subscribersRef = FirebaseFirestore.instance
      .collection('SUBSCRIBERS');

  Future<void> registerSubscriberEmailAndPassword(
    UserCredential userCredentials,
    Map<String, dynamic> phoneSubs,
  ) async {
    try {
      await _subscribersRef.doc(userCredentials.user?.uid ?? '').set(phoneSubs);
    } catch (e) {
      throw Exception('Failed to register subscriber: $e');
    }
  }

  Future<void> registerSubscriberGoogleSignin(
    Map<String, dynamic> phoneSubs,
  ) async {
    try {
      await _subscribersRef.doc(phoneSubs['id']).set(phoneSubs);
    } catch (e) {
      throw Exception('Failed to register subscriber: $e');
    }
  }

  Future<String?> getSubscriberFullName(String userId) async {
    try {
      DocumentSnapshot doc = await _subscribersRef.doc(userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['fullName'] as String?;
      }
      return null;
    } catch (e) {
      throw Exception("Failed to get subscriber full name: $e");
    }
  }

  Future<AppSubscriber?> fetchSubscriberInfo(String id) async {
    try {
      DocumentSnapshot doc = await _subscribersRef.doc(id).get();

      if (doc.exists && doc.data() != null) {
        return AppSubscriber.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch subscriber info: $e');
    }
  }

  Future<void> updateSubscriberInfo(AppSubscriber subscriber) async {
    try {
      await _subscribersRef.doc(subscriber.id).update(subscriber.toMap());
    } catch (e) {
      throw Exception("Failed to update subscriber info: $e");
    }
  }

  Future<void> deleteSubscriber(String id) async {
    try {
      await _subscribersRef.doc(id).delete();
    } catch (e) {
      throw Exception("Failed to delete subscriber info: $e");
    }
  }
}
