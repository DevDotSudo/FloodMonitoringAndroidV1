import 'package:flood_monitoring_android/dao/subscriber_dao.dart';
import 'package:flood_monitoring_android/model/app_subscriber.dart';
import 'package:flood_monitoring_android/utils/encrypt_util.dart';
import 'package:flood_monitoring_android/utils/hash_util.dart';

class SubscriberService {
  final _subscriberDao = SubscriberDao();

  Future<void> registerSubscriber(Map<String, dynamic> phoneSubs) async {
    try {
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
          viaSMS: phoneSubs['viaSMS']);
      await _subscriberDao.registerSubscriber(encryptedSubscriber.toMap());
    } catch (e) {
      print('Error : $e');
    }
  }

  Future<void> loginSubscriber(Map<String, dynamic> phonLogin) async {
    try {
      final encryptedLogin = AppSubscriber.credentials(
        email: Encryption.encryptText(phonLogin['email'] ?? ''),
        password: HashPassword().hashPassword(phonLogin['password'] ?? ''),
      );

      await _subscriberDao.loginSubscriber(encryptedLogin.toCredentialsMap());
    } catch (e) {
      print('Error during login: $e');
    }
  }
}