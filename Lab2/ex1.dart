void main() {
  // 1. Khai báo các kiểu dữ liệu nguyên thủy
  int age = 21;
  double gpa = 2.8;
  String name = "Nhat Minh";
  bool isStudent = true;

  print("--- Exercise 1: Basic Syntax ---");
  print("Student Name: $name");
  print("Age: $age");
  print("GPA: $gpa");
  print("Status: ${isStudent ? 'Active' : 'Inactive'}");

  print("Next year, I will be ${age + 1} years old.");
}
