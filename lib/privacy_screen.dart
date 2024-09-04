import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'snackbar_utils.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('PrivacyScreen loaded');
    return Scaffold(
      appBar: AppBar(title: const Text('隱私權政策')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  const Text(
                      '關聯臺灣版不會收集任何個人資料，也不會使用任何 Cookie。關聯臺灣版是為了提供一個有趣的遊戲體驗，並且不會有任何廣告。\n若您有任何問題或回饋，請寄信到開發者信箱。'),
                  TextButton(
                      onPressed: () {
                        _launchMailClient(context);
                      },
                      child: const Text(Constants.developerEmail))
                ],
              ),
              // add version number
              const Divider(),
              const Text('版本號碼：${Constants.version}'),
            ],
          ),
        ),
      ),
    );
  }
}

void _launchMailClient(BuildContext context) async {
  String mailUrl =
      'mailto:${Constants.developerEmail}?subject=關連－臺灣版問題或回饋&body=';

  try {
    var url = Uri.parse(mailUrl);
    await launchUrl(url);
  } catch (e) {
    await Clipboard.setData(
        const ClipboardData(text: Constants.developerEmail));
    if (context.mounted) showSnackBar(context, '已將開發者信箱複製到剪貼簿。');
  }
}
