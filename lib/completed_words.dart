import 'package:connections_taiwan/constants.dart';
import 'package:connections_taiwan/word_model.dart';
import 'package:flutter/material.dart';

class CompletedWords extends StatelessWidget {
  const CompletedWords({
    super.key,
    required this.difficulitiesSolved,
    required this.words,
    required this.difficultyDescriptionMap,
  });

  final List<Difficulty> difficulitiesSolved;
  final List<WordModel> words;
  final Map<Difficulty, String> difficultyDescriptionMap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 8,
      children: [
        for (var difficulty in difficulitiesSolved)
          if (words
              .where((e) => e.difficulty == difficulty && e.isCompleted)
              .isNotEmpty)
            Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) => Container(
                    height: Constants.wordCardHeight,
                    alignment: Alignment.center,
                    width: (constraints.maxWidth /
                                Constants.wordCardWidthDevisionFactor) *
                            4 +
                        Constants.cardHorizontalSpacing * 3,
                    decoration: BoxDecoration(
                      color: difficultyColorMap[difficulty],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          difficultyDescriptionMap[difficulty]!,
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            words
                                .where((e) =>
                                    e.difficulty == difficulty && e.isCompleted)
                                .map((e) => e.word)
                                .join('、'),
                            style: const TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }
}
