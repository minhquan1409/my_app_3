import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách chat room (Admin)
  Stream<List<ChatRoom>> getChatRooms() {
    return _firestore.collection('chatRooms')
      .orderBy('lastUpdated', descending: true)
      .snapshots()
      .map((snapshot) =>
        snapshot.docs.map((doc) => ChatRoom.fromMap(doc.id, doc.data())).toList()
      );
  }

  // Lấy tin nhắn của 1 phòng
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _firestore.collection('chatRooms')
      .doc(chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snapshot) =>
        snapshot.docs.map((doc) => ChatMessage.fromMap(doc.id, doc.data())).toList()
      );
  }

  // Gửi tin nhắn
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String text,
  }) async {
    final message = ChatMessage(
      id: '',
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    );

    final roomRef = _firestore.collection('chatRooms').doc(chatRoomId);

    await roomRef.collection('messages').add(message.toMap());

    // Cập nhật lastUpdated và unreadCount
    if (senderId == "admin") {
      // Admin gửi tin nhắn, không tăng unreadCount
      await roomRef.update({
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      });
    } else {
      // User gửi tin nhắn, tăng unreadCount
      await roomRef.update({
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
        'unreadCount': FieldValue.increment(1),
      });
    }
  }

  // User bắt đầu chat (nếu chưa có room)
  Future<String> startChatWithAdmin({
    required String userId,
    required String userName,
  }) async {
    final existingRoom = await _firestore.collection('chatRooms')
      .where('userId', isEqualTo: userId)
      .limit(1)
      .get();

    if (existingRoom.docs.isNotEmpty) {
      return existingRoom.docs.first.id;
    }

    final newRoom = ChatRoom(
      id: '',
      userId: userId,
      userName: userName,
      lastUpdated: DateTime.now(),
    );

    final docRef = await _firestore.collection('chatRooms').add(newRoom.toMap());
    return docRef.id;
  }

  // Xóa tin nhắn
  Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
  }) async {
    await _firestore.collection('chatRooms')
      .doc(chatRoomId)
      .collection('messages')
      .doc(messageId)
      .delete();  
  }

  // Đặt lại số tin nhắn chưa đọc về 0 khi admin mở phòng chat
  Future<void> resetUnreadCount(String chatRoomId) async {
    final roomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    await roomRef.update({'unreadCount': 0});
  }

  // Xoá toàn bộ đoạn chat giữa user và admin
  Future<void> deleteChatRoom({
    required String chatRoomId,
  }) async {
    final roomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    final messagesSnapshot = await roomRef.collection('messages').get();

    final batch = _firestore.batch();
    
    // Xoá tất cả tin nhắn trong sub-collection
    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // Xoá document của phòng chat
    batch.delete(roomRef);
    
    await batch.commit();
  }
}