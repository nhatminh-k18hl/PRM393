String checkGrade(double score) {
  if (score >= 8.0) return "Excellent";
  if (score >= 5.0) return "Pass";
  return "Fail";
}

void printInfo(String message) => print("Info: $message");

void main() {
  print("--- Exercise 3: Control Flow ---");

  double myScore = 8.5;
  print("Score $myScore is: ${checkGrade(myScore)}");

  int day = 3;
  switch (day) {
    case 1:
      print("Monday");
      break;
    case 2:
      print("Tuesday");
      break;
    case 3:
      print("Wednesday");
      break;
    default:
      print("Other day");
  }

  List<String> tools = ['Flutter', 'Dart', 'Git'];

  print("Loop with for-in:");
  for (var tool in tools) {
    print("- $tool");
  }

  print("Loop with forEach:");
  tools.forEach((t) => print("Tool: $t"));

  printInfo("Control flow practice completed.");
}
