import 'package:cloud_firestore/cloud_firestore.dart';


class SubscriberDao {
  Future<String> registerSubscriber(Map<String, dynamic> phoneSubs) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collectionReference = firestore.collection('SUBSCRIBERS');

    try {
      DocumentReference docRef = await collectionReference.add(phoneSubs);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add admin: $e');
    }
  }
}
