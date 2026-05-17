/// Ghi chu documentation - example 01
/* Khai bao bien voi Dart:';
  - Khai bao voi var (giong js de tu suy luan kieu du lieu)
  - Khai bao voi kieu du lieu cu the (String, int, double, bool)
  - Khai bao bang Object (kieu du lieu cha, co the chua tat ca cac kieu du lieu con)
*/

/*
void main() {
/* viet gan giong c
  */

  String name = "Minh";
  // Khai bao bien tuoi
  int age = 21;

  // Neu tuoi >= 18 thi in ra "Hello $name"
  if(age >= 18) {
    print("Hello $name");
  }
  

}

*/

// Khai bao bien
void main() {
  //var
  var name = "Minh"; //String
  var tuoi = 18; //int
  String ten = "Minh";
  int age = 18;

  //Object
  Object tenNguoidung = "Minh";
  int tuoiNguoidung;

  ///tuoiNguoidung; // khai bao ma khong khoi tao gia tri, mac dinh la null

  String? ten1;
  ten1 = null;
  ten1 = "Minh";
}
