// ignore_for_file: file_names

import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  //static final _clientID = '829727723302-2v1fsmoahbuofka8kgp864ts17r6b6c5.apps.googleusercontent.com';
  static final _googleSignIn = GoogleSignIn(
      clientId: _clientIDWeb,
      scopes: <String>['email', 'https://www.googleapis.com/auth/calendar']);
  static const _clientIDWeb =
      '19640108832-qnaapop6ivc2tn3blak8grfauopdejs2.apps.googleusercontent.com';
  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
  //https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/androidpublisher&response_type=code&access_type=offline&redirect_uri=http://localhost:8080&client_id=829727723302-2v1fsmoahbuofka8kgp864ts17r6b6c5.apps.googleusercontent.com
  //http://localhost:8080
  //baseLocalUrl https://viajuntos-production.herokuapp.com
  //829727723302-2v1fsmoahbuofka8kgp864ts17r6b6c5.apps.googleusercontent.com
  static Future logout() => _googleSignIn.disconnect();
  static Future logout2() => _googleSignIn.signOut();
}
