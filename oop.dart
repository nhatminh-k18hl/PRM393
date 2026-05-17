class Device {
  String name;
  Device(this.name); // Constructor rút gọn 

  void turnOn() => print('$name is starting...');
}

void main() {
  var myPhone = Device('Google Pixel');
  myPhone.turnOn();
}