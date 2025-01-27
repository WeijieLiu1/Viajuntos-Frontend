// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:viajuntos/feature_user/screens/link_user.dart';
import 'package:viajuntos/feature_user/services/signIn_facebook.dart';
import 'package:viajuntos/feature_user/services/signIn_google.dart';
import 'package:viajuntos/feature_user/widgets/policy.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:viajuntos/feature_user/services/login_signUp.dart';
import 'package:viajuntos/utils/go_to.dart';

import 'form_register_CS.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);
  final userAPI uapi = userAPI();
  @override
  Widget build(BuildContext context) {
    double borderradius = 10.0;
    double policyTextSize = 14;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0x00c8c8c8),
          title: const Text('register').tr(),
          leading: IconButton(
            iconSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
            icon: const Icon(Icons.arrow_back_ios_new_sharp),
            onPressed: () {
              Navigator.of(context).pushNamed('/welcome');
            },
          ),
        ),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(children: <Widget>[
                const SizedBox(height: 60),
                // Container(
                //   alignment: Alignment.center,
                //   padding: const EdgeInsets.all(10),
                //   child: SignInButton(
                //     Buttons.Google,
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(borderradius)),
                //     text: "ContinuewithGoogle".tr(),
                //     onPressed: () => _handleSignInGoogle(
                //         context), //{print("object"); FacebookSignInApi.logout2();}
                //     // onPressed: () =>
                //     //     signInWithGoogle(), //{print("object"); FacebookSignInApi.logout2();}
                //   ),
                // ),
                // Container(
                //   alignment: Alignment.center,
                //   padding: const EdgeInsets.all(10),
                //   child: SignInButton(
                //     Buttons.Facebook,
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(borderradius)),
                //     text: "ContinuewithFacebook".tr(),
                //     onPressed: () => _handleSignInFacebook(context),
                //   ),
                // ),
                // Container(
                //   alignment: Alignment.center,
                //   padding: const EdgeInsets.all(10),
                //   child: SignInButton(
                //     Buttons.GitHub,
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(borderradius)),
                //     text: "ContinuewithGithub".tr(),
                //     onPressed: () => _handleSignInGithub(context),
                //   ),
                // ),
                // const SizedBox(height: 10),
                // Container(
                //   alignment: Alignment.center,
                //   padding: const EdgeInsets.all(10),
                //   child: const Text(
                //     "or",
                //     style: TextStyle(color: Colors.black45, fontSize: 16),
                //   ).tr(),
                // ),
                const SizedBox(height: 50),
                Image.asset(
                  "assets/Banner.png",
                  height: MediaQuery.of(context).size.height / 10,
                  width: MediaQuery.of(context).size.width / 1.5,
                ),
                const SizedBox(height: 100),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: SignInButton(
                    Buttons.Email,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderradius)),
                    text: "ContinuewithEmail".tr(),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: policyTextSize),
                          text: "Alreadyhaveanaccount".tr()),
                      TextSpan(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: policyTextSize),
                          text: "login".tr(),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(context, '/login',
                                  arguments: GoTo(() =>
                                      Navigator.pushNamed(context, '/home')));
                            }),
                    ]),
                  ),
                ),
                const SizedBox(height: 100),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const PolicyWidget(),
                ),
              ])),
        ));
  }

  void _handleSignUpGoogle(BuildContext context, Response response,
      GoogleSignInAuthentication googleSignInAuthentication) {
    String auxToken = googleSignInAuthentication.accessToken.toString();
    if (response.statusCode == 200) {
      Map<String, dynamic> ap = json.decode(response.body);
      print(ap);
      //Map<String, dynamic> ap = await uapi.checkUserGoogle(googleSignInAuthentication.accessToken);
      if (ap["action"] == "continue") {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => FormRegisterCS(auxToken, "google")),
            (route) => false);
        GoogleSignInApi.logout2();
      } else if (ap["action"] == "error") {
        GoogleSignInApi.logout2();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("Userexists").tr(),
            content: Text("wantLogin").tr(),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login',
                      arguments: GoTo(() => Navigator.of(context)
                          .pushNamedAndRemoveUntil('/home', (route) => false))),
                  child: Text("Yes").tr()),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("No").tr()),
            ],
          ),
        );
      } else if (ap["action"] == "link_auth") {
        GoogleSignInApi.logout2();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("UserexistsViajuntos").tr(),
            content: Text("LinkViajuntos").tr(),
            actions: <Widget>[
              TextButton(
                  onPressed: () => {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LinkScreen(
                                    "", "", "google", auxToken.toString())),
                            (route) => false)
                      },
                  child: Text("Yes").tr()),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("No".tr())),
            ],
          ),
        );
      }
    } else if (response.statusCode == 400) {
      String errorMessage = json.decode(response.body)['error_message'];
      if (errorMessage ==
          "Authentication method not available for this email") {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("methodnotavailableemail").tr(),
            content: Text("LinkViajuntos").tr(),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LinkScreen(
                              "", "", "google", auxToken.toString())),
                      (route) => false),
                  //Navigator.of(context).pushNamed('/welcome'),
                  child: Text("Yes").tr()),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("No").tr()),
            ],
          ),
        );
        Navigator.pushNamed(context, '/login',
            arguments: GoTo(() => Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false)));
      } else if (errorMessage == "Google token was invalid") {
        Navigator.pushNamed(context, '/login',
            arguments: GoTo(() => Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false)));
      }
    }
  }

  void _handleSignUpFacebook(
      BuildContext context, Response response, String accessToken) {
    if (response.statusCode == 200) {
      Map<String, dynamic> ap = json.decode(response.body);
      if (ap["action"] == "continue") {
        FacebookSignInApi.logout();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => FormRegisterCS(accessToken, "facebook")),
            (route) => false);
        FacebookSignInApi.logout();
      } else if (ap["action"] == "error") {
        FacebookSignInApi.logout();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("Userexists").tr(),
            content: Text("wantLogin").tr(),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login',
                      arguments: GoTo(() => Navigator.of(context)
                          .pushNamedAndRemoveUntil('/home', (route) => false))),
                  child: Text("Yes").tr()),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("No").tr()),
            ],
          ),
        );
      } else if (ap["action"] == "link_auth") {
        FacebookSignInApi.logout();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("UserexistsViajuntos").tr(),
            content: Text("LinkViajuntos").tr(),
            actions: <Widget>[
              TextButton(
                  onPressed: () => {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LinkScreen(
                                    "", "", "facebook", accessToken)),
                            (route) => false),
                      },
                  child: Text("Yes").tr()),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("No").tr()),
            ],
          ),
        );
      }
    } else if (response.statusCode == 400) {
      String errorMessage = json.decode(response.body)['error_message'];
      if (errorMessage ==
          "Authentication method not available for this email") {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("methodnotavailableemail").tr(),
            content: Text("LinkViajuntos").tr(),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LinkScreen("", "", "facebook", accessToken)),
                      (route) => false),
                  child: Text("Yes").tr()),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("No").tr()),
            ],
          ),
        );
      } else if (errorMessage == "Facebook token was invalid") {
        Navigator.of(context).pushNamed('/signup');
      }
    } else {
      /* print('status code : ' + response.statusCode.toString());
      print('error_message: ' + json.decode(response.body)['error_message']);
      print("Undefined Error"); */
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    print("signInWithGoogle1");
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    print("signInWithGoogle2");
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    print("signInWithGoogle3");
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _handleSignInGoogle(BuildContext context) async {
    try {
      print("signInWithGoogle1");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // final user = await GoogleSignInApi.login();
      // print("_handleSignInGoogle2");
      if (googleUser == null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('SignupFailed').tr(),
            content: Text("tryAgain").tr(),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Ok").tr()),
            ],
          ),
        );
      } else {
        print("signInWithGoogle2");
        // Obtain the auth details from the request
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;
        print("signInWithGoogle3");
        // Create a new credential
        // final credential = GoogleAuthProvider.credential(
        //   accessToken: googleAuth?.accessToken,
        //   idToken: googleAuth?.idToken,
        // );

        if (googleAuth != null) {
          Response response =
              await uapi.checkUserGoogle(googleAuth.accessToken);
          _handleSignUpGoogle(context, response, googleAuth);
        }
        // GoogleSignInAuthentication googleSignInAuthentication =
        //     await googleUser.authentication;

        //https://www.googleapis.com/oauth2/v3/userinfo?access_token=googleSignInAuthentication.accessToken
        //https://www.googleapis.com/oauth2/v3/userinfo?access_token=ya29.A0ARrdaM-Uo5BGubza4xGpXK0JuFiAATuEHI_5UXjx-CWGtddi0Q_Qg6HxX-mRoNzKeQTc1ZyNs4JdwacIzGdSNQnzUlSyCfP3AVpK2OMaQcbqPcT3eM_4wSZSyKaYwIxhCZhI5zkLAtpCgHZj-XQ1vKUaOTrh

        //we can decode with this idtoken
        //print(googleSignInAuthentication.idToken);

        /*
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoggedInPage(
            user: user,
          ),
        )
        );
        */
      }
    } catch (error) {
      //print(error);
    }
  }

  Future<void> _handleSignInFacebook(BuildContext context) async {
    try {
      final LoginResult result =
          await FacebookAuth.i.login(permissions: ['public_profile', 'email']);
      if (result.status == LoginStatus.success) {
        final accessTokenFacebook = result.accessToken?.token.toString();

        Response response = await uapi.checkUserFacebook(accessTokenFacebook);
        _handleSignUpFacebook(context, response, accessTokenFacebook!);
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('SigninFailed').tr(),
            content: Text("tryAgain").tr(),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Ok").tr()),
            ],
          ),
        );
      }
    } catch (error) {
      //print(error);
    }
  }

  Future<void> _handleSignInGithub(BuildContext context) async {
    try {
      print("signInWithGithub1");
      // 3edd3eac6d4f310cc67856cfaea8ee4587dfae0e
      GithubAuthProvider githubAuthProvider = GithubAuthProvider();
      UserCredential uc =
          await FirebaseAuth.instance.signInWithProvider(githubAuthProvider);
      // Trigger the authentication flow

      // final user = await GoogleSignInApi.login();
      print("signInWithGithub2");
      if (uc == null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('SignupFailed').tr(),
            content: Text("tryAgain").tr(),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Ok").tr()),
            ],
          ),
        );
      } else {
        // Obtain the auth details from the request
        String email = uc.user!.email!;
        String token = uc.user!.refreshToken!.toString();
        print("email+token: " + email + " " + token);

        // Response response =
        //     await uapi.checkUserGithub(googleAuth.accessToken);
        // _handleSignUpGoogle(context, response, googleAuth);
        // Response response =
        //     await uapi.checkUserGithub(googleAuth.accessToken);
        // _handleSignUpGoogle(context, response, googleAuth);
      }
    } catch (error) {
      //print(error);
    }
  }
}
