import 'package:rti_shared/rti_shared.dart';

class NotificationService {
  final Logger _logger = Logger("NotificationService");
  final List<NotificationListener> _listeners = [];

  NotificationService();

  void pushNotification(Notification notification) {
    _logger.log(LogLevel.debug, "A new notification has been pushed, notifying listeners...");
    for (NotificationListener listener in _listeners) {
      listener.onNotificationPushed(notification);
    }
  }

  void subscribe(NotificationListener listener) {
    _listeners.add(listener);
  }

  void unsubscribe(NotificationListener listener) {
    _listeners.remove(listener);
  }
}