void main() {
  // int kieu so nguyen
  int x = 100;
  // double kie so thuc
  double y = 3.14;
  // num co the la so nguyen hoac so thuc
  num n = 10;
  num m = 4.5;

  // Chuyen chuoi sang so nguyen
  var one = int.parse('1');
  print(one == 1 ? 'TRUE' : 'FALSE');

  // Chuyen chuoi sang so thuc
  var onePointOne = double.parse('1.1');
  print(onePointOne == 1.1);

  // So nguyen ==> chuoi
  String oneAsString = 1.toString();
  print(oneAsString);

  // So thuc ==> chuoi
  String piAsString = 3.14159.toStringAsFixed(2);
  print(piAsString);
}
