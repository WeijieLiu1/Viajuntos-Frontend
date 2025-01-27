import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:provider/provider.dart';
import 'package:viajuntos/feature_event/screens/create_event.dart';
import 'package:viajuntos/feature_explore/screens/home.dart';
import 'package:viajuntos/feature_home/screens/home.dart';
import 'package:viajuntos/feature_navigation/screens/profile.dart';
import 'package:viajuntos/feature_user/services/externalService.dart';
import 'package:uni_links/uni_links.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'dart:async';
import 'package:viajuntos/feature_event/screens/event_screen.dart';
import 'dart:convert';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:viajuntos/utils/friend_request_notifier.dart';
import '../../feature_chat/screens/listChat_screen.dart';

class NavigationBottomBar extends StatefulWidget {
  const NavigationBottomBar({Key? key}) : super(key: key);

  @override
  State<NavigationBottomBar> createState() => _NavigationBottomBarState();
}

class _NavigationBottomBarState extends State<NavigationBottomBar> {
  int _index = 0;
  String clipboardText = '';
  String _scanResult = 'Unknown';
  final TextEditingController linkContent = TextEditingController(text: '');
  static const List<Widget> _widgetOptions = <Widget>[
    MainHomeScreen(),
    HomeScreen(),
    ListChatScreen(),
    CreateEventScreen()
  ];

  Map user = {};

  String getCurrentUser() {
    return APICalls().getCurrentUser();
  }

  final ExternServicePhoto es = ExternServicePhoto();

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanResult = barcodeScanRes;
    });
  }

  StreamSubscription? _sub;

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  void initUser() async {
    var response =
        await APICalls().getItem('v2/users/:0', [APICalls().getCurrentUser()]);

    var aux = await APICalls().getItem('v2/users/get_friend_request', []);
    APICalls().friendRequests = json.decode(aux.body);
    Provider.of<RedDotNotifier>(context, listen: false)
        .updateFriendRequests(APICalls().friendRequests);
    setState(() {
      user = json.decode(response.body);
    });
  }

  @override
  void initState() {
    super.initState();
    initUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: FittedBox(
                    child: Image.asset('assets/Logo.png'), fit: BoxFit.fill),
              ),
              const SizedBox(width: 5),
              Text('Viajuntos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                    backgroundColor: Theme.of(context).colorScheme.background,
                  )),
            ],
          ),
          leading: const SizedBox(),
          elevation: 1,
          backgroundColor: Theme.of(context).colorScheme.background,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {},
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: ClipRRect(
                      child: FittedBox(
                          child: Icon(Icons.qr_code_scanner,
                              color: Theme.of(context).colorScheme.secondary),
                          fit: BoxFit.fitHeight),
                      borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                  onTap: () async {
                    // print('click');
                    // _socket.emit('connect', 'msgtest');
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          id: APICalls().getCurrentUser(),
                        ),
                      ),
                    );

// 根据返回值判断是否需要更新红点
                    if (result != null && result is bool && result) {
                      setState(() {}); // 更新界面
                    }
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 18, // 半径大小可以根据需要调整
                        backgroundImage: (user["image_url"] == null ||
                                user["image_url"].isEmpty)
                            ? const AssetImage('assets/noProfileImage.png')
                                as ImageProvider
                            : NetworkImage(user["image_url"]),
                      ),
                      Consumer<RedDotNotifier>(
                        builder: (context, notifier, child) {
                          return Positioned(
                            top: 0,
                            right: 0,
                            child: notifier.hasFriendRequest // 判断是否有红点
                                ? Container(
                                    width: 10, // 红点大小
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.red, // 红点颜色
                                      shape: BoxShape.circle, // 圆形
                                    ),
                                  )
                                : SizedBox(), // 没有红点时为空
                          );
                        },
                      ),
                    ],
                  )),
            )
          ]),
      body: Center(child: _widgetOptions.elementAt(_index)),
      bottomNavigationBar: BottomNavigationBar(
          // iconSize: 50,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: 'Home'.tr(),
                backgroundColor: Theme.of(context).colorScheme.onPrimary),
            BottomNavigationBarItem(
                icon: const Icon(Icons.search_rounded),
                label: 'Explore'.tr(),
                backgroundColor: Theme.of(context).colorScheme.onPrimary),
            BottomNavigationBarItem(
                icon: const Icon(Icons.chat),
                label: 'Chat'.tr(),
                backgroundColor: Theme.of(context).colorScheme.onPrimary),
            BottomNavigationBarItem(
                icon: const Icon(Icons.add),
                label: 'Create'.tr(),
                backgroundColor: Theme.of(context).colorScheme.onPrimary),
          ],
          currentIndex: _index,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          onTap: _onItemTapped),
    );
  }
}
