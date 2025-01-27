// ignore_for_file: prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/main.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/utils/share.dart';
import 'dart:convert';

class ReportUser extends StatefulWidget {
  final String id;
  const ReportUser({Key? key, required this.id}) : super(key: key);

  @override
  State<ReportUser> createState() => _ReportUserState();
}

class _ReportUserState extends State<ReportUser> {
  APICalls ac = APICalls();

  final TextEditingController reportContent = TextEditingController(text: '');
  Map url = {};
  Map user = {};
  String idProfile = '0';

  @override
  void initState() {
    super.initState();
    idProfile = widget.id;
  }

  Future<void> reportUser(String comment) async {
    final response = await ac
        .postItem('/v2/users/:0/report/', [widget.id], {"comment": comment});
    print("reportEvent:" + response.statusCode + " " + response.body);
    if (response != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(json.decode(response.body)["error_message"]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 24,
      // color: Theme.of(context).colorScheme.onSurface,
      color: Colors.red,
      icon: const Icon(Icons.report_problem),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            bool isButtonEnabled = false;

            return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: Text('ReportUser').tr(),
                content: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      isButtonEnabled = value.isNotEmpty; // 根据输入文本更新按钮状态
                    });
                  },
                  controller: reportContent,
                  decoration: InputDecoration(
                    hintText: 'ReportComment'.tr(),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel').tr(),
                    onPressed: () =>
                        {reportContent.text = '', Navigator.pop(context)},
                  ),
                  TextButton(
                    child: Text('Yes').tr(),
                    onPressed: isButtonEnabled
                        ? () {
                            reportUser(reportContent.text);
                            reportContent.text = '';
                            Navigator.pop(context); // 关闭对话框
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
