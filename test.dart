void main() {
  // List: Danh sách có thứ tự (cho phép trùng lặp)
  List<String> devices = ['Android', 'iPhone', 'Web', 'Android']; [cite: 15, 43]
  
  // Set: Tập hợp các phần tử duy nhất
  Set<String> uniquePlatforms = {'Android', 'iPhone', 'Web', 'Android'}; [cite: 16, 43]
  
  // Map: Cặp Key-Value
  Map<String, dynamic> projectInfo = {
    'name': 'Flutter Lab',
    'version': 3.41,
    'isStable': true
  }; [cite: 17, 43]

  print(uniquePlatforms); // Kết quả sẽ tự loại bỏ 'Android' trùng
}