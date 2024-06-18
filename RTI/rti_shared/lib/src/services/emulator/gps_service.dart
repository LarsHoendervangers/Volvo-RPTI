import 'package:rti_shared/rti_shared.dart';

class EmulatedGPSService implements IGPSService {
  final Logger _logger = Logger("EmulatedGPSService");
  final List<GPSListener> _listeners = [];
  final ITwinWireService _twinWireService;

  EmulatedGPSService(this._twinWireService);

  @override
  void subscribe(GPSListener listener) {
    _listeners.add(listener);
  }

  @override
  void unsubscribe(GPSListener listener) {
    _listeners.remove(listener);
  }
}