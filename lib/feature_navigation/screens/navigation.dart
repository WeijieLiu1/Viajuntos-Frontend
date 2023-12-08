import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:viajuntos/feature_event/screens/create_event.dart';
import 'package:viajuntos/feature_explore/screens/home.dart';
import 'package:viajuntos/feature_home/screens/home.dart';
import 'package:viajuntos/feature_navigation/screens/profile.dart';
import 'package:viajuntos/feature_user/services/externalService.dart';
import 'package:viajuntos/utils/go_to.dart';
import 'package:uni_links/uni_links.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'dart:async';
import 'package:viajuntos/feature_event/screens/event_screen.dart';
import 'dart:convert';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../../feature_chat/screens/listChat_screen.dart';
import '../../utils/globals.dart';

class NavigationBottomBar extends StatefulWidget {
  const NavigationBottomBar({Key? key}) : super(key: key);

  @override
  State<NavigationBottomBar> createState() => _NavigationBottomBarState();
}

class _NavigationBottomBarState extends State<NavigationBottomBar> {
  int _index = 0;
  String _scanResult = 'Unknown';
  static const List<Widget> _widgetOptions = <Widget>[
    MainHomeScreen(),
    HomeScreen(),
    ListChatScreen(),
    CreateEventScreen()
  ];

  APICalls ac = APICalls();

  String getCurrentUser() {
    return ac.getCurrentUser();
  }

  String urlProfilePhoto = "";
  final ExternServicePhoto es = ExternServicePhoto();

  Future<void> getProfilePhoto() async {
    final response = await es.getAPhoto(getCurrentUser());
    if (response != 'Fail') {
      setState(() {
        urlProfilePhoto = response;
      });
    }
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
      CallLink(barcodeScanRes);
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

  void CallLink(String link) async {
    var uri = Uri.parse(link);
    var type = uri.pathSegments[1];
    switch (type) {
      case "events":
        var id = uri.pathSegments[2];
        if (id != '') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EventScreen(id: id)));
        }
        break;
      case "users":
        var response = await APICalls().getCollection(
            '/v2/users/new_friend', [], {"code": uri.queryParameters["code"]!});
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProfileScreen(id: json.decode(response.body)["id"])));
        break;
      default:
      // http://localhost:5000/v2/users/new_friend?code=bmWecsrvil7UTVT
    }
  }

  Future<void> initUniLinks() async {
    // ... check initialLink

    // Attach a listener to the stream
    _sub = linkStream.listen((String? link) async {
      // Parse the link and warn the user, if it is not correct

      if (link != null) {
        // baseLocalUrl+/v2/events/i
        // baseLocalUrl+/v2/users/new_friend?code=xxx
        var uri = Uri.parse(link);
        var type = uri.pathSegments[1];
        switch (type) {
          case "events":
            var id = uri.pathSegments[2];
            if (id != '') {
              Navigator.of(context).pushNamed('/home');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EventScreen(id: id)));
            }
            break;
          case "users":
            var response = await APICalls().getCollection(
                '/v2/users/new_friend',
                [],
                {"code": uri.queryParameters["code"]!});
            Navigator.of(context).pushNamed('/home');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(id: json.decode(response.body)["id"])));
            break;
          default:
        }
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();
    getProfilePhoto();
    // print('initState1');
    // _socket = IO.io(
    //   baseLocalUrl,
    //   IO.OptionBuilder().setTransports(['websocket'])
    //       // .disableAutoConnect()
    //       .build(),
    // );
    // _connectSocket();
    // print('initState2');
  }

  // Future<void> _scanQR() async {
  //   try {
  //     var result = await BarcodeScanner.scan();
  //     setState(() {
  //       _scanResult = result.rawContent;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _scanResult = 'Error: $e';
  //     });
  //   }
  // }

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
                onTap: () {
                  // print('click');
                  // _socket.emit('connect', 'msgtest');
                  scanQR();
                },
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
                onTap: () {
                  // print('click');
                  // _socket.emit('connect', 'msgtest');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          id: getCurrentUser(),
                        ),
                      ));
                },
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: ClipRRect(
                      child: FittedBox(
                          child: (urlProfilePhoto == "")
                              ? Image.asset('assets/noProfileImage.png')
                              : Image.network(urlProfilePhoto),
                          fit: BoxFit.fitHeight),
                      borderRadius: BorderRadius.circular(100)),
                ),
              ),
            )
          ]),
      body: Center(child: _widgetOptions.elementAt(_index)),
      bottomNavigationBar: BottomNavigationBar(
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
