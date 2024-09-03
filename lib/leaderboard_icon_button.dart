import 'package:connections_taiwan/leaderboard_model.dart';
import 'package:flutter/material.dart';

class LeaderboardIconButton extends StatelessWidget {
  const LeaderboardIconButton({
    super.key,
    required this.selectedDate,
  });

  final DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final gameTitle =
            '${selectedDate!.year}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}';
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('排行榜 - $gameTitle'),
            content: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: FutureBuilder<List<LeaderboardModel>>(
                future: LeaderboardModel.loadData(gameTitle),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('發生錯誤'));
                  }
                  if (snapshot.hasData) {
                    final leaderboard = snapshot.data!;
                    // if empty then show no data
                    if (leaderboard.isEmpty) {
                      return const Center(child: Text('目前沒有資料'));
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var i = 0; i < leaderboard.length; i++)
                            ListTile(
                              // show gold, silver, bronze medal for top 3
                              leading: i == 0
                                  ? const Icon(Icons.emoji_events,
                                      color: Colors.amber)
                                  : i == 1
                                      ? const Icon(Icons.emoji_events,
                                          color: Colors.grey)
                                      : i == 2
                                          ? const Icon(Icons.emoji_events,
                                              color: Colors.brown)
                                          : null,
                              title:
                                  Text('${i + 1}. ${leaderboard[i].username}'),
                              subtitle: Text(leaderboard[i]
                                  .timeSolved
                                  .toLocal()
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
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('關閉'),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.leaderboard_outlined),
    );
  }
}
