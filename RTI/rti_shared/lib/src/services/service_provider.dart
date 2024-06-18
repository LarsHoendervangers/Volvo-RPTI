import 'dart:io';

import 'package:rti_shared/rti_shared.dart';
import 'package:rti_shared/src/services/emulator/canbus_service.dart';
import 'package:rti_shared/src/services/emulator/display_service.dart';
import 'package:rti_shared/src/services/emulator/gps_service.dart';
import 'package:rti_shared/src/services/emulator/headunit_service.dart';
import 'package:rti_shared/src/services/emulator/infrared_service.dart';
import 'package:rti_shared/src/services/emulator/twinwire_service.dart';

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
  late IGPSService gpsService;

  ServiceProvider._() {
    notificationService = NotificationService();
    if (Platform.isWindows) {
      _logger.log(LogLevel.info, "Platform: Windows, using emulated services.");
      twinWireService = EmulatedTwinWireService();
      canbusService = EmulatedCanbusService(twinWireService);
      displayService = EmulatedDisplayService(twinWireService);
      infraRedService = EmulatedInfraRedService(twinWireService);
      headUnitService = EmulatedHeadUnitService(twinWireService);
      gpsService = EmulatedGPSService(twinWireService);
    }
    _logger.log(LogLevel.info, "Services ready!");
  }
}

enum Service {
  canbus, display, infrared, headunit, twinwire
}