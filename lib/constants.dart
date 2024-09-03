// create a class that holds const values
import 'package:flutter/material.dart';

class Constants {
  static const double wordCardHeight = 90;
  static const double cardHorizontalSpacing = 8;
  static const double wordCardWidthDevisionFactor = 4.5;
  static const String developerEmail = 'frankhuang66655@gmail.com';
  // supabaseUrl
  static const String supabaseUrl = 'https://abmdqijlmzgqqlhdqcrc.supabase.co';
  static const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFibWRxaWpsbXpncXFsaGRxY3JjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTMyMzg2ODIsImV4cCI6MjAyODgxNDY4Mn0.Tb4aiBZHYhSeWqH-FBzWpGUzbAPREfl66o8x2Zwyavc';
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
