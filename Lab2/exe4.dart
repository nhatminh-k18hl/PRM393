class Car {
  String brand;

  Car(this.brand);

  Car.luxury() : brand = "Rolls Royce";

  void drive() {
    print("$brand is driving...");
  }
}

class ElectricCar extends Car {
  int batteryLife;

  ElectricCar(String brand, this.batteryLife) : super(brand);

  @override
  void drive() {
    print("$brand (Electric) is driving silently with $batteryLife% battery.");
  }
}

void main() {
  print("--- Exercise 4: OOP ---");

  Car myCar = Car("Toyota");
  myCar.drive();

  Car dreamCar = Car.luxury();
  dreamCar.drive();

  ElectricCar myTesla = ElectricCar("Tesla", 95);
  myTesla.drive();
}
