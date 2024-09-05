import 'package:connections_taiwan/constants.dart';
import 'package:supabase/supabase.dart';

class LeaderboardModel {
  final String username;
  final DateTime timeSolved;
  final String gameTitle;

  const LeaderboardModel({
    required this.username,
    required this.timeSolved,
    required this.gameTitle,
  });

  // copyWith
  LeaderboardModel copyWith({
    String? username,
    DateTime? timeSolved,
    DateTime? gameDate,
  }) {
    return LeaderboardModel(
      username: username ?? this.username,
      timeSolved: timeSolved ?? this.timeSolved,
      gameTitle: gameTitle,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'time_solved': timeSolved.toIso8601String(),
      'game_title': gameTitle,
    };
  }

  // read from Supabase
  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      username: json['username'],
      timeSolved: DateTime.parse(json['time_solved']),
      gameTitle: json['game_title'],
    );
  }

  // read from Supabase
  static Future<List<LeaderboardModel>> loadData(String? gameTitle) async {
    print('gameTitle: $gameTitle');
    if (gameTitle == null) {
      return [];
    }
    final supabase =
        SupabaseClient(Constants.supabaseUrl, Constants.supabaseKey);
    final response = await supabase.from('leaderboard').select().eq(
          'game_title',
          gameTitle,
        );
    print('Response: $response');
    List<LeaderboardModel> leaderboard =
        response.map((e) => LeaderboardModel.fromJson(e)).toList();
    leaderboard = leaderboard.toList()
      ..sort((a, b) => a.timeSolved.compareTo(b.timeSolved));
    print('Leaderboard: $leaderboard');

    return leaderboard;
  }

  // add to leaderboard
  static Future<void> addToLeaderboard(
      LeaderboardModel leaderboardModel) async {
    final supabase =
        SupabaseClient(Constants.supabaseUrl, Constants.supabaseKey);
    final response = await supabase.from('leaderboard').insert([
      leaderboardModel.toJson(),
    ]);
    print('Response: $response');
  }
}
