import 'dart:io';

import 'package:rti_shared/src/services/canbus_service.dart';
import 'package:rti_shared/src/services/display_service.dart';
import 'package:rti_shared/src/services/emulator/canbus_service.dart';
import 'package:rti_shared/src/services/emulator/display_service.dart';
import 'package:rti_shared/src/services/emulator/headunit_service.dart';
import 'package:rti_shared/src/services/emulator/infrared_service.dart';
import 'package:rti_shared/src/services/emulator/twinwire_service.dart';
import 'package:rti_shared/src/services/headunit_service.dart';
import 'package:rti_shared/src/services/infrared_service.dart';
import 'package:rti_shared/src/services/notification_service.dart';
import 'package:rti_shared/src/services/twinwire_service.dart';
import 'package:rti_shared/src/util/logger.dart';

class ServiceProvider {
  factory ServiceProvider() => _this;
  static final ServiceProvider _this = ServiceProvider._();

  final Logger _logger = Logger("ServiceProvider");

  late ITwinWireService twinWireService;
  late ICanbusService canbusService;
  late IDisplayService displayService;
  late IInfraRedService infraRedService;
  late IHeadUnitService headUnitService;
  late NotificationService notificationService;

  ServiceProvider._() {
    notificationService = NotificationService();
    if (Platform.isWindows) {
      _logger.log(LogLevel.info, "Platform: Windows, using emulated services.");
      twinWireService = EmulatedTwinWireService();
      canbusService = EmulatedCanbusService(twinWireService);
      displayService = EmulatedDisplayService(twinWireService);
      infraRedService = EmulatedInfraRedService(twinWireService);
      headUnitService = EmulatedHeadUnitService(twinWireService);
    }
    _logger.log(LogLevel.info, "Services ready!");
  }
}

enum Service {
  canbus, display, infrared, headunit, twinwire
}