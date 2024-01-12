import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:http/http.dart';
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
  String clipboardText = '';
  String _scanResult = 'Unknown';
  static const List<Widget> _widgetOptions = <Widget>[
    MainHomeScreen(),
    HomeScreen(),
    ListChatScreen(),
    CreateEventScreen()
  ];

  Map user = {};
  APICalls ac = APICalls();

  String getCurrentUser() {
    return ac.getCurrentUser();
  }

  final ExternServicePhoto es = ExternServicePhoto();

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

  Future<void> getClipboardData() async {
    try {
      // 调用Clipboard的方法获取剪贴板内容
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);

      if (data != null && data.text != null) {
        // 剪贴板中有文本内容
        clipboardText = data.text!;
        print('Clipboard Text: $clipboardText');
        tryResolveClipboardData();
      } else {
        print('Clipboard is empty or does not contain text');
      }
    } catch (e) {
      // 处理异常
      print('Failed to get clipboard data: $e');
    }
  }

  Future<void> tryResolveClipboardData() async {
    try {
      var uri = Uri.parse(clipboardText);
      var type = uri.pathSegments[1];
      switch (type) {
        case "events": // join event
          var id = uri.pathSegments[2];
          if (id != '') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EventScreen(id: id)));
          }
          break;
        case "users": // add friend
          var response = await APICalls().getCollection('/v2/users/new_friend',
              [], {"code": uri.queryParameters["code"]!});
          // http://localhost:5000/v2/users/new_friend?code=bmWecsrvil7UTVT
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(id: json.decode(response.body)["id"])));
          break;
        default:
      }
    } catch (e) {
      // 处理异常
      print('Failed to set clipboard data: $e');
    }
  }

  Future<void> initUniLinks() async {
    // ... check initialLink

    // Attach a listener to the stream
    _sub = linkStream.listen((String? link) async {
      // Parse the link and warn the user, if it is not correct

      if (link != null) {
        // baseLocalUrl+/v3/events/i
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

  // void initUser() async {
  //   final response =
  //       await APICalls().getItem('v2/users/:0', [getCurrentUser()]);
  //   user = json.decode(response.body);
  //   print("user[image_url]" + user["image_url"]);
  // }

  @override
  void initState() {
    super.initState();
    initUniLinks();
    getClipboardData();
    // initUser();
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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => PaypalCheckoutView(
                      sandboxMode: true,
                      clientId:
                          "AYQPBYQ6U-hyIKBERgEN_qjO4fSIFvjljwKaYaCgU00NEKXB76Uxsba29zRPHp6AO1HBV7-VMFNyDhYt",
                      secretKey:
                          "EMfnOAW3h4UuOjrQJnnDBAf7s-ro7RLguWanGlXjYJxpF_OCH7-wZD4HKw45wIq1jXKkYlSMXUcsoSg_",
                      transactions: const [
                        {
                          "amount": {
                            "total": '100',
                            "currency": "USD",
                            "details": {
                              "subtotal": '100',
                              "shipping": '0',
                              "shipping_discount": 0
                            }
                          },
                          "description": "The payment transaction description.",
                          // "payment_options": {
                          //   "allowed_payment_method":
                          //       "INSTANT_FUNDING_SOURCE"
                          // },
                          "item_list": {
                            "items": [
                              {
                                "name": "Apple",
                                "quantity": 4,
                                "price": '10',
                                "currency": "USD"
                              },
                              {
                                "name": "Pineapple",
                                "quantity": 5,
                                "price": '12',
                                "currency": "USD"
                              }
                            ],

                            // Optional
                            //   "shipping_address": {
                            //     "recipient_name": "Tharwat samy",
                            //     "line1": "tharwat",
                            //     "line2": "",
                            //     "city": "tharwat",
                            //     "country_code": "EG",
                            //     "postal_code": "25025",
                            //     "phone": "+00000000",
                            //     "state": "ALex"
                            //  },
                          }
                        }
                      ],
                      note: "Contact us for any questions on your order.",
                      onSuccess: (Map params) async {
                        print('onSuccess');
                        print(params);
                        Navigator.pop(context);
                      },
                      onError: (error) {
                        print('onError');
                        Navigator.pop(context);
                      },
                      onCancel: () {
                        print('cancelled:');
                        Navigator.pop(context);
                      },
                    ),
                  ));

                  // scanQR();
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
                  var res = Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          id: getCurrentUser(),
                        ),
                      ));
                  res.then((value) => setState(() {
                        user = value;
                      }));
                },
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: ClipRRect(
                      child: FittedBox(
                          child: Image.asset('assets/noProfileImage.png'),
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
