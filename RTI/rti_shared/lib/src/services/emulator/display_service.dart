import 'package:rti_shared/rti_shared.dart';

class EmulatedDisplayService implements IDisplayService {
  final Logger _logger = Logger("EmulatedDisplayService");
  ITwinWireService i2cService;

  EmulatedDisplayService(this.i2cService);

  void _update() {
    
  }

  @override
  void setBrightness() {

  }

  @override
  void setDisplayMode(DisplayMode mode) {
    
  }

  @override
  void turnOff() {
    
  }

  @override
  void turnOn() {
    
  }
}