abstract class IGPSService {
  void subscribe(GPSListener listener);
  void unsubscribe(GPSListener listener);
}

abstract class GPSListener {
  void onBearingChanged(double bearing);
  void onSpeedChanged();
  void onAltitudeChanged();
  void onTimeChanged();
}