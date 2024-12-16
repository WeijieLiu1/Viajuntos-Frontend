import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BannedUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Banned')),
      body: Center(
        child: Text('This user is banned.'),
      ),
    );
  }
}
