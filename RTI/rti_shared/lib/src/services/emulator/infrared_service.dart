import 'package:rti_shared/rti_shared.dart';

class EmulatedInfraRedService implements IInfraRedService {
  final Logger _logger = Logger("EmulatedInfraRedService");

  ITwinWireService _i2cService;

  EmulatedInfraRedService(this._i2cService);

  
}