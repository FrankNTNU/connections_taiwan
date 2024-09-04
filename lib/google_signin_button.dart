import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase/supabase.dart';

import 'constants.dart';
class GoogleSigninButton extends StatefulWidget {
  const GoogleSigninButton({super.key});

  @override
  State<GoogleSigninButton> createState() => _GoogleSigninButtonState();
}

class _GoogleSigninButtonState extends State<GoogleSigninButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final supabase =
        SupabaseClient(Constants.supabaseUrl, Constants.supabaseKey);
       
      },
      child: const Text('Sign in with Google'),
    );
  }
}