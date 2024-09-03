import 'package:connections_taiwan/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutContent extends StatelessWidget {
  const AboutContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('本遊戲由NYT的Connections啟發。每局共有4組關聯字，每組關聯字包含四個畫面上出現的字。例如：玫瑰、薔薇、月季、康乃馨都與花有關連。'),
          const Divider(),

          const Text('難度與顏色對應：', style: TextStyle(fontSize: 16)),
          // show color and difficulty name
          for (var difficultyTuple in [
            (Difficulty.easy, '容易'),
            (Difficulty.normal, '中等'),
            (Difficulty.hard, '困難'),
            (Difficulty.expert, '專家'),
          ])
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: difficultyColorMap[difficultyTuple.$1],
                ),
                const SizedBox(width: 8),
                Text(difficultyTuple.$2),
              ],
            ),
          // data privacy
          const Divider(),
          const Row(
            children: [
              // icon
              Icon(Icons.privacy_tip_outlined),
              SizedBox(width: 8),
              Expanded(child: Text('本網站不會收集任何個人資料，也不會使用任何 Cookie。')),
            ],
          ),
          // add author email
          const Divider(),
          Row(
            children: [
              const Icon(Icons.email_outlined),
              const SizedBox(width: 8),
              Expanded(
                  child: Wrap(
                children: [
                  const Text('若有問題或回饋都可以寄信到'),
                  TextButton(
                      onPressed: () {
                        // open email app with launch url
                        launchUrl(Uri.parse(
                            'mailto:${Constants.developerEmail}?subject=關連－臺灣版問題或回饋&body='));
                      },
                      child: const Text(Constants.developerEmail))
                ],
              ))
            ],
          ),

        ],
      ),
    );
  }
}
