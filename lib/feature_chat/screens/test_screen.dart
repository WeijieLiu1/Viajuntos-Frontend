// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class TestScreen extends StatefulWidget {
//   const TestScreen({Key? key}) : super(key: key);
//   @override
//   _TestScreen createState() => _TestScreen();
// }

// class _TestScreen extends State<TestScreen> {
//   late IO.Socket socket;
//   List<String> messages = [];
//   TextEditingController messageController = TextEditingController();
//   late String currentName = "tommy";

//   @override
//   void initState() {
//     super.initState();
//     socket = IO.io('http://192.168.1.107:5000');
//     socket.on('message', (data) {
//       setState(() {
//         messages.add(data['message']);
//       });
//     });
//     socket.on('name', (data) {
//       setState(() {
//         currentName = data['name'];
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//             appBar: AppBar(title: Text('Chat')),
//             body: Column(children: [
//               Text('Hello $currentName!'),
//               Expanded(
//                   child: ListView.builder(
//                       itemCount: messages.length,
//                       itemBuilder: (context, index) => ListTile(
//                             title: Text('${messages[index]}'),
//                             subtitle: Text(index == 0 ? 'You' : currentName),
//                           ))),
//               Row(children: [
//                 Expanded(child: TextField(controller: messageController)),
//                 ElevatedButton(
//                     onPressed: () {
//                       socket.emit('message',
//                           {'message': messageController.text, 'name': 'You'});
//                       setState(() {
//                         messageController.clear();
//                       });
//                     },
//                     child: Text('Send'))
//               ])
//             ])));
//   }
// }
