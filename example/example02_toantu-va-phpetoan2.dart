void main() {
  print(2 == 2);
  print(2 != 3);
  print(5 < 3);

  //kiem tra obj co phai la String
  Object obj = "Hello";
  if (obj is String) {
    print("Obj la mot chuoi");
  }
  if (obj is! String) {
    print("Obj khong phai la mot chuoi");
  }

  // Ep kieu
  String str = obj as String;
  print(str.toUpperCase());
}
