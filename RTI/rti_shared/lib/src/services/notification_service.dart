import 'package:rti_shared/rti_shared.dart';

class NotificationService {
  final Logger _logger = Logger("NotificationService");
  final List<NotificationListener> _listeners = [];

  NotificationService() {
    // TESTING ONLY
    Future.delayed(Duration(seconds: 2), () {
      pushNotification(Notification("Test notification", "This is a description", NotificationLevel.info));
    });
  }

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