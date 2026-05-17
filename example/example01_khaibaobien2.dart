// gan bien toan cuc

// String name1 = "An";
// String ?name1;

// Khai bao bien theo Lazy initialization (khoi tao treo)
late String name2;

void main() {
  name2 = "Minh";
  // name2 = null;
  print(name2);

  final tuoi = 20;
  // final tuoi = 21; // loi: khong the gan lai gia tri cho bien final

  final age;
  age = 18;
  // age = 19; // loi: khong the gan lai gia tri cho bien final

  const pi = 3.14;
  // const gravity; // loi: bien const phai duoc khoi tao ngay khi khai bao, khong the khoi tao treo
  // gravity = 9.8;
}
