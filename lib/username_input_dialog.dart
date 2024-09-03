import 'package:connections_taiwan/leaderboard_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  DateTime? timeSolved;
  String gameTitle = '';
  @override
  void initState() {
    super.initState();
    checkIfCompleted();
    setState(() {
      gameTitle =
          '${widget.selectedDate!.year}/${widget.selectedDate!.month.toString().padLeft(2, '0')}/${widget.selectedDate!.day.toString().padLeft(2, '0')}';
    });
  }

  void checkIfCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var timeSolvedCached = prefs.getString(gameTitle);
    if (timeSolvedCached != null) {
      setState(() {
        timeSolved = DateTime.parse(timeSolvedCached);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AlertDialog(
            title: const Text('恭喜！您找到所有關聯組合！'),
            content: timeSolved != null
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '您於 ${currentTime.toLocal().toString().substring(0, 19)} 完成！\n您已經在排行榜上了！',
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  LeaderboardDialog(gameTitle: gameTitle),
                            );
                          },
                          child: const Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('查看排行榜'),
                              SizedBox(width: 8),
                              Icon(Icons.leaderboard_outlined),
                            ],
                          ))
                    ],
                  )
                : Column(
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
            actions: timeSolved != null
                ? [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('關閉'),
                    ),
                ]
                : [
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
                          // save game title and time solved to shared preferences
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString(gameTitle, currentTime.toString());
                          setState(() {
                            timeSolved = currentTime;
                          });
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
