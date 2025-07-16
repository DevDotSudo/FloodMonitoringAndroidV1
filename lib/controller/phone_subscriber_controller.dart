import 'package:flood_monitoring_android/model/app_subscriber.dart';
import 'package:flood_monitoring_android/services/subscriber_service.dart';

class PhoneSubscriberController {
  final _subscriberService = SubscriberService();

  Future<void> registerSubscriber(AppSubscriber phoneSubs) async {
    await _subscriberService.registerSubscriber(phoneSubs.toMap());
  }
}
