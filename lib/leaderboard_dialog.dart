import 'package:connections_taiwan/leaderboard_model.dart';
import 'package:flutter/material.dart';

class LeaderboardDialog extends StatelessWidget {
  const LeaderboardDialog({
    super.key,
    required this.gameTitle,
  });

  final String gameTitle;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('排行榜 - $gameTitle'),
      content: FutureBuilder<List<LeaderboardModel>>(
        future: LeaderboardModel.loadData(gameTitle),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: const Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: const Center(child: Text('發生錯誤')));
          }
          if (snapshot.hasData) {
            final leaderboard = snapshot.data!;
            // if empty then show no data
            if (leaderboard.isEmpty) {
              return Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5),
                  child: const Center(child: Text('目前沒有資料')));
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < leaderboard.length; i++)
                    ListTile(
                      // show gold, silver, bronze medal for top 3
                      leading: Container(
                        alignment: Alignment.center,
                        width: 32,
                        child: i == 0
                            ? const Icon(Icons.emoji_events,
                                color: Colors.amber)
                            : i == 1
                                ? const Icon(Icons.emoji_events,
                                    color: Colors.grey)
                                : i == 2
                                    ? const Icon(Icons.emoji_events,
                                        color: Colors.brown)
                                    : // show ranking with a circle avatar
                                    Text(
                                        '${i + 1}',
                                        textAlign: TextAlign.center,
                                      ),
                      ),
                      title: Text(leaderboard[i].username),
                      subtitle: Text(leaderboard[i]
                          .timeSolved
                          .toString()
                          .substring(0, 19)),
                    ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('關閉'),
        ),
      ],
    );
  }
}
