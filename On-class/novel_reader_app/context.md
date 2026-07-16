Bạn là chuyên gia lập trình Flutter & Dart cao cấp. Hãy tiếp nhận và ghi nhớ bối cảnh dự án ứng dụng di động Đọc Truyện Tiểu Thuyết (Novel Reader App) sau đây để hướng dẫn viết code chuẩn kiến trúc sạch (Clean Architecture):

1. KIẾN TRÚC MÀN HÌNH VÀ LUỒNG ĐIỀU HƯỚNG:
- Screen 1: Splash Screen (Màn hình chào tự động chuyển sau 2 giây).
- Screen 2: HomeScreen (Màn hình chọn sách).
- Screen 3: DetailScreen (Màn hình chi tiết, tóm tắt truyện và danh sách mục lục đầy đủ).
- Screen 4: ReadingScreen (Màn hình đọc chữ chính của chương truyện).

2. ĐẶC TẢ GIAO DIỆN VÀ LOGIC UX HIỆN ĐẠI (ĐÃ CHỐT VỚI KHÁCH HÀNG):
- Bộ lọc thông minh (Tag Intersection): Tại HomeScreen, người dùng có thể chọn đồng thời 2-3 tag thể loại để tìm ra giao diện chung của những bộ truyện chứa tất cả các tag đó (Thuật toán lọc tập hợp con Dart Collection).
- Demo Box tại HomeScreen: Có một ô hộp thoại hiển thị văn bản mẫu trực quan giúp người dùng xem trước (Preview) sự thay đổi về Font chữ, kích thước Font size, và Theme màu sắc (Light/Dark mode) trước khi áp dụng chung cho toàn app.
- Center Content (Reading Screen): Nội dung chữ truyện nằm trọn vẹn ở lớp dưới, sử dụng widget Text thuần để chặn hoàn toàn tính năng ấn giữ bôi đen chữ theo thói quen tì tay của độc giả.
- Header (Reading Screen): Cố định ở đỉnh trang đọc, chứa nút quay lại DetailScreen, Tên tác phẩm viết ngắn gọn, nút bánh răng cài đặt.
- Footer thông minh (Reading Screen): Chỉ xuất hiện khi người dùng cuộn ngược lên (Scroll up) hoặc khi vuốt chạm đáy trang truyện (Scroll to max extent). Chứa lần lượt: [Nút nhảy thẳng về HomeScreen], [Nút lùi 1 chương liền kề], [Nút dạngDropdown mở danh sách chương nhanh], [Nút tiến 1 chương liền kề], [Nút Bookmark lưu local chương đang đọc].
- Reset Thanh Cuộn: Mặc định bất kể khi chuyển chương liền kề, chuyển màn hình, hay chọn chương từ Dropdown, trang đọc phải tự động được đưa về vị trí đỉnh trên cùng (scrollController.jumpTo(0.0)).
- Floating Drop-list chọn chương nhanh: Xuất hiện dạng menu nổi chính giữa trang, phủ mờ lớp chữ truyện phía sau bằng Stack và BackdropFilter. Khi bật menu này, khóa tạm thời tính năng chạm biên chuyển trang và cuộn văn bản bên dưới. Danh sách chương dài phải bọc trong ConstrainedBox để khống chế chiều cao, hỗ trợ scroll mượt mà bên trong mà không gây hiện tượng giật lag màn hình. Người dùng tắt menu bằng cách click vào chương mới, click lại chương hiện tại (giữ nguyên vị trí cuộn chữ), hoặc chạm vào phần mờ bao phủ bên ngoài để hủy ý định đổi chương.
- Bảng Setting bánh răng: Trồi lên làm mờ nền chữ, đóng lại khi bấm ngón tay vào vùng Center trống bên ngoài. Lưu trữ realtime xuống ổ cứng local bằng SharedPreferences.

3. TÍNH NĂNG CHUYỂN CHƯƠNG NÂNG CAO:
- Thiết lập 3 vùng cảm ứng vô hình bằng GestureDetector trên màn đọc bình thường: 15% biên trái (chạm lùi chương), 15% biên phải (chạm tiến chương), 70% ở giữa (chạm bật/tắt thanh công cụ).
- Bắt sự kiện Overscroll (kéo kịch đáy chương truyện thêm 1 lần nữa) qua ScrollNotification để tự động load dữ liệu chương tiếp theo.