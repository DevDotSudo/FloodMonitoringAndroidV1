import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_monitoring_android/dao/subscriber_dao.dart';
import 'package:flood_monitoring_android/model/app_subscriber.dart';
import 'package:flood_monitoring_android/utils/encrypt_util.dart';
import 'package:flood_monitoring_android/utils/hash_util.dart';

class SubscriberService {
  final _subscriberDao = SubscriberDao();
  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> storeFillup(Map<String, dynamic> phoneSubs) async {
    final encryptedSubscriber = AppSubscriber(
      id: phoneSubs['id'] ?? '',
      fullName: Encryption.encryptText(phoneSubs['fullName'] ?? ''),
      address: Encryption.encryptText(phoneSubs['address'] ?? ''),
      gender: Encryption.encryptText(phoneSubs['gender'] ?? ''),
      age: Encryption.encryptText(phoneSubs['age'] ?? ''),
      phoneNumber: Encryption.encryptText(phoneSubs['phoneNumber'] ?? ''),
      registeredDate: phoneSubs['registeredDate'] ?? '',
      viaSMS: phoneSubs['viaSMS'],
      viaApp: phoneSubs['viaApp'],
    );
    await _subscriberDao.registerSubscriberGoogleSignin(
      encryptedSubscriber.toMap(),
    );
  }

  Future<void> registerSubscriberEmailAndPassword(
    Map<String, dynamic> phoneSubs,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: phoneSubs['email'],
        password: phoneSubs['password'],
      );

      final encryptedSubscriber = AppSubscriber(
        id: phoneSubs['id'] ?? '',
        fullName: Encryption.encryptText(phoneSubs['fullName'] ?? ''),
        email: Encryption.encryptText(phoneSubs['email'] ?? ''),
        address: Encryption.encryptText(phoneSubs['address'] ?? ''),
        gender: Encryption.encryptText(phoneSubs['gender'] ?? ''),
        age: Encryption.encryptText(phoneSubs['age'] ?? ''),
        phoneNumber: Encryption.encryptText(phoneSubs['phoneNumber'] ?? ''),
        password: HashPassword().hashPassword(phoneSubs['password'] ?? ''),
        registeredDate: phoneSubs['registeredDate'] ?? '',
        viaSMS: phoneSubs['viaSMS'],
        viaApp: phoneSubs['viaApp'],
      );
      await _subscriberDao.registerSubscriberEmailAndPassword(
        userCredential,
        encryptedSubscriber.toMap(),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = 'An unknown error occurred. Please try again.';
      }
      throw Exception(message);
    }
  }

  Future<UserCredential> loginSubscriber(String email, String password) async {
    try {
      UserCredential user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return user;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      throw Exception(message);
    }
  }

  Future<String?> getDecryptedSubscriberFullName(String userId) async {
    try {
      final encryptedName = await _subscriberDao.getSubscriberFullName(userId);

      if (encryptedName != null && encryptedName.isNotEmpty) {
        return Encryption.decryptText(encryptedName);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to get decrypted subscriber full name: $e");
    }
  }

  Future<AppSubscriber?> getDecryptedSubscriberInfo(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('No user is currently logged in.');
      }

      final encryptedSubs = await _subscriberDao.fetchSubscriberInfo(id);

      if (encryptedSubs == null) return null;

      return AppSubscriber(
        id: encryptedSubs.id,
        fullName: Encryption.decryptText(encryptedSubs.fullName),
        email: encryptedSubs.email != null && encryptedSubs.email!.isNotEmpty
            ? Encryption.decryptText(encryptedSubs.email!)
            : null,
        address: Encryption.decryptText(encryptedSubs.address),
        gender: Encryption.decryptText(encryptedSubs.gender),
        age: Encryption.decryptText(encryptedSubs.age),
        phoneNumber: Encryption.decryptText(encryptedSubs.phoneNumber),
        password: encryptedSubs.password,
        registeredDate: encryptedSubs.registeredDate,
        viaSMS: encryptedSubs.viaSMS,
        viaApp: encryptedSubs.viaApp,
      );
    } catch (e) {
      throw Exception('Failed to decrypt subscriber info: $e');
    }
  }


  Future<void> updateSubscriberInfo(AppSubscriber subscriber) async {
    try {
      final encryptedSubscriber = AppSubscriber(
        id: subscriber.id,
        fullName: Encryption.encryptText(subscriber.fullName),
        email: subscriber.email != null
            ? Encryption.encryptText(subscriber.email!)
            : null,
        address: Encryption.encryptText(subscriber.address),
        gender: Encryption.encryptText(subscriber.gender),
        age: Encryption.encryptText(subscriber.age),
        phoneNumber: Encryption.encryptText(subscriber.phoneNumber),
        password: subscriber.password,
        registeredDate: subscriber.registeredDate,
        viaSMS: subscriber.viaSMS,
        viaApp: subscriber.viaApp,
      );

      await _subscriberDao.updateSubscriberInfo(encryptedSubscriber);
    } catch (e) {
      throw Exception("Error in service while updating: $e");
    }
  }

  Future<void> deleteSubscriber(String id) async {
    try {
      await _subscriberDao.deleteSubscriber(id);
    } catch (e) {
      throw Exception("Failed to delete subscriber info: $e");
    }
  }
}
