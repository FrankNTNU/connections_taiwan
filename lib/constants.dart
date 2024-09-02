// create a class that holds const values
import 'package:flutter/material.dart';

class Constants {
  static const double wordCardHeight = 90;
  static const double cardHorizontalSpacing = 8;
}

enum Difficulty { easy, normal, hard, expert }

// difficulty and color map
Map<Difficulty, Color> difficultyColorMap = {
  // ##f9df6d
  Difficulty.easy: const Color(0xfff9df6d),
  // #a0c35a
  Difficulty.normal: const Color(0xffa0c35a),
  // #b0c4ef
  Difficulty.hard: const Color(0xffb0c4ef),
  // ba81c5
  Difficulty.expert: const Color(0xffba81c5),
};