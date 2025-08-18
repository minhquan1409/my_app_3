import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../models/chat_room.dart';
import '../../../models/chat_message.dart';

// Đây là màn hình chat dành cho admin, hiển thị danh sách các phòng chat
// và nội dung tin nhắn của phòng chat đã chọn.
class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  // Trạng thái để lưu ID và tên người dùng của phòng chat đang được chọn.
  String? selectedRoomId;
  String? selectedUserName;
  final TextEditingController _controller = TextEditingController();

  // Hàm xử lý việc gửi tin nhắn.
  void _sendMessage() {
    if (_controller.text.trim().isEmpty || selectedRoomId == null) {
      return;
    }
    
    // Gọi phương thức gửi tin nhắn từ ChatProvider.
    Provider.of<ChatProvider>(context, listen: false).sendMessage(
      chatRoomId: selectedRoomId!,
      senderId: "admin", // ID admin cố định
      text: _controller.text.trim(),
    );

    _controller.clear();
  }

  // Hàm xử lý việc xoá toàn bộ phòng chat.
  void _deleteChatRoom() {
    if (selectedRoomId == null) return;
    
    // Gọi phương thức xóa phòng chat từ ChatProvider
    Provider.of<ChatProvider>(context, listen: false,).deleteChatRoom(chatRoomId: selectedRoomId!);
    
    // Sau khi xóa thành công, đặt lại trạng thái để giao diện quay về
    // trạng thái ban đầu.
    setState(() {
      selectedRoomId = null;
      selectedUserName = null;
    });
  }

  // Hiển thị hộp thoại xác nhận xoá phòng chat
  Future<void> _showDeleteRoomConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xoá toàn bộ đoạn chat'),
          content: const Text('Bạn có chắc chắn muốn xoá vĩnh viễn đoạn chat này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Xoá', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteChatRoom();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: selectedUserName != null
            ? Text("Đang trò chuyện với $selectedUserName")
            : const Text("Admin Chat"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (selectedRoomId != null)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _showDeleteRoomConfirmationDialog,
            )
        ],
      ),
      body: Row(
        children: [
          // Khu vực danh sách phòng chat
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: StreamBuilder<List<ChatRoom>>(
                stream: provider.getChatRooms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Chưa có phòng chat nào."));
                  }
                  final rooms = snapshot.data!;
                  return ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final isSelected = selectedRoomId == room.id;
                      
                      // Biến cờ để kiểm tra có tin nhắn chưa đọc hay không
                      final hasUnreadMessages = room.unreadCount > 0;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            room.userName,
                            style: TextStyle(
                              fontWeight: isSelected || hasUnreadMessages
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            "Cập nhật: ${room.lastUpdated}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: hasUnreadMessages
                              ? Badge(
                                  backgroundColor: Colors.red,
                                  label: Text(
                                    room.unreadCount.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              selectedRoomId = room.id;
                              selectedUserName = room.userName;
                            });
                            // Gọi phương thức để reset unread count
                            provider.resetUnreadCount(room.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // Khu vực hiển thị tin nhắn
          Expanded(
            flex: 4,
            child: selectedRoomId == null
                ? const Center(
                    child: Text(
                      "Vui lòng chọn một phòng chat để bắt đầu.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: StreamBuilder<List<ChatMessage>>(
                          stream: provider.getMessages(selectedRoomId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text("Phòng chat trống."));
                            }
                            final messages = snapshot.data!.reversed.toList();
                            return ListView.builder(
                              reverse: true, // Hiển thị tin nhắn mới nhất ở dưới cùng
                              padding: const EdgeInsets.all(12),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final isMe = msg.senderId == "admin";
                                return Align(
                                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.4,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.blueAccent : Colors.grey[300],
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Khu vực nhập tin nhắn
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: "Nhập tin nhắn...",
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.blueAccent),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
          )
        ],
      ),
    );
  }
}
