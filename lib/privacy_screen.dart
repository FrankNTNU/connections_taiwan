import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'snackbar_utils.dart';

class PrivacyScreen extends StatelessWidget {
  final Function()? goBackToGameScreenOnTap;
  const PrivacyScreen({super.key, this.goBackToGameScreenOnTap});

  @override
  Widget build(BuildContext context) {
    print('PrivacyScreen loaded');
    return Scaffold(
      appBar: AppBar(
        title: const Text('隱私權政策'),
        // a back button to go back to the previous screen
        leading: goBackToGameScreenOnTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => goBackToGameScreenOnTap!(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('關聯臺灣版隱私政策', style: TextStyle(fontSize: 16),),
                const SizedBox(height: 8),
                const Text(
                    '關聯臺灣版致力於保護您的隱私。我們不會收集任何敏感的個人資料，亦不使用任何 Cookie。您的個人資料將不會被分享或提供給任何第三方。關聯臺灣版旨在為玩家提供純粹的遊戲體驗，不包含任何形式的廣告。'),
                    const SizedBox(height: 8),
                    const Text('若您對本遊戲有任何問題、建議或回饋，歡迎隨時聯繫開發者，我們將竭誠為您服務。請將您的信件寄至開發者信箱。'),
                TextButton(
                    onPressed: () {
                      _launchMailClient(context);
                    },
                    child: const Text(Constants.developerEmail)),
                // add version number
                const Divider(),
                const Text('版本號碼：${Constants.version}'),
              ],
            ),
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
