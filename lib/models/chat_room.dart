import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String userId;
  final String userName;
  final DateTime lastUpdated;
  int unreadCount; // Trường mới để theo dõi tin nhắn chưa đọc

  ChatRoom({
    required this.id,
    required this.userId,
    required this.userName,
    required this.lastUpdated,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromMap(String id, Map<String, dynamic> map) {
    return ChatRoom(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'unreadCount': unreadCount,
    };
  }
}