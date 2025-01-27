import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/feature_home/widgets/user_events.dart';
import 'package:viajuntos/feature_home/widgets/events_tab_menu.dart';
import 'package:viajuntos/utils/api_controller.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  Future<void> isPremium() async {
    final response = await APICalls()
        .getItem('/v1/users/:0/get_premium', [APICalls().getCurrentUser()]);
    bool activated = false;
    if (response.body.contains('"User is Premium"')) activated = true;

    APICalls().setIsPremium(activated);
  }

  @override
  Widget build(BuildContext context) {
    isPremium();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Myevents',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18))
              .tr(),
          const SizedBox(height: 20),
          const UserEventsList(),
          const SizedBox(height: 20),
          Text('Yourcalendar',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18))
              .tr(),
          const SizedBox(height: 20),
          const EventsTabMenu()
        ],
      ),
    );
  }
}
