import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String userId1, String userId2) {
    return (userId1.hashCode <= userId2.hashCode)
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  Stream<QuerySnapshot> getMessages(String currentUserId, String receiverId) {
    final chatId = getChatId(currentUserId, receiverId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String currentUserId,
    required String receiverId,
    required String text,
  }) async {
    final chatId = getChatId(currentUserId, receiverId);
    final timestamp = Timestamp.now();

    final messageData = {
      'text': text,
      'senderId': currentUserId,
      'receiverId': receiverId,
      'createdAt': timestamp,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
  }
}
