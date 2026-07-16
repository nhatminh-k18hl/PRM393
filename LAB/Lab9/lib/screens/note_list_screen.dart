import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final StorageService _storageService = StorageService();

  List<Note> _allNotes = []; // Mảng gốc lưu từ File
  List<Note> _filteredNotes = []; // Mảng động phục vụ ô Tìm kiếm
  bool _isNotesLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocalData();
  }

  // Hàm kết nối bất đồng bộ nạp danh sách dữ liệu khi ứng dụng mở ra
  Future<void> _fetchLocalData() async {
    final list = await _storageService.loadNotes();
    setState(() {
      _allNotes = list;
      _filteredNotes = list;
      _isNotesLoading = false;
    });
  }

  // Hàm kích hoạt bộ lọc tìm kiếm Realtime văn bản không phân biệt hoa thường
  void _performSearch(String query) {
    setState(() {
      _filteredNotes = _allNotes
          .where((note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Hàm đồng bộ lưu xuống bộ nhớ thiết bị sau mỗi hành động CRUD thành công
  void _syncAndRefresh() {
    _storageService.saveNotes(_allNotes);
    setState(() {
      _filteredNotes = List.from(_allNotes);
    });
  }

  // =========================================================================
  // CÁC HỘP THOẠI DIALOG CHỨC NĂNG CRUD
  // =========================================================================

  // 1. CHỨC NĂNG CREATE (THÊM PHẦN TỬ MỚI)
  void _showAddDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm ghi chú mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề')),
            TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Nội dung')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                // Tự cấp phát ID duy nhất dựa theo mốc thời gian timestamp miligiây
                final newNote = Note(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                );
                _allNotes.add(newNote);
                _syncAndRefresh(); // Đồng bộ dữ liệu xuống ổ cứng thiết bị
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu'),
          )
        ],
      ),
    );
  }

  // 2. CHỨC NĂNG UPDATE (SỬA THÔNG TIN ĐÃ CÓ)
  void _showEditDialog(Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa ghi chú'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề')),
            TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Nội dung')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                note.title = titleController.text.trim();
                note.content = contentController.text.trim();
                _syncAndRefresh(); // Tự động lưu ghi xuống ổ cứng
                Navigator.pop(ctx);
              }
            },
            child: const Text('Cập nhật'),
          )
        ],
      ),
    );
  }

  // 3. CHỨC NĂNG DELETE (XÓA KÈM DIALOG UX XÁC NHẬN)
  void _showDeleteConfirmDialog(Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Xác nhận xóa'),
        content: Text(
            'Bạn có chắc chắn muốn xóa vĩnh viễn ghi chú "${note.title}" không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _allNotes.removeWhere((item) => item.id == note.id);
              _syncAndRefresh(); // Lưu đè dữ liệu mới sau khi xóa
              Navigator.pop(ctx);
            },
            child: const Text('Xóa'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📂 Local JSON DB Manager',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: _isNotesLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Khối thanh tìm kiếm sản phẩm/ghi chú
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: _performSearch,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tiêu đề hoặc nội dung...',
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.indigo),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),

                // Khối hiển thị danh sách cuộn mượt mà
                Expanded(
                  child: _filteredNotes.isEmpty
                      ? const Center(
                          child: Text('Không có ghi chú nào trùng khớp!'))
                      : ListView.builder(
                          itemCount: _filteredNotes.length,
                          itemBuilder: (context, index) {
                            final item = _filteredNotes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              elevation: 2,
                              child: ListTile(
                                leading: const CircleAvatar(
                                    backgroundColor: Colors.indigo,
                                    child: Icon(Icons.note,
                                        color: Colors.white, size: 20)),
                                title: Text(item.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(item.content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () => _showEditDialog(item)),
                                    IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _showDeleteConfirmDialog(item)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
