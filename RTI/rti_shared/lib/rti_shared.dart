/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

export 'src/services/service_provider.dart' show ServiceProvider, Service;
export 'src/services/canbus_service.dart' show ICanbusService, CanbusMessage, CanbusError;
export 'src/services/display_service.dart' show IDisplayService, DisplayMode;
export 'src/services/headunit_service.dart' show IHeadUnitService;
export 'src/services/infrared_service.dart' show IInfraRedService;
export 'src/services/twinwire_service.dart' show ITwinWireService;
export 'src/services/notification_service.dart' show NotificationService;
export 'src/services/gps_service.dart' show IGPSService, GPSListener;

export 'src/carplay/carplay.dart' show Carplay;
export 'src/carplay/common.dart' show DongleConfig, DEFAULT_CONFIG, Message, VideoData, Plugged, Unplugged, MessageType, KeyFrame;
 
export 'src/ui/notification.dart' show Notification, NavigationalNotification, MusicNotification, NotificationLevel, NotificationListener;

export 'src/util/logger.dart' show Logger, LogLevel;
export 'src/util/terminal.dart' show Terminal;