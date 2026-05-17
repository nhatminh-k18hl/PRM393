void main() {
  var a = 2;
  print(a);

  // ??= :se gan gia tri neu bien dang null

  int? b;
  b ??= 5;
  print('b = $b');

  b ??= 10; // khi nay b khongcon null nua nen khong duoc gan lai gia tri moi
  print('b = $b');
}
