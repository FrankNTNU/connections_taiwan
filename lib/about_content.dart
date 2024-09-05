import 'package:connections_taiwan/constants.dart';
import 'package:flutter/material.dart';

import 'privacy_screen.dart';

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
          const Text(
              '本遊戲，關聯臺灣版，由NYT的Connections啟發。是一個單純娛樂性非營利的平臺。目的在於讓臺灣人也可以在關聯遊戲中娛樂。'),
          const Divider(),
          const Text('遊戲規則：', style: TextStyle(fontSize: 16)),
          const Text('每局共四組關聯字，每組關聯字包含四個畫面上出現的字。例如：玫瑰、薔薇、月季、康乃馨都與花有關連。關聯性的可能為相同的種類、特徵、主題或意思或諧音等。'),
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
          const Divider(),
          // privacy link button
          TextButton(
            onPressed: () {
              // go to /privacy
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PrivacyScreen()));
            },
            child: const Text('隱私權政策'),
          ),
        ],
      ),
    );
  }
}
