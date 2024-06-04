import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  final _streamController = StreamController<List<Map<String, String>>>.broadcast();
  List<Map<String, String>> mensajes = [];
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.on('connect', (_) {
      print('connected');
    });

    socket.on('receive_message', (message) {
      setState(() {
        mensajes.add({'type': 'received', 'message': message});
      });
      _streamController.add(mensajes);
    });

    socket.on('disconnect', (_) {
      print('disconnected');
    });
  }

  void _enviar() {
    if (_textController.text.isNotEmpty) {
      socket.emit('send_message', _textController.text);
      setState(() {
        mensajes.add({'type': 'sent', 'message': _textController.text});
      });
      _streamController.add(mensajes);
      _textController.clear();
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    _streamController.close();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return GestureDetector(
   onTap: () {
     FocusScope.of(context).unfocus();
   },
   child: Scaffold(
     appBar: AppBar(
       title: const Text('WhatsGram ©'),
     ),
     body: Column(
     children:[
       Expanded(
         child: StreamBuilder<List<Map<String, String>>>(
           stream: _streamController.stream,
           builder: (context, snapshot) {
             if (snapshot.hasError) {
               return Center(child: Text('Error: ${snapshot.error}'));
             }
             if (!snapshot.hasData || snapshot.data!.isEmpty) {
               return const Center(child: Text('No hay mensajes'));
             }
             return ListView.builder(
               itemCount: snapshot.data!.length,
               itemBuilder: (context, index) {
                 final message = snapshot.data![index];
                 final enviado = message['type'] == 'sent';
                 return Align(
                   alignment: enviado ? Alignment.centerRight : Alignment.centerLeft,
                   child: Container(
                     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                     padding: EdgeInsets.all(10),
                     decoration: BoxDecoration(
                       color: enviado ? Color.fromARGB(177, 111, 176, 230) : Color.fromARGB(132, 94, 180, 95),
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: Text(
                       message['message']!,
                       style: TextStyle(
                         color: Colors.black,
                         fontSize: 16, fontWeight: FontWeight.w500
                       ),
                     ),
                   ),
                 );
               },
             );
           },
         ),
       ),
       Padding(
         padding: const EdgeInsets.all(8),
         child: Row(
           children: [
             Expanded(
               child: TextField(
                 controller: _textController,
                 decoration: const InputDecoration(
                   labelText: 'Mensaje',
                   border: OutlineInputBorder(),
                 ),
               ),
             ),
             const SizedBox(width: 8),
             ElevatedButton(
               style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color.fromARGB(177, 111, 176, 230) ),foregroundColor: MaterialStatePropertyAll(Colors.white)),
               onPressed: _enviar,
               child: const Text('Enviar', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
             ),
           ],
         ),
       ),
     ],
     ),
    ),
  );
  }
}
