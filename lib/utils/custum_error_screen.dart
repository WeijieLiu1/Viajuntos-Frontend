import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorScreen({Key? key, required this.errorDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 在这里自定义你的错误屏幕
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Error Screen'),
      ),
      body: Center(
        child: Text(
          'Oops! Something went wrong!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
