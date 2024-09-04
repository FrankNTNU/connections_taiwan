import 'package:flutter/material.dart';

import 'leaderboard_dialog.dart';
import 'leaderboard_model.dart';
import 'snackbar_utils.dart';

class UsernameInputDialog extends StatefulWidget {
  const UsernameInputDialog({
    super.key,
    required this.selectedDate,
  });

  final DateTime? selectedDate;

  @override
  State<UsernameInputDialog> createState() => _UsernameInputDialogState();
}

class _UsernameInputDialogState extends State<UsernameInputDialog> {
  String username = '';
  final currentTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AlertDialog(
            title: const Text('恭喜！找到所有有關連性的字。'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    '您於 ${currentTime.toLocal().toString().substring(0, 19)} 完成！\n將你的名字加入排行榜：'),
                TextField(
                  maxLength: 128,
                  autofocus: true,
                  autocorrect: false,
                  onChanged: (value) {
                    username = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('不紀錄'),
              ),
              TextButton(
                onPressed: () async {
                  if (username.isEmpty) {
                    showSnackBar(context, '請輸入你的名字。');
                    return;
                  }
                  if (username.isNotEmpty) {
                    String gameTitle =
                        '${widget.selectedDate!.year}/${widget.selectedDate!.month.toString().padLeft(2, '0')}/${widget.selectedDate!.day.toString().padLeft(2, '0')}';
                    await LeaderboardModel.addToLeaderboard(
                      LeaderboardModel(
                        username: username,
                        timeSolved: currentTime,
                        gameTitle: gameTitle,
                      ),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      // open leaderboard dialog
                      showDialog(
                        context: context,
                        builder: (context) =>
                            LeaderboardDialog(gameTitle: gameTitle),
                      );
                    }
                  } else {
                    showSnackBar(context, '請輸入你的名字。');
                  }
                },
                child: const Text('記錄到排行榜'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
