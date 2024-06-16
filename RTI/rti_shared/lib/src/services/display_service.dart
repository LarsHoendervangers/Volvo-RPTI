abstract class IDisplayService {
  void turnOn();
  void turnOff();

  void setBrightness();
  void setDisplayMode(DisplayMode mode);
}

enum DisplayMode {
  off, rgb, ntsc, pal
}