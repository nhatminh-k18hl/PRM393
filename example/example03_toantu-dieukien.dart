/*
  expr1 ? expr2 : expr3;
  Nếu expr1 đúng thì trả về giá trị của expr2, ngược lại trả về giá trị của expr3.

  expr1 ?? expr2;
  Nếu expr1 khác null thì trả về giá trị của expr1, ngược lại trả về giá trị của expr2.
*/

void main() {
  var kiemTra = (100 % 2 == 0) ? "100 là số chẵn" : "100 là số lẻ";
  print(kiemTra);

  var x = 100;
  var y = x ?? 50;
  print(y);

  int? z;
  y = z ?? 30;
  print(y);
}
