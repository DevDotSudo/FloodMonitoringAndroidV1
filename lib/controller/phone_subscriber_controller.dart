import 'package:flood_monitoring_android/model/app_subscriber.dart';
import 'package:flood_monitoring_android/services/subscriber_service.dart';

class PhoneSubscriberController {
  final _subscriberService = SubscriberService();

  Future<void> registerSubscriber(AppSubscriber phoneSubs) async {
    await _subscriberService.registerSubscriberEmailAndPassword(
      phoneSubs.toMap(),
    );
  }

  Future<void> saveFillup(AppSubscriber phoneSubs) async {
    await _subscriberService.storeFillup(phoneSubs.toMap());
  }

  Future<void> loginSubscriber(String email, String password) async {
    await _subscriberService.loginSubscriber(email, password);
  }

  Future<AppSubscriber?> getSubscriberInfo(String id) async {
    return await _subscriberService.getDecryptedSubscriberInfo(id);
  }

  Future<void> updateSubscriberInfo(AppSubscriber subscriber) async {
    await _subscriberService.updateSubscriberInfo(subscriber);
  }

  Future<String?> getSubscriberFullName(String id) async {
    return await _subscriberService.getDecryptedSubscriberFullName(id);
  }

  Future<void> delete(String id) async {
    await _subscriberService.deleteSubscriber(id);
  }
}
