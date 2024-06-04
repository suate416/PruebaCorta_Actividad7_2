
import 'package:chatsocket_application_1/chat_socket.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Chatgram',
      debugShowCheckedModeBanner: false,
      home:ChatScreen(),
    );
  }
}
