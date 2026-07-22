# Tài Liệu Kỹ Thuật Dự Án (`Giải_thích.md`)
**Origami 3D Master (`threed_orimaster`)**

---

## 1. Tổng Quan Dự Án & Cấu Hình Nền Tảng

- **Tên Dự Án**: Origami 3D Master (`threed_orimaster`)
- **Nền Tảng Mục Tiêu**: Flutter Mobile (Android & iOS)
- **Chế Độ Hiển Thị**: Khóa Màn Hình Nằm Ngang (Landscape-Locked mode - hỗ trợ xoay cảm biến 180 độ qua `DeviceOrientation.landscapeLeft` & `DeviceOrientation.landscapeRight`)
- **Mô Hình Kiến Trúc**: Clean Architecture + Provider State Management (`provider: ^6.1.2`). Tách biệt hoàn toàn giữa logic nghiệp vụ, luồng mạng, server HTTP nội cục, và cây giao diện Presentation.

---

## 2. Danh Sách Thư Viện Dependency & Hạ Tầng Cốt Lõi

Toàn bộ các gói phụ thuộc khai báo trong `Code/pubspec.yaml` và thư viện chuẩn:

| Thư Viện / Module | Phiên Bản / Nguồn | Mục Đích Kiến Trúc |
| :--- | :--- | :--- |
| `flutter` | SDK | Bộ khung UI Material Design và bộ dựng đồ họa chính |
| `provider` | `^6.1.2` | Quản lý trạng thái phản ứng (Reactive State Management) |
| `shared_preferences` | `^2.2.3` | Lưu trữ cấu hình theme và font chữ vào bộ nhớ phần cứng thiết bị |
| `path_provider` | `^2.1.2` | Truy xuất đường dẫn thư mục lưu trữ ứng dụng (`getApplicationDocumentsDirectory`) |
| `dio` | `^5.4.0` | Client HTTP tải gói tài nguyên ZIP từ Github theo tiến độ realtime |
| `archive` | `^3.4.10` | Giải nén file ZIP trực tiếp trên bộ nhớ và lưu ra bộ nhớ máy |
| `flutter_3d_controller` | `^1.2.1` | Wrapper WebView nền tảng dựng mô hình 3D Google `<model-viewer>` |
| `connectivity_plus` | `^6.0.3` | Lắng nghe trạng thái kết nối mạng phần cứng (Offline, 4G/5G, Wi-Fi/Ethernet) |
| `dart:io` | Thư viện chuẩn | Khởi tạo HTTP Server nội bộ (`HttpServer.bind`) và đọc ghi file hệ thống |

---

## 3. Các Tính Năng Cốt Lõi Của Ứng Dụng

### A. Màn Hình Chính Dashboard (`Code/lib/screens/dashboard_screen.dart`)
- **Danh Mục Dữ Liệu Hybrid**: Nạp danh sách mô hình từ file asset nội bộ (`assets/data/origami_database.json`).
- **Bộ Lọc Thẻ Multi-Tag Theo Logic ANY (OR)**: Lọc mô hình khớp với *bất kỳ* danh mục nào người dùng chọn (`_selectedCategories.any(...)`).
- **Thanh ChoiceChips Động**: Tự động trích xuất các danh mục duy nhất từ dữ liệu mô hình để dựng dải cuộn ngang.
- **Sắp Xếp Ưu Tiên Nổi Bọt**: Các mô hình đã tải về máy sẽ tự động nổi lên đầu danh sách hiển thị.
- **Tìm Kiếm & Xóa Bộ Lọc**: Tìm kiếm theo từ khóa tên/mô tả và nút xóa sạch bộ lọc 1-tap.
- **Menu Cài Đặt Làm Mờ (Blurred Settings Drawer)**: Bảng tùy chỉnh giao diện (Theme `AppTheme.LIGHT_CLASSIC` mặc định), font chữ và tỉ lệ UI scale.

### B. Màn Hình Chi Tiết Sản Phẩm (`Code/lib/screens/product_detail_screen.dart`)
- **Bảng Thông Số Vật Liệu**: Hiển thị kích thước giấy, loại giấy, dụng cụ cần thiết và mô tả chi tiết.
- **Banner Cảnh Báo Trạng Thái Mạng Inline**:
  - **Trạng thái Mất Mạng (`ConnectivityResult.none`)**: Hiển thị dòng cảnh báo đỏ (`"You are currently offline."`) và chặn thao tác tải về.
  - **Trạng thái Mạng Dữ Liệu Di Động (`ConnectivityResult.mobile`)**: Hiển thị dòng cảnh báo vàng cam (`"Warning: You are using mobile data."`) nhưng vẫn cho phép bấm tải.
  - **Trạng thái Wi-Fi / Ethernet (`ConnectivityResult.wifi / ethernet`)**: Ẩn hoàn toàn dòng cảnh báo.
- **Điều Khiển Tương Tác**: Nút đóng modal `[X]` và thanh tiến trình hiển thị phần trăm tải/giải nén.

### C. Màn Hình Thực Hành Dựng Mô Hình (`Code/lib/screens/practice_viewer_screen.dart`)
- **Hướng Dẫn 2D Theo Bước**: Hiển thị ảnh 2D từng bước kèm góc xoay thử nghiệm.
- **Thao Tác Vuốt Cảm Ứng Ngang**:
  - Vuốt Phải sang Trái (Vuốt Trái) -> Sang bước tiếp theo (`_goToNextStep`).
  - Vuốt Trái sang Phải (Vuốt Phải) -> Quay lại bước trước (`_goToPrevStep`).
- **Khung Hướng Dẫn Chống Tràn Bố Cục**: Chiều cao cố định gọn nhẹ (`42px`), chữ 1 dòng bọc trong `SingleChildScrollView(scrollDirection: Axis.horizontal, physics: BouncingScrollPhysics())` giúp chữ dài tự trượt ngang mượt mà, triệt tiêu hoàn toàn lỗi vỡ khung Vertical Overflow.
- **Trình Dựng Mô Hình 3D Tích Hợp**: Tự động chuyển sang trình xem 3D tương tác ở bước cuối cùng (`currentStepIndex == total2DSteps`).

---

## 4. Các Giải Pháp & Hotfix Kiến Trúc Quan Trọng

### A. Server HTTP Nội Bộ Nhúng (`LocalServerService`)
- **Vấn đề**: Các WebView hiện đại trên Android/iOS áp dụng chính sách bảo mật CSP và CORS rất nghiêm ngặt, ngăn cản Google `<model-viewer>` đọc file `.glb` trực tiếp từ giao thức `file://` hoặc chuỗi `data:` Base64.
- **Giải pháp**: Khởi tạo dịch vụ singleton `LocalServerService` chạy `HttpServer` tại địa chỉ loopback `127.0.0.1:$port`. Server cấu hình đầy đủ header CORS (`Access-Control-Allow-Origin: *`, `Access-Control-Allow-Methods: GET, POST, OPTIONS`) và header `Content-Type: model/gltf-binary`, cho phép `<model-viewer>` stream file `.glb` mượt mà qua URL `http://127.0.0.1:$port/models/$origamiId/finish.glb`.

### B. Cách Ly Tương Tác Cảm Ứng (Touch Hit-Test Isolation)
- **Vấn đề**: Các view nền tảng native (`AndroidView` / `UiKitView`) của WebView nuốt chửng các sự kiện chạm, làm đóng đắng các nút bấm Flutter trên thanh điều hướng.
- **Giải pháp**: Đưa thanh AppBar phía trên xuống vị trí **CHILD CUỐI CÙNG** trong `Stack(children: [...])` bọc trong `Material(color: Colors.transparent)`. Nút bấm bọc bằng `GestureDetector(behavior: HitTestBehavior.opaque)` và nút "Trở về Trang chủ" gọi `Navigator.of(context).popUntil((route) => route.isFirst)` giúp chuyển trang lập tức.

### C. Cấu Hình Quyền Mạng Android Manifest
Khai báo quyền và cho phép lưu thông HTTP không mã hóa trong `Code/android/app/src/main/AndroidManifest.xml`:
- `<uses-permission android:name="android.permission.INTERNET"/>`
- `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>`
- `android:usesCleartextTraffic="true"` trong thẻ `<application>` để phục vụ giao tiếp HTTP nội bộ 127.0.0.1.

---

## 5. Cấu Trúc Thư Mục Mã Nguồn (`Code/lib/`)

```
Code/lib/
├── main.dart                          # Điểm chạy ứng dụng, khởi động HTTP server & bọc Theme
├── models/
│   └── origami_model.dart             # Class dữ liệu OrigamiModel & logic parse JSON
├── providers/
│   ├── app_settings_provider.dart     # Quản lý trạng thái Theme, Font chữ & Scale UI
│   └── origami_provider.dart          # Quản lý danh mục dữ liệu, đường dẫn unzipped & bộ lọc
├── screens/
│   ├── dashboard_screen.dart          # Màn hình chính, ô tìm kiếm, chip danh mục & cài đặt
│   ├── practice_viewer_screen.dart    # Trình xem bước 2D/3D, vuốt trang & chống tràn UI
│   ├── product_detail_screen.dart     # Modal thông số & banner cảnh báo mạng inline
│   └── splash_screen.dart             # Màn hình chào animated landing page
└── services/
    └── local_server_service.dart      # Server HTTP nội bộ stream file GLB & tài nguyên
```
