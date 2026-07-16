# CẨM NANG PHẢN BIỆN KỸ THUẬT - NOVEL READER APP

Tài liệu này giải thích chi tiết cấu trúc kiến trúc, thuật toán và giải pháp lập trình UI/UX trong ứng dụng Đọc Truyện Tiểu Thuyết nhằm tối ưu hóa hiệu năng, tiết kiệm bộ nhớ RAM và kiến tạo trải nghiệm nghệ thuật nhập vai (Artistic Immersive Experience).

---

## PHẦN 1: CƠ CHẾ REGEX MARKUP PARSER VÀ LUỒNG NẠP BẤT ĐỒNG BỘ TIẾT KIỆM RAM

### 1. Luồng dữ liệu tối ưu RAM & Defensive Coding đúp
- Thay vì tải trước toàn bộ văn bản của tất cả các chương truyện lên RAM, ứng dụng chỉ đọc nội dung của đúng chương hiện tại thông qua `rootBundle.loadString(txtPath)` được bọc trong một `FutureBuilder`.
- **Cơ chế phân giải đường dẫn đúp**: Để ngăn chặn lỗi đặt tên file sai biệt (mismatch) giữa `ngo-dong-chuong-` và `ngo-ngo-dong-chuong-` trên ổ cứng, hàm `loadContent()` của lớp `Chapter` thực hiện try-catch đúp: Nếu đường dẫn chính lỗi, nó tự động hoán đổi hậu tố tên file để nạp lại. Nếu vẫn lỗi hoặc file rỗng, nó trả về thông báo phòng thủ: *"Nội dung chương này đang được cập nhật, độc giả vui lòng quay lại sau!"* mà không bao giờ gây treo/crash app.

### 2. Thuật toán phân tách RegEx Parser
Trong phương thức `parseParagraphs(String content)` của lớp `Chapter`, ta sử dụng biểu thức chính quy (Regular Expression) để bóc tách các lệnh đổi vibe:
- Biểu thức chính quy: `r'^\[THEME:(PEACE|HORROR)\](.*)$'`
- **Nguyên lý hoạt động**:
  1. Duyệt qua từng dòng trong văn bản thô sau khi tách dòng bằng dấu xuống dòng `\n`.
  2. Dòng nào khớp với cấu trúc `[THEME:vibe_name] nội_dung` sẽ được tách làm hai nhóm: Nhóm 1 chứa chuỗi Vibe (`PEACE` hoặc `HORROR`), Nhóm 2 chứa chuỗi text sạch đã loại bỏ nhãn lệnh.
  3. Dòng nào không khớp sẽ mặc định gán vibe là `NORMAL`.
  4. Đóng gói dòng đó vào một đối tượng `ParagraphBlock` siêu nhẹ.
- **Lợi ích**: Tách biệt hoàn toàn phần xử lý logic hiển thị và phần văn bản thô, tránh việc duyệt chuỗi nhiều lần trong hàm `build()`.

---

## PHẦN 2: THUẬT TOÁN DỆT GRADIENT CHỮ BẰNG SHADERMASK, BLENDMODE VÀ DYNAMIC GOOGLE FONTS

Để tạo nên nét chữ đổ dải màu nghệ thuật mịn màng bám khít nét thanh đậm thay vì dải màu phẳng công nghiệp, chúng ta kết hợp `ShaderMask` và `BlendMode.srcIn`:

### 1. Mã nguồn dệt màu chữ
```dart
ShaderMask(
  shaderCallback: (bounds) {
    return LinearGradient(
      colors: textGradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds);
  },
  blendMode: BlendMode.srcIn,
  child: Text(paragraphText, style: TextStyle(...)),
)
```

### 2. Nguyên lý hoạt động của `BlendMode.srcIn`
- `ShaderMask` nhận vào một `shaderCallback` tạo ra một dải gradient tuyến tính (`LinearGradient`) có tọa độ giới hạn khít bằng khung hình chữ nhật (`bounds`) của đoạn văn bản nằm bên dưới.
- `BlendMode.srcIn` hoạt động dựa trên thuật toán pha trộn điểm ảnh (Pixel Blending): Nó giữ lại phần hình ảnh giao nhau giữa nguồn (Source - dải màu Gradient) và đích (Destination - biên dạng nét của các ký tự chữ).
- Điều này có nghĩa là màu sắc dải Gradient chỉ hiển thị lấp đầy đúng phần thân nét chữ thanh đậm, trong khi toàn bộ nền của chữ vẫn hoàn toàn trong suốt. Tính năng này chặn được hoàn toàn hiện tượng bôi đen tì tay vốn xảy ra khi dùng `SelectableText`.

### 3. Nạp phông chữ động qua `google_fonts`
- Không sử dụng việc khai báo phông chữ cứng trong dự án gây nặng file cài đặt (.apk), ứng dụng sử dụng gói thư viện `google_fonts` để tải động phông chữ được chọn từ bảng setting (Lora, Merriweather, Quicksand, Roboto, Inter).
- Gọi hàm động: `GoogleFonts.getFont(selectedFont, textStyle: ...)` giúp nạp và render phông chữ trực tiếp từ bộ nhớ đệm (hoặc tải từ máy chủ Google nếu chưa có), tăng tính tùy biến cao cho trải nghiệm văn học độc giả.

---

## PHẦN 3: LOGIC TOÁN HỌC ĐIỀU KHIỂN HỆ THỐNG HẠT ĐỘNG VÀ BÓNG MỜ CHU KỲ (MATH-DRIVEN ANIMATION OVERLAY)

Hệ thống hoạt họa chạy ở lớp nền trung gian sử dụng `CustomPainter` kết hợp một vòng lặp `AnimationController` liên tục tuần hoàn để cập nhật tọa độ hạt theo thời gian thực (60 FPS).

### 1. Mô hình vật lý của các Vibe hạt
- **Bong bóng nước (BUBBLES - Hồ Điệp & Kình Ngư)**:
  - Tọa độ Y giảm dần theo tốc độ để hạt trôi lên: $y = y - speed$.
  - Tọa độ X dao động điều hòa theo hàm hình sin dựa trên góc xoay: $x = x + \sin(\theta) \times driftSpeed$.
  - Khi bong bóng bay vọt lên mép trên màn hình ($y < -size$), nó được tái chế đưa về đáy màn hình ($y = screenHeight + 20$) với tọa độ X và kích thước ngẫu nhiên mới để tiết kiệm RAM.
- **Lá rơi mùa thu (LEAVES - Ngõ Ngô Đồng)**:
  - Tọa độ Y tăng dần theo tốc độ để rơi xuống: $y = y + speed$.
  - Tọa độ X lắc lư biên độ rộng mô phỏng lá chao lượn trong gió: $x = x + \sin(\theta) \times driftSpeed \times 1.2$.
  - Khi rơi quá mép dưới màn hình, tái chế đưa về đỉnh.
- **Chim hải yến bay (SWALLOWS - Hà Thanh Hải Yến)**:
  - Tọa độ X giảm dần để bay từ phải sang trái: $x = x - speed \times 1.2$.
  - Tọa độ Y dập dềnh nhẹ theo hàm hình sin: $y = y + \sin(\theta) \times driftSpeed \times 0.4$.

### 2. Bóng mờ chuyển động chu kỳ (Giant Silhouette Watermark)
- Để tạo cảm giác nhập vai sâu sắc, ứng dụng duy trì một bộ định thời đếm tick. Cứ sau mỗi chu kỳ khoảng 20-30 giây, hệ thống kích hoạt vẽ một bóng mờ khổng lồ lướt qua màn đọc nền chìm:
  - **Whale (Cá voi)**: Bơi chầm chậm chéo lên lướt qua nền bằng cách tăng dần tọa độ $x$, dao động chiều cao Y theo hàm $\sin(progress \times 2\pi)$.
  - **Butterfly (Cánh bướm)**: Bay xiên vút lên và đập cánh bằng cách tăng $x$, giảm $y$ kèm theo xoay lắc lư liên tục.
  - **Maple Leaf (Lá phong lớn)**: Trôi chéo xuống và xoay tròn liên tục bằng cách áp một ma trận xoay góc $\theta = progress \times 4\pi$.
  - **Swallow (Hải yến khổng lồ)**: Bay lướt nhanh từ phải qua trái theo chu kỳ dạng sóng.
- Toàn bộ các bóng mờ này được vẽ bằng đối tượng hình học `Path` phức tạp và khống chế Opacity cực kỳ mờ ảo (0.015 - 0.02) nằm ở lớp trung gian chìm sâu dưới trang sách để không cản trở thị giác độc giả.

---

## PHẦN 4: LẬP TRÌNH SCROLLNOTIFICATION VÀ TRI-STATE STATE MANAGEMENT LAN TỎA KHÍ QUYỂN

### 1. Nhận diện hướng cuộn thông minh ẩn/hiện thanh công cụ
Chúng ta bọc toàn bộ khung danh sách đọc trong một `NotificationListener<ScrollNotification>` để bắt các gói tin sự kiện cuộn màn hình mà không cần dùng `ScrollController.addListener` quá nhiều gây quá tải Render:
- **Ẩn công cụ (Scroll Down)**: Khi nhận sự kiện `ScrollUpdateNotification` có `scrollDelta > 0`, chứng tỏ người dùng đang vuốt ngón tay lên để kéo trang xuống đọc chữ. Lập tức ẩn Header và Footer.
- **Hiện công cụ (Scroll Up)**: Khi `scrollDelta < 0`, chứng tỏ độc giả đang vuốt xuống để đọc lại phần trên. Lập tức hiện thanh công cụ để chuẩn bị thao tác.
- **Kịch đáy (Max Scroll)**: Khi `pixels >= maxScrollExtent`, tự động hiện lại công cụ để người dùng chuyển chương hoặc bookmark.

### 2. Overscroll đổi chương kế tiếp
- Khi độc giả vuốt kịch đáy trang đọc thêm một lần nữa, hệ thống ném ra sự kiện `OverscrollNotification` có `overscroll > 0.0`.
- Ta tiến hành kiểm tra thời gian (Debounce 2 giây) để tránh đổi liên tục. Nếu đủ điều kiện, tự động gọi hàm tiến chương `_goToNextChapter()`, reset vị trí cuộn lên đỉnh màn hình bằng `jumpTo(0.0)`.

### 3. Tri-state Theme & Global Vibe Spillover
- Hệ thống quản lý theme lưu trữ một biến trạng thái `themeModeIndex` nhận 3 giá trị: `0` (Light), `1` (Dark), `2` (Book Sync).
- Khi chế độ `themeModeIndex == 2` hoạt động:
  1. Khi người dùng vào trang đọc chương của Cuốn sách X, ID của cuốn sách được cập nhật vào SharedPreferences với khoá `lastReadBookId`.
  2. Khi nhấn Back quay ra ngoài `HomeScreen` và `DetailScreen`, hệ thống đọc `lastReadBookId` từ Preferences và gọi phương thức `getVibeConfig(...)` để lấy chính xác dải màu Gradient bám sát vibe của cuốn sách cuối cùng vừa đọc đó.
  3. Biến đổi đồng loạt phông chữ, dải màu gradient nền của toàn bộ ứng dụng qua `AnimatedContainer` và cấu hình `fontFamily` trong `ThemeData`. Đây chính là hiện tượng lan tỏa khí quyển Global Vibe Spillover nghệ thuật.

---

## PHẦN 5: THUẬT TOÁN BỘ LỌC NÂNG CAO (TAG INTERSECTION) BẰNG EVERY

Tại `HomeScreen`, khi người dùng chọn đồng thời nhiều tag thể loại (Ví dụ chọn cả "Thanh xuân", "Đô thị", "Ngược tâm"), chúng ta thực hiện phép toán giao tập hợp nâng cao:

### 1. Thuật toán Dart
```dart
final filteredBooks = mockBooks.where((book) {
  if (_selectedTags.isEmpty) return true;
  return _selectedTags.every((tag) => book.tags.contains(tag));
}).toList();
```

### 2. Giải thích toán học
- Phương thức `.every` của Dart Collection là hiện thân của lượng từ **VỚI MỌI** ($\forall$) trong Toán học logic.
- Dòng lệnh yêu cầu: *"Một cuốn sách chỉ được giữ lại trong danh sách hiển thị nếu VỚI MỌI tag $t$ nằm trong tập hợp các tag người dùng đang tích chọn (`_selectedTags`), tag $t$ đó BẮT BUỘC phải tồn tại trong danh sách tag thuộc tính của cuốn sách (`book.tags`)"*.
- Phép toán này lọc ra phần giao nhau chính xác tuyệt đối của các tập hợp thể loại thay vì phép toán HOẶC (`.any`) vốn chỉ tìm bộ truyện có chứa một trong các tag riêng rẽ.
