Future<String> fetchData() async {
  return await Future.delayed(
    Duration(seconds: 2),
    () => "Data loaded successfully!",
  );
}

Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    yield i;
    await Future.delayed(Duration(seconds: 1));
  }
}

void main() async {
  print("--- Exercise 5: Async & Null Safety ---");

  String? nullableName;
  // nullableName = "Nhat Minh";

  print("Name: ${nullableName ?? 'Guest'}");

  print("Fetching data...");
  String result = await fetchData();
  print(result);

  print("Starting stream...");
  await for (int val in countStream(3)) {
    print("Stream value: $val");
  }
  print("Done!");
}
