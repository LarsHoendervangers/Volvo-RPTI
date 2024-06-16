class CanbusMessage {
  int id;
  List<int> data;

  CanbusMessage(this.id, this.data);
}

enum CanbusError {
  txFail,
  rxFail,
  initFail
}

abstract class ICanbusService {
  void send(CanbusMessage msg);
  void onMessage(void Function(CanbusMessage msg) callback);
  void onError(void Function(CanbusError err) callback);
}