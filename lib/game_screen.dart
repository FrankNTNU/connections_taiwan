import 'dart:convert';

import 'package:connections_taiwan/constants.dart';
import 'package:connections_taiwan/word_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'snackbar_utils.dart';
import 'word_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  List<WordModel> words = [];
  Map<Difficulty, String> difficultyDescriptionMap = {};
  List<Difficulty> difficulitiesSolved = [];
  @override
  void initState() {
    super.initState();
    WordModel.loadData(null).then((value) {
      setState(() {
        words = value.$1;
        words.shuffle();
        difficultyDescriptionMap = value.$2;
      });
      syncWordsFromSharedPreferences();
    });
  }

  void wordCardOnTap(String word) {
    bool isCurrentSelected = words.firstWhere((e) => e.word == word).isSelected;
    // if there are already 4 selected words
    bool isMaxSelected =
        words.where((e) => e.isSelected).length == 4 && !isCurrentSelected;
    if (isMaxSelected) {
      showSnackBar(context, '已經選擇了四個字，請取消選擇後再選擇新的字。');
      return;
    }
    setState(() {
      words = words.map((e) {
        if (e.word == word) {
          return e.copyWith(isSelected: !e.isSelected);
        }
        return e;
      }).toList();
    });
    // Save words to Shared Preferences
    saveWordsToSharedPreferences();
  }

  void checkAnswers() {
    bool isNoneSelected = words.where((e) => e.isSelected).isEmpty;
    if (isNoneSelected) {
      showSnackBar(context, '請選擇字後再提交。');
      return;
    }
    bool isSelectedWordsNotFour = words.where((e) => e.isSelected).length != 4;
    if (isSelectedWordsNotFour) {
      showSnackBar(context, '請選擇四個字後再提交。');
      return;
    }
    bool currentlySelectedWordsSameDifficulty = words
            .where((e) => e.isSelected)
            .map((e) => e.difficulty)
            .toSet()
            .length ==
        1;
    if (!currentlySelectedWordsSameDifficulty) {
      showSnackBar(context, '不正確。請選擇四個有關聯的字。');
      return;
    }
    if (currentlySelectedWordsSameDifficulty) {
      setState(() {
        words = words.map((e) {
          if (e.isSelected) {
            return e.copyWith(isCompleted: true);
          }
          return e;
        }).toList();
      });
      setState(() {
        difficulitiesSolved.add(
          words.firstWhere((e) => e.isSelected).difficulty,
        );
      });
      deSelectAll();
      // save words to Shared Preferences
      saveWordsToSharedPreferences();
      showSnackBar(context, '正確！找到四個有關連性的字。');
    }
    bool isAllCompleted = words.where((e) => !e.isCompleted).isEmpty;
    if (isAllCompleted) {
      showSnackBar(context, '恭喜！找到所有有關連性的字。');
    }
  }

  void deSelectAll() {
    setState(() {
      words = words.map((e) {
        return e.copyWith(isSelected: false);
      }).toList();
    });
  }

  void shuffleWords() {
    setState(() {
      // Separate the completed and uncompleted words
      final completedWords = words.where((e) => e.isCompleted).toList();
      final uncompletedWords = words.where((e) => !e.isCompleted).toList();

      // Shuffle the uncompleted words
      uncompletedWords.shuffle();

      // Rebuild the words list with shuaffled uncompleted words and original completed words
      words = words.map((e) {
        if (e.isCompleted) {
          return completedWords.removeAt(0);
        } else {
          return uncompletedWords.removeAt(0);
        }
      }).toList();
    });
  }

  void resetCompletedAndSelected() {
    setState(() {
      words = words.map((e) {
        return e.copyWith(isSelected: false, isCompleted: false);
      }).toList();
      difficulitiesSolved = [];
    });
    saveWordsToSharedPreferences();
  }

  void saveWordsToSharedPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(
        'words',
        words.map((e) => json.encode(e.toJson())).toList(),
      );
      // save difficulitiesSolved to Shared Preferences
      prefs.setStringList(
        'difficulitiesSolved',
        difficulitiesSolved.map((e) => e.name).toList(),
      );
    });
  }

  void syncWordsFromSharedPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      final List<String>? wordsJson = prefs.getStringList('words');
      if (wordsJson != null) {
        setState(() {
          words =
              wordsJson.map((e) => WordModel.fromJson(json.decode(e))).toList();
        });
      }
      final List<String>? difficulitiesSolvedJson =
          prefs.getStringList('difficulitiesSolved');
      if (difficulitiesSolvedJson != null) {
        setState(() {
          difficulitiesSolved = difficulitiesSolvedJson
              .map((e) => Difficulty.values.firstWhere((element) => element.name == e))
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAllCompleted = words.where((e) => !e.isCompleted).isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('關聯_臺灣版'),
        actions: [
          IconButton(
            onPressed: () {
              // confirm if reset
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('確定要重新開始嗎？'),
                    content: const Text('所有已選擇的字將會被清除。'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          resetCompletedAndSelected();
                          Navigator.of(context).pop();
                        },
                        child: const Text('確定'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800, minWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Title
                Text(
                  isAllCompleted ? '恭喜你找到所有關聯!' : '選擇四個有關連性的字按下提交',
                  style: const TextStyle(fontSize: 25),
                ),
                const SizedBox(height: 16),
                // Completed words
                if (words.where((e) => e.isCompleted).isNotEmpty)
                  Wrap(
                    runSpacing: 8,
                    children: [
                      for (var difficulty in difficulitiesSolved)
                        if (words
                            .where((e) =>
                                e.difficulty == difficulty && e.isCompleted)
                            .isNotEmpty)
                          Column(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) => Container(
                                  height: Constants.wordCardHeight,
                                  alignment: Alignment.center,
                                  width: (constraints.maxWidth / 4.5) * 4 +
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
                                                  e.difficulty == difficulty &&
                                                  e.isCompleted)
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
                  ),
                const SizedBox(height: 8),
                // Uncompleted words
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: Constants
                        .cardHorizontalSpacing, // Spacing between items
                    runSpacing: 8, // Spacing between lines
                    alignment:
                        WrapAlignment.center, // Center items horizontally
                    children: [
                      for (var word in words.where((e) => !e.isCompleted))
                        WordCard(
                          word: word.word,
                          isSelected: word.isSelected,
                          onTap: () => wordCardOnTap(word.word),
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Button group
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (isAllCompleted)
                      OutlinedButton(
                        onPressed: resetCompletedAndSelected,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('重新開始', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    if (!isAllCompleted)
                      OutlinedButton(
                        onPressed: deSelectAll,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('清除選擇', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    if (!isAllCompleted)
                      OutlinedButton(
                        onPressed: shuffleWords,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('洗牌', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    if (!isAllCompleted)
                      ElevatedButton(
                        onPressed: checkAnswers,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('提交', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
