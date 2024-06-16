import 'package:rti_shared/rti_shared.dart';

class EmulatedHeadUnitService implements IHeadUnitService {
  final ITwinWireService _twinWireService;

  EmulatedHeadUnitService(this._twinWireService);

  @override
  void changeCD() {
    // TODO: implement changeCD
  }

  @override
  void mute() {
    // TODO: implement mute
  }

  @override
  void nextTrack() {
    // TODO: implement nextTrack
  }

  @override
  void prevTrack() {
    // TODO: implement prevTrack
  }

  @override
  void unmute() {
    // TODO: implement unmute
  }

  @override
  void volumeDown() {
    // TODO: implement volumeDown
  }

  @override
  void volumeUp() {
    // TODO: implement volumeUp
  }

}