class Animal {
  void sound() => "Some";
}

class Dog extends Animal {
  @override
  void sound() => "Woof";
}

void main() {
  var myDog = Dog();
  print(myDog..sound());
}
