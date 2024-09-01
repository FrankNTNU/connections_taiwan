import 'dart:convert';

import 'package:connections_taiwan/game_screen.dart';
import 'package:flutter/services.dart';

class WordModel {
  final String word;
  final Difficulty difficulty;
  final bool isSelected;
  final bool isCompleted;
  // A constructor that allows word and difficulity only
  const WordModel({
    required this.word,
    required this.difficulty,
    this.isSelected = false,
    this.isCompleted = false,
  });
  // copyWith
  WordModel copyWith({
    String? word,
    Difficulty? difficulty,
    bool? isSelected,
    bool? isCompleted,
  }) {
    return WordModel(
      word: word ?? this.word,
      difficulty: difficulty ?? this.difficulty,
      isSelected: isSelected ?? this.isSelected,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'difficulty': difficulty.name,
      'isSelected': isSelected,
      'isCompleted': isCompleted,
    };
  }

  // fromJson
  factory WordModel.fromJson(Map<String, dynamic> json) {
    print('json: $json');
    return WordModel(
      word: json['word'],
      difficulty: Difficulty.values.firstWhere(
        (element) => element.name == json['difficulty'],
      ),
      isSelected: json['isSelected'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  static Future<(List<WordModel>, Map<Difficulty, String>)> loadData(
      DateTime? dateTime) async {
    // date in yyyy_mm_dd format
    final String dateString = (dateTime ?? DateTime.now())
        .toString()
        .split(' ')[0]
        .replaceAll('-', '_');
    print('dateString: $dateString');
    String jsonString =
        await rootBundle.loadString('assets/json/data_$dateString.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    print('jsonData: $jsonData');
    // Load difficulty descriptions
    final Map<Difficulty, String> difficultyDescriptionMap = {};
    (jsonData['difficultyDescriptions'] as Map<String, dynamic>)
        .forEach((key, value) {
      difficultyDescriptionMap[
          Difficulty.values.firstWhere((e) => e.name == key)] = value;
    });

    // Load words list
    List<WordModel> words = (jsonData['words'] as List)
        .map((wordJson) => WordModel.fromJson(wordJson))
        .toList();

    return (words, difficultyDescriptionMap);
  }
}
