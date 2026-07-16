import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _postFuture;

  // Controllers thu thập dữ liệu Form POST phần thưởng cộng điểm
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadData(); // Khởi động luồng kéo dữ liệu mạng khi load màn hình
  }

  void _loadData() {
    setState(() {
      _postFuture = _apiService.fetchPosts();
    });
  }

  // Logic gửi POST Request lên máy chủ (Bonus Feature)
  Future<void> _submitNewPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);

      final success = await _apiService.createPost(
        _titleController.text.trim(),
        _bodyController.text.trim(),
      );

      setState(() => _isSending = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('🚀 Gửi dữ liệu POST thành công! (Mock created)'),
              backgroundColor: Colors.green),
        );
        _titleController.clear();
        _bodyController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('🚨 Lỗi gửi dữ liệu POST thất bại!'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📡 API Data Explorer',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // -----------------------------------------------------------------
          // KHỐI FORM NHẬP LIỆU GỬI POST REQUEST (TÍNH NĂNG CỘNG ĐIỂM THƯỞNG)
          // -----------------------------------------------------------------
          Card(
            margin: const EdgeInsets.all(12.0),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('➕ Thêm bài viết mới (POST Request)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.teal)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          labelText: 'Tiêu đề bài viết',
                          isDense: true,
                          border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty
                          ? 'Không được để trống tiêu đề'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                          labelText: 'Nội dung bài viết',
                          isDense: true,
                          border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty
                          ? 'Không được để trống nội dung'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white),
                      onPressed: _isSending ? null : _submitNewPost,
                      child: _isSending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('SEND POST REQUEST'),
                    )
                  ],
                ),
              ),
            ),
          ),

          const Divider(),

          // -----------------------------------------------------------------
          // KHỐI QUẢN LÝ TRẠNG THÁI BẤT ĐỒNG BỘ: FutureBuilder (HÀM CỐT LÕI ĐỀ BÀI)
          // -----------------------------------------------------------------
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _postFuture,
              builder: (context, snapshot) {
                // TRẠNG THÁI 1: Hệ thống đang tải gọi dữ liệu mạng (LoadingIndicator)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.teal),
                        SizedBox(height: 12),
                        Text('Đang kết nối Server và tải dữ liệu JSON...',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // TRẠNG THÁI 2: Xử lý ngoại lệ nếu sập nguồn mạng hoặc sai đường dẫn (Error State)
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 60, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(
                            'Lỗi: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          // Nút kích hoạt nạp lại dữ liệu hỗ trợ trải nghiệm người dùng cao
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử Kết Nối Lại'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white),
                            onPressed: _loadData,
                          )
                        ],
                      ),
                    ),
                  );
                }

                // TRẠNG THÁI 3: Nạp dữ liệu hoàn tất thành công (Success State)
                if (snapshot.hasData) {
                  final posts = snapshot.data!;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final item = posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        child: ListTile(
                          // Hiện Badge ID chỉ định tròn tinh tế bên góc trái
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.withOpacity(0.1),
                            child: Text('${item.id}',
                                style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            item.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text('Không có dữ liệu hiển thị!'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
