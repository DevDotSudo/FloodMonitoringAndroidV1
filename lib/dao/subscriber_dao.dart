import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriberDao {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference subscribersRef =
      FirebaseFirestore.instance.collection('SUBSCRIBERS');

  Future<String> registerSubscriber(Map<String, dynamic> phoneSubs) async {
    try {
      DocumentReference docRef = await subscribersRef.add(phoneSubs);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to register subscriber: $e');
    }
  }

  Future<Map<String, dynamic>> loginSubscriber(
      Map<String, dynamic> phoneLogin) async {
    try {
      final String email = phoneLogin['email'];
      final String password = phoneLogin['password'];

      QuerySnapshot querySnapshot = await subscribersRef
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Exception('Invalid email or password.');
      }
    } catch (e) {
      throw Exception('Failed to login subscriber: $e');
    }
  }
}