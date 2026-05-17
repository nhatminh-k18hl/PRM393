void main() {

  List<int> numbers = [10, 25, 30, 45, 10];

  int sum = numbers[0] + numbers[1];
  bool isGreater = numbers[2] > numbers[0];

  Set<int> uniqueNumbers = {1, 2, 3, 3, 4}; 
  Map<String, dynamic> userMap = {
    'id': 'HE186934',
    'role': 'Admin'
  };

  numbers.add(60);
  uniqueNumbers.remove(1);
  userMap['name'] = 'Minh';

  print("--- Exercise 2: Collections & Operators ---");
  print("List: $numbers");
  print("Set (Unique): $uniqueNumbers");
  print("Map Access (ID): ${userMap['id']}");
  print("Is numbers[2] > numbers[0]? $isGreater");


  String accessLevel = userMap['role'] == 'Admin' ? 'Full Access' : 'Limited';
  print("Access Level: $accessLevel");
}