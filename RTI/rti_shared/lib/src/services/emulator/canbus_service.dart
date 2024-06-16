import 'package:rti_shared/rti_shared.dart';

class EmulatedCanbusService implements ICanbusService {
  final Logger _logger = Logger("EmulatedCanbusService");
  ITwinWireService i2cService;

  EmulatedCanbusService(this.i2cService);

  @override
  void send(CanbusMessage msg) {
    
  }
  
  @override
  void onError(void Function(CanbusError msg) callback) {
    
  }
  
  @override
  void onMessage(void Function(CanbusMessage err) callback) {
    
  }
}