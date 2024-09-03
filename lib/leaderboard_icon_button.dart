import 'package:flutter/material.dart';

import 'leaderboard_dialog.dart';

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
          builder: (context) => LeaderboardDialog(gameTitle: gameTitle),
        );
      },
      icon: const Icon(Icons.leaderboard_outlined),
    );
  }
}
