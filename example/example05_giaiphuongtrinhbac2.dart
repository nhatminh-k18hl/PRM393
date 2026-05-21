/*
  ax^2 + bx + c = 0;
 */

import 'dart:math';
import 'dart:io';

void main() {
  double a = 0, b = 0, c = 0;

  // Input a
  do {
    stdout.write('Nhap vao he so a (a khac 0): ');
    String? inputA = stdin.readLineSync();
    if (inputA != null) {
      a = double.tryParse(inputA) ?? 0; // co bat loi
    }

    // Input b
    stdout.write('Nhap vao he so b: ');
    String? inputB = stdin.readLineSync();
    if (inputB != null) {
      b = double.tryParse(inputB) ?? 0; // co bat loi
    }

    //Input c
    stdout.write('Nhap vao he so c: ');
    String? inputC = stdin.readLineSync();
    if (inputC != null) {
      c = double.tryParse(inputC) ?? 0; // co bat loi
    }
  } while (a == 0);

  // Tinh delta
  double delta = b * b - 4 * a * c;

  // Hien thi phuong trinh
  print('Phuong trinh: ${a}x^2 + ${b}x + $c = 0');

  //GPT
  if (delta < 0) {
    print('Phuong trinh vo nghiem');
  } else if (delta == 0) {
    double x = -b / (2 * a);
    print('Phuong trinh co nghiem kep x1 = x2 = ${x.toStringAsFixed(2)}');
  } else {
    double x1 = (-b - sqrt(delta)) / (2 * a);
    double x2 = (-b + sqrt(delta)) / (2 * a);
    print('Phuong trinh co 2 nghiem phan biet: ');
    print('x1 = ${x1.toStringAsFixed(2)}');
    print('x1 = ${x2.toStringAsFixed(2)}');
  }
}
