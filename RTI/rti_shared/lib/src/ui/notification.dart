class Notification {
  String title;
  String description;
  NotificationLevel level;
  int visibleDuration;

  Notification(this.title, this.description, this.level, {this.visibleDuration = 4000});
}

class NavigationalNotification extends Notification {
  double distanceToInstruction;

  NavigationalNotification(this.distanceToInstruction, String title, String description, NotificationLevel level) : super(title, description, level);
}

class MusicNotification extends Notification {
  String album;
  String artist;

  MusicNotification(this.album, this.artist, String title, NotificationLevel level) : super(title, "$artist - $album", level);
}

enum NotificationLevel {
  info, warning
}

abstract class NotificationListener {
  void onNotificationPushed(Notification notification);
}