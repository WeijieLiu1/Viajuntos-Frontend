// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:viajuntos/feature_map/screens/EventSearchMap.dart';
import 'package:viajuntos/feature_navigation/screens/navigation.dart';
import 'package:viajuntos/feature_navigation/screens/profile.dart';
import 'package:viajuntos/feature_user/screens/banned_user_page.dart';
import 'package:viajuntos/feature_user/screens/change_password.dart';
import 'package:viajuntos/feature_user/screens/edit_profile.dart';
import 'package:viajuntos/feature_user/screens/friend_request.dart';
import 'package:viajuntos/feature_user/screens/loading_page.dart';
import 'package:viajuntos/feature_user/screens/login_screen.dart';
import 'package:viajuntos/feature_user/screens/register_viajuntos.dart';
import 'package:viajuntos/feature_user/screens/signup_screen.dart';
import 'package:viajuntos/feature_user/screens/welcome_screen.dart';
import 'package:viajuntos/firebase_options.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/utils/friend_request_notifier.dart';

import 'feature_user/screens/languages.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    // default D8:48:B0:ED:60:2B:9E:C6:5C:39:63:28:96:A1:13:22:E1:8E:67:18:CB:B3:EB:0B:1B:1A:07:40:58:A9:F8:DC
    // this app b5:ea:4c:ea:3d:b5:c8:d4:8e:16:df:07:0f:5d:07:39:f6:8d:af:ef:12:e8:78:f4:05:eb:53:ee:e7:d5:65:87
  );

  await EasyLocalization.ensureInitialized();
  //final prefs = await SharedPreferences.getInstance();

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('ca', 'ES'),
        Locale('en'),
        Locale('es', 'ES'),
        Locale('zh', 'CN')
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      saveLocale: true,
      child: ChangeNotifierProvider(
        create: (_) => RedDotNotifier(), // 初始化全局状态管理器
        child: MyApp(),
      ),
    ),
  );
  // 确保 navigatorKey.currentState 不为 null
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   APICalls().tryInitializeFromPreferences();
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    // hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return ScreenUtilInit(
        designSize: const Size(1080, 2220),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          // ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          //   // 自定义错误屏幕
          //   return CustomErrorScreen(errorDetails: errorDetails);
          // };
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            navigatorKey: navigatorKey,
            title: 'Viajuntos',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                cardColor: Colors.white,
                primaryColor: Colors.green,
                tabBarTheme: TabBarTheme(
                  labelColor: Theme.of(context).colorScheme.secondary,
                  labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary), // color for text
                  indicator: UnderlineTabIndicator(
                      // color for indicator (underline)
                      borderSide: BorderSide(
                          width: 2,
                          color: Theme.of(context).colorScheme.primary)),
                ),
                colorScheme: ColorScheme(
                  brightness: Brightness.light,
                  primary: HexColor('22577A'),
                  onPrimary: Colors.grey.shade100,
                  secondary: HexColor('38A3A5'),
                  onSecondary: Colors.grey.shade100,
                  error: HexColor('ED4337'),
                  onError: HexColor('D4AC2B'),
                  background: Colors.grey.shade100,
                  onBackground: Colors.black,
                  surface: Colors.black,
                  onSurface: HexColor('767676'),
                )),
            initialRoute: '/welcome',
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: BannedUserPage(),
            routes: {
              '/loading_Page': (_) => const LoadingScreen(),
              '/welcome': (_) => const WelcomeScreen(),
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => SignUpScreen(),
              '/register': (_) => const RegisterScreen(),
              '/home': (_) => const NavigationBottomBar(),
              '/map_screen': (_) => const EventSearchMap(),
              '/profile': (_) => const ProfileScreen(id: "0"),
              '/edit_profile': (_) => const EditarProfile(),
              '/change_password': (_) => const ChangePassword(),
              '/languages': (_) => const LanguagesOptions(),
              '/banned_user_page': (_) => BannedUserPage(),
              '/friend_request': (_) => FriendRequest(),
              // '/testScreen': (_) => const TestScreen(),
            },
          );
        });
  }
}


// // socket.io example
// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// void main() => runApp(MyApp());

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late IO.Socket socket;
//   List<String> messages = [];
//   TextEditingController messageController = TextEditingController();
//   late String currentName = "Tommy";

//   @override
//   void initState() {
//     super.initState();
//     socket = IO.io('http://127.0.0.1:5000');
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



// // add event to system calendar example
// import 'package:flutter/material.dart';

// import 'package:add_2_calendar/add_2_calendar.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
//       GlobalKey<ScaffoldMessengerState>();

//   Event buildEvent({Recurrence? recurrence}) {
//     return Event(
//       title: 'Test eventeee',
//       description: 'example',
//       location: 'Flutter app',
//       startDate: DateTime.now(),
//       endDate: DateTime.now().add(Duration(minutes: 30)),
//       allDay: false,
//       iosParams: IOSParams(
//           // reminder: Duration(minutes: 40),
//           // url: "http://example.com",
//           ),
//       androidParams: AndroidParams(
//         emailInvites: ["test@example.com"],
//       ),
//       recurrence: recurrence,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       scaffoldMessengerKey: scaffoldMessengerKey,
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Add event to calendar example'),
//         ),
//         body: ListView(
//           // mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ListTile(
//               title: Text('Add normal event'),
//               trailing: Icon(Icons.calendar_today),
//               onTap: () {
//                 Add2Calendar.addEvent2Cal(
//                   buildEvent(),
//                 );
//               },
//             ),
//             Divider(),
//             ListTile(
//               title: const Text('Add event with recurrence 1'),
//               subtitle: const Text("weekly for 3 months"),
//               trailing: Icon(Icons.calendar_today),
//               onTap: () {
//                 Add2Calendar.addEvent2Cal(buildEvent(
//                   recurrence: Recurrence(
//                     frequency: Frequency.weekly,
//                     endDate: DateTime.now().add(Duration(days: 60)),
//                   ),
//                 ));
//               },
//             ),
//             Divider(),
//             ListTile(
//               title: const Text('Add event with recurrence 2'),
//               subtitle: const Text("every 2 months for 6 times (1 year)"),
//               trailing: Icon(Icons.calendar_today),
//               onTap: () {
//                 Add2Calendar.addEvent2Cal(buildEvent(
//                   recurrence: Recurrence(
//                     frequency: Frequency.monthly,
//                     interval: 2,
//                     ocurrences: 6,
//                   ),
//                 ));
//               },
//             ),
//             Divider(),
//             ListTile(
//               title: const Text('Add event with recurrence 3'),
//               subtitle:
//                   const Text("RRULE (android only) every year for 10 years"),
//               trailing: Icon(Icons.calendar_today),
//               onTap: () {
//                 Add2Calendar.addEvent2Cal(buildEvent(
//                   recurrence: Recurrence(
//                     frequency: Frequency.yearly,
//                     rRule: 'FREQ=YEARLY;COUNT=10;WKST=SU',
//                   ),
//                 ));
//               },
//             ),
//             Divider(),
//           ],
//         ),
//       ),
//     );
//   }
// }
