import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase/supabase.dart';

import 'constants.dart';
import 'snackbar_utils.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

class GoogleSigninButton extends StatefulWidget {
  const GoogleSigninButton({super.key});

  @override
  State<GoogleSigninButton> createState() => _GoogleSigninButtonState();
}

class _GoogleSigninButtonState extends State<GoogleSigninButton> {
  final _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
      "https://www.googleapis.com/auth/userinfo.profile"
    ],
    clientId:
        '428534230815-bim6amjledjf0308ucplcilrprbivvri.apps.googleusercontent.com',
  );
  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? googleUser) {
// you can handel the returned account here
      print('Google User: $googleUser');
    });
  }

  void signInWithGoogle() {
    try {
      final supabase =
          SupabaseClient(Constants.supabaseUrl, Constants.supabaseKey);

      _googleSignIn.signIn().then((googleUser) async {
        print('Google User: $googleUser');
        if (googleUser == null) return;
        final googleAuth = await googleUser.authentication;
        print(
            'Google Auth: $googleAuth, idToken: ${googleAuth.idToken}, accessToken: ${googleAuth.accessToken}}');

        final response = await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken ?? '',
        );
        print('Response: $response');
        if (response.user != null) {
          showSnackBar(context, '登入成功！');
        } else {
          showSnackBar(context, '登入失敗，請再試一次。');
        }
      });
    } catch (e) {
      showSnackBar(context, '登入失敗，請再試一次。');
    }
  }

  @override
  Widget build(BuildContext context) {
    return (GoogleSignInPlatform.instance as web.GoogleSignInPlugin)
        .renderButton();
    return ElevatedButton(
      onPressed: () {
        signInWithGoogle();
      },
      child: const Text('Sign in with Google'),
    );
  }
}
