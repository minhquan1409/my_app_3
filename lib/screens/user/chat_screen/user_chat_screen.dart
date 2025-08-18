import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../models/chat_message.dart';



class UserChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserChatScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  String? chatRoomId;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _initChatRoom();
  }

  Future<void> _initChatRoom() async {
    final provider = Provider.of<ChatProvider>(context, listen: false);
    final id = await provider.startChatWithAdmin(
      userId: widget.userId,
      userName: widget.userName,
    );
    setState(() {
      chatRoomId = id;
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty || chatRoomId == null) return;

    Provider.of<ChatProvider>(context, listen: false).sendMessage(
      chatRoomId: chatRoomId!,
      senderId: widget.userId,
      text: _controller.text.trim(),
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    print("DEBUG - userId when open chat: ${widget.userId}");
    if (chatRoomId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat với Admin")
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: Provider.of<ChatProvider>(context).getMessages(chatRoomId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.userId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(msg.text),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Nhập tin nhắn...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}
