import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/services/chat/chat_service.dart';
import 'package:dormlanders/widgets/chat_bubble.dart';
import 'package:dormlanders/widgets/profile_image_widget.dart';
import 'package:screenshot/screenshot.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> receiverData;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverData,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  // TEXT CONTROLLERS
  final TextEditingController _messageController = TextEditingController();

  // CHAT AND AUTH SERVICES
  final ChatService _chatService = ChatService();

  // FOCUS NODE
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});

    // ADD LISTENER
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // CAUSE A DELAY
        Future.delayed(
          const Duration(milliseconds: 300),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 300),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _exitTimer.cancel();
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // CHECK CONNECTION
  Future<void> _checkConnection() async {
    _connectionSubscription = InternetConnectionChecker().onStatusChange.listen(
      (status) {
        // Check if the context is still mounted
        if (!mounted) return;

        setState(() {
          _isConnectedToInternet = status == InternetConnectionStatus.connected;
        });

        if (_isConnectedToInternet) {
          _showConnectedSnackBar();
        } else {
          _showDisconnectedSnackBar();
        }
      },
    );
  }

  void _showDisconnectedSnackBar() {
    if (!_isConnectedToInternet) {
      // Check if a disconnected snack bar is already being displayed
      if (!isDisconnectedSnackBarVisible) {
        // showFloatingSnackBarWithIcon(
        //   context,
        //   'No internet connection',
        //   Icons.wifi_off_rounded,
        //   10,
        // );
        // Set the flag to indicate that the disconnected snack bar is being displayed
        isDisconnectedSnackBarVisible = true;

        // Restart the app after 10 seconds unless connection is restored
        _exitTimer = Timer(const Duration(seconds: 15), () async {
          await InternetConnectionChecker().hasConnection
              ? _exitTimer.cancel()
              : SystemNavigator.pop();
        });
      }
    }
  }

  void _showConnectedSnackBar() {
    if (isDisconnectedSnackBarVisible) {
      // If a disconnected snack bar is being displayed, hide it
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // Reset the flag
      isDisconnectedSnackBarVisible = false;
    }

    // showFloatingSnackBarWithIcon(
    //   context,
    //   'Connected to the internet',
    //   Icons.wifi_rounded,
    //   10,
    // );
  }

  // SCROLL CONTROLLER
  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  // SEND MESSAGE
  void sendMessage() async {
    // IF THERE IS SOMETHING INSIDE TEXTFIELD
    if (_messageController.text.isNotEmpty) {
      // SEND THE MESSAGE
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);

      scrollDown();

      // CLEAR THE CONTROLLER
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          titleSpacing: 0,
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          leading: Container(
            padding: EdgeInsets.zero,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 25,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: <Widget>[
                // USER PROFILE
                ProfileImageWidget(
                  width: 45,
                  height: 45,
                  borderRadius: 50,
                  imageURL: widget.receiverData['imageURL'],
                ),

                // SIZED BOX: SPACING
                const SizedBox(width: 10),

                // USER NAME
                Flexible(
                  child: Text(
                    widget.receiverData['displayName'] ??
                        "${widget.receiverData['firstName']} ${widget.receiverData['lastName']}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              height: 3,
              thickness: 1.5,
              color: Color(0xFFF5F5F5), // Customize the color of the line
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          // DISPLAY ALL THE MESSAGES
          Expanded(child: _buildMessageList()),

          // SIZED BOX: SPACING
          const SizedBox(height: 5),

          // USER INPUT
          _buildUserInput(),
        ],
      ),
    );
  }

  // BUILD MESSAGE LIST
  Widget _buildMessageList() {
    String senderID = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: _chatService.getMessage(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // ERRORS
        if (snapshot.hasError) {
          return const Text('Error');
        }

        // LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        // RETURN LIST VIEW
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // BUILD MESSAGE ITEM
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser =
        data['senderID'] == FirebaseAuth.instance.currentUser!.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    String getTimeDifference() {
      DateTime createdAt = (data['timestamp'] as Timestamp).toDate();
      Duration difference = DateTime.now().difference(createdAt);

      if (difference.inDays >= 30) {
        int months = difference.inDays ~/ 30;
        if (months == 1) {
          return '1 month ago';
        } else {
          return '$months months ago';
        }
      } else if (difference.inHours >= 24) {
        int days = difference.inDays;
        if (days == 1) {
          return '1 day ago';
        } else {
          return '$days days ago';
        }
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inMinutes} minutes ago';
      }
    }


    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          ChatBubble(message: data["message"], isCurrentUser: isCurrentUser),
          Align(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Text(
                getTimeDifference(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BUILD MESSAGE INPUT
  Widget _buildUserInput() {

    return Padding(
      padding: const EdgeInsets.only(bottom: 30, right: 10),
      child: Row(
        children: <Widget>[
          // TEXTFIELD SHOULD TAKE UP MOST OF THE SPACE
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 25),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  fillColor: const Color(0xFFF1F0F5),
                  filled: true,
                  hintText: "Type a message...",
                  hintStyle: const TextStyle(
                    color: Color(0xFF7C7C7D),
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                focusNode: myFocusNode,
                maxLines: 5,
                minLines: 1,
              ),
            ),
          ),

          // ICON
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send_rounded,
                color: Color(0xFF279778),
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
