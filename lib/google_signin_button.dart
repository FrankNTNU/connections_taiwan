import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase/supabase.dart';

import 'constants.dart';
import 'snackbar_utils.dart';

class GoogleSigninButton extends StatefulWidget {
  const GoogleSigninButton({super.key});

  @override
  State<GoogleSigninButton> createState() => _GoogleSigninButtonState();
}

class _GoogleSigninButtonState extends State<GoogleSigninButton> {
  void signInWithGoogle() {
    try {
      final supabase =
          SupabaseClient(Constants.supabaseUrl, Constants.supabaseKey);
      final googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
      googleSignIn.signIn().then((googleUser) async {
        if (googleUser == null) return;
        final googleAuth = await googleUser.authentication;
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
    return ElevatedButton(
      onPressed: () {
        signInWithGoogle();
      },
      child: const Text('Sign in with Google'),
    );
  }
}
