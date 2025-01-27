import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PolicyWidget extends StatelessWidget {
  const PolicyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double policyTextSize = 14;
    return RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(children: [
          TextSpan(
              style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: policyTextSize),
              text: "Bycontinuing".tr()),
          TextSpan(
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: policyTextSize),
              text: "TermsofServices".tr(),
              recognizer: TapGestureRecognizer()
                // https://www.termsfeed.com/live/90f405ab-00ec-4ae5-9dc9-28ca3fe34aa9
                ..onTap = () async {
                  final Uri uri = Uri(
                      scheme: 'https',
                      host: 'www.termsfeed.com',
                      path: 'live/90f405ab-00ec-4ae5-9dc9-28ca3fe34aa9');
                  await launchUrl(uri);
                }),
          TextSpan(
              style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: policyTextSize),
              text: "manage".tr()),
          TextSpan(
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: policyTextSize),
              text: "Privacy".tr(),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  // https://www.termsfeed.com/live/b486a204-d33c-4957-9611-b20ccc180ed6
                  final Uri uri = Uri(
                      scheme: 'https',
                      host: 'www.termsfeed.com',
                      path: 'live/b486a204-d33c-4957-9611-b20ccc180ed6');
                  await launchUrl(uri);
                }),
          TextSpan(
              style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: policyTextSize),
              text: "and".tr()),
          TextSpan(
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: policyTextSize),
              text: "CookiePolicy".tr(),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  // https://www.termsfeed.com/live/ee0a92b9-fe63-401c-b392-6c5eb992ce41
                  final Uri uri = Uri(
                      scheme: 'https',
                      host: 'www.termsfeed.com',
                      path: 'live/ee0a92b9-fe63-401c-b392-6c5eb992ce41');
                  await launchUrl(uri);
                }),
          TextSpan(
              style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: policyTextSize),
              text: "."),
        ]));
  }
}
