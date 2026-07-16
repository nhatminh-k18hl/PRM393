import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // GlobalKey quản lý trạng thái kiểm lỗi Form
  final _formKey = GlobalKey<FormState>();

  // Bộ điều khiển thu thập văn bản từ ô nhập liệu
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Biến quản lý ẩn/hiện văn bản mật khẩu
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // Trạng thái hiển thị vòng xoay loading bất đồng bộ (Task 7.4)
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // [LAB 7.4]: Hàm kiểm tra Email trùng lặp bất đồng bộ mô phỏng gọi lên Server
  Future<void> _processRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Giả lập độ trễ mạng phản hồi từ Server mất 2 giây
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      // Quy tắc chặn: Nếu Email nhập vào khớp với taken@gmail.com thì báo lỗi hệ thống
      if (_emailController.text.trim() == 'taken@gmail.com') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '🚨 Lỗi bất đồng bộ: Email này đã có người đăng ký sử dụng!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Đăng ký tài khoản thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset(); // Xóa sạch dữ liệu các ô nhập
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // [TASK 7.3]: Chạm ra ngoài vùng Form để ẩn bàn phím ảo ngay lập tức
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đăng ký tài khoản',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        // [FIX THÒ THỤT PHÍM]: Sử dụng ListView thay cho SingleChildScrollView để
        // Flutter tự động tính toán không gian và vọt đẩy bàn phím ảo lên cho toàn bộ các trường.
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              const SizedBox(height: 10),
              const Text(
                'Tạo tài khoản mới',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // 1. TRƯỜNG NHẬP LIỆU: HỌ VÀ TÊN
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType
                    .text, // Chỉ định kiểu text cơ bản để kích hoạt phím ảo nhạy bén
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Vui lòng nhập tên của bạn';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. TRƯỜNG NHẬP LIỆU: EMAIL (VALIDATE CHUẨN abc@gmail.com)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons
                      .email), // Đã sửa từ icon lỗi email_outline cũ thành icon email chuẩn
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Email không được để trống';
                  // Biểu thức chính quy Regex bắt buộc cấu trúc: tên_mail @ tên_loại_mail . tên_đuôi_mở_rộng (vd: abc@gmail.com)
                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Email chưa đúng định dạng (vd: abc@gmail.com)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. TRƯỜNG NHẬP LIỆU: PASSWORD (MẠNH: 8-20 KÝ TỰ, 1 HOA, 1 THƯỜNG, 1 SỐ)
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon:
                      const Icon(Icons.lock), // Đã sửa sang icon lock chuẩn
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePass ? Icons.visibility : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
                obscureText: _obscurePass,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Mật khẩu không được để trống';

                  // Tách biệt các bộ kiểm tra điều kiện mật khẩu mạnh
                  final hasLength = value.length >= 8 && value.length <= 20;
                  final hasUppercase = value.contains(RegExp(r'[A-Z]'));
                  final hasLowercase = value.contains(RegExp(r'[a-z]'));
                  final hasDigits = value.contains(RegExp(r'[0-9]'));

                  if (!hasLength)
                    return 'Độ dài mật khẩu phải từ 8 đến 20 ký tự!';
                  if (!hasUppercase)
                    return 'Mật khẩu phải chứa ít nhất 1 chữ cái viết HOA!';
                  if (!hasLowercase)
                    return 'Mật khẩu phải chứa ít nhất 1 chữ cái viết thường!';
                  if (!hasDigits)
                    return 'Mật khẩu phải chứa ít nhất 1 chữ số (0-9)!';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. TRƯỜNG NHẬP LIỆU: CONFIRM PASSWORD
              TextFormField(
                controller: _confirmController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(
                      Icons.lock_reset), // Đã sửa sang icon lock_reset chuẩn
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _processRegistration(),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Vui lòng xác nhận lại mật khẩu';
                  if (value != _passwordController.text)
                    return 'Mật khẩu xác nhận không khớp!';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // NÚT ĐĂNG KÝ TÍNH NĂNG XOAY LOADING ASYNC
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null : _processRegistration,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('ĐĂNG KÝ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
