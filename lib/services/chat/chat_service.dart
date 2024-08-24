import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dormlanders/models/message.dart';

class ChatService {
  // GET INSTANCE OF FIRESTORE
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // SEND MESSAGE
  Future<void> sendMessage(String receiverID, message) async {
    // GET CURRENT USER INFO
    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // CREATE A NEW MESSAGE
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // CONSTRUCT CHAT ROOM (SORTED TO ENSURE UNIQUENESS)
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // ADD NEW MESSAGE TO DATABASE
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());


        // Save the chat room information in my_chatrooms collection
        await _firestore
            .collection('users')
            .doc(currentUserID)
            .collection('my_chatrooms')
            .doc(chatRoomID)
            .set({
          'participants': ids,
          'timestamp': timestamp,
        });
  }

  // GET MESSAGES
  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    // CONSTRUCT CHAT ROOM
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore.collection("chat_rooms").doc(chatRoomID).collection("messages").orderBy("timestamp", descending: false).snapshots();
  }
}
