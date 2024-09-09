import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:confetti/confetti.dart';
import 'package:connections_taiwan/constants.dart';
import 'package:connections_taiwan/google_signin_button.dart';
import 'package:connections_taiwan/word_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about_content.dart';
import 'action_button.dart';
import 'completed_words.dart';
import 'leaderboard_icon_button.dart';
import 'privacy_screen.dart';
import 'snackbar_utils.dart';
import 'username_input_dialog.dart';
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
  List<DateTime> availableDates = [];
  DateTime? selectedDate;
  DateTime? customLevelDate;
  final confettiController =
      ConfettiController(duration: const Duration(seconds: 30));

  @override
  void initState() {
    super.initState();

    // reading from url params
    Future.delayed(Duration.zero, () {
      print(
          'Url [GameScreen]: base: ${Uri.base} param: ${Uri.base.queryParameters}');
      final customLevel = Uri.base.queryParameters['customLevel'];
      print('customLevel: $customLevel');
      // full url: http://localhost:49764/?page=privacy&customLevel=2024-09-02
      customLevelDate = DateTime.tryParse(customLevel ?? '');
      bool isPrivacyInParam = Uri.base.toString().contains('privacy');
      if (isPrivacyInParam) {
        setState(() {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PrivacyScreen()));
        });
      }
      bool isAboutInParam = Uri.base.toString().contains('about');
      if (isAboutInParam) {
        openAboutDialog();
      }

      if (customLevelDate != null) {
        setState(() {
          selectedDate = customLevelDate;
        });

        return saveSelectedDateToSharedPreferences();
      }
      // clear url param with universal html
      html.window.history.pushState({}, '', '/');
      
      // return future void
      return Future.value(null);
    })
        .then((_) => getAllFileDates())
        .then((_) => SharedPreferences.getInstance())
        .then((prefs) {
      // load available dates
      // set selected date
      final String? selectedDateJson = prefs.getString('selectedDate');
      // priority: customLevelDate > cached date > last date in availableDates
      selectedDate = // if there is today's date, select it, otherwise select the last date
          // check year, month, day
          customLevelDate ??
              DateTime.tryParse(selectedDateJson ?? '') ??
              (availableDates.contains(DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day))
                  ? DateTime.now()
                  : availableDates.last);
      // load data from json file based on selected date
      return WordModel.loadData(selectedDate);
    }).then((value) {
      if (value != null) {
        setState(() {
          words = value.$1;
          words.shuffle();
          difficultyDescriptionMap = value.$2;
        });
      }
      // if there is a forced level in url then dont load from cache
      if (customLevelDate == null) {
        // (override file data above) load words and difficulties solved from cahced data
        loadWordsFromSharedPreferences();
      }
    });
  }

  Future<void> getAllFileDates() async {
    var value = await rootBundle.loadString('AssetManifest.json');
    final List<String> fileNames = (jsonDecode(value) as Map<String, dynamic>)
        .keys
        .where((fileName) => fileName.startsWith('assets/json/data_'))
        .map((e) => e.split('_').last.split('.').first)
        .toList();
    print('fileNames: $fileNames');
    setState(() {
      availableDates = fileNames.map((e) => DateTime.parse(e)).toList();
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
      showSnackBar(context, '正確！', isError: false);
    }
    bool isAllCompleted = words.where((e) => !e.isCompleted).isEmpty;
    if (isAllCompleted) {
      showSnackBar(context, '恭喜！您找到所有關聯組合！', isError: false);
      // confetti
      confettiController.play();
      openLeaderboardOptInDialog();
    }
  }

  void openLeaderboardOptInDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return UsernameInputDialog(
          selectedDate: selectedDate,
        );
      },
    );
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
    confettiController.stop();
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
      // save difficultyMap to Shared Preferences
      Map<String, String> encodedDifficultyDescriptionMap = {
        for (var entry in difficultyDescriptionMap.entries)
          entry.key.name: entry.value
      };
      prefs.setString(
        'difficultyDescriptionMap',
        json.encode(encodedDifficultyDescriptionMap),
      );
      // save difficulitiesSolved to Shared Preferences
      prefs.setStringList(
        'difficulitiesSolved',
        difficulitiesSolved.map((e) => e.name).toList(),
      );
    });
  }

  Future<void> saveSelectedDateToSharedPreferences() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedDate', selectedDate.toString());
  }

  void loadWordsFromSharedPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      final List<String>? wordsJson = prefs.getStringList('words');
      if (wordsJson != null) {
        setState(() {
          words =
              wordsJson.map((e) => WordModel.fromJson(json.decode(e))).toList();
        });
      }
      final String? difficultyDescriptionMapJson =
          prefs.getString('difficultyDescriptionMap');
      if (difficultyDescriptionMapJson != null) {
        setState(() {
          difficultyDescriptionMap = (json.decode(difficultyDescriptionMapJson)
                  as Map<String, dynamic>)
              .map((key, value) => MapEntry(
                  Difficulty.values
                      .firstWhere((element) => element.name == key),
                  value));
        });
      }
      final List<String>? difficulitiesSolvedJson =
          prefs.getStringList('difficulitiesSolved');
      if (difficulitiesSolvedJson != null) {
        setState(() {
          difficulitiesSolved = difficulitiesSolvedJson
              .map((e) =>
                  Difficulty.values.firstWhere((element) => element.name == e))
              .toList();
        });
      }
    });
  }

  void changeSelectedDate(DateTime date) async {
    confettiController.stop();
    setState(() {
      selectedDate = date;
    });
    await saveSelectedDateToSharedPreferences();
    WordModel.loadData(date).then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        words = value.$1;
        words.shuffle();
        difficultyDescriptionMap = value.$2;
        difficulitiesSolved = [];
      });
      saveWordsToSharedPreferences();
    });
  }

  void openAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('關於關連－臺灣版'),
          content: const AboutContent(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('關閉'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAllCompleted = words.where((e) => !e.isCompleted).isEmpty;
    return Scaffold(
      appBar: AppBar(
        leading: // logo
            InkWell(
          onTap: () => openAboutDialog(),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/icon/connections.webp'),
              ),
            ],
          ),
        ),
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('關聯臺灣版'),
            const SizedBox(
              width: 8,
            ),
            // a date picker to select date
            OutlinedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
              ),
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: availableDates.first,
                  lastDate: availableDates.last,
                  // show only available dates
                  selectableDayPredicate: (DateTime date) {
                    return availableDates.contains(date);
                  },
                  // show 選擇日期 button
                  cancelText: '取消',
                  confirmText: '選擇日期',
                  // change 'SELECT DATE' to '選擇日期'
                  helpText: '選擇日期',
                ).then((value) {
                  print('value: $value');
                  if (value == null || !context.mounted) {
                    return;
                  }
                  String yyyyMMdd = '${value.year}/${value.month}/${value.day}';
                  // confirm to change date
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('確認'),
                          content: Text('確定要切換到日期 $yyyyMMdd 嗎？您目前的進度將會被清除。'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                changeSelectedDate(value);
                              },
                              child: const Text('確定'),
                            ),
                          ],
                        );
                      });
                });
              },
              child: Text(
                selectedDate == null
                    ? '選擇日期'
                    : '${selectedDate!.year}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ),
        actions: [
          // leaderboard icon button
          LeaderboardIconButton(selectedDate: selectedDate),
        ],
      ),
      body: words.isEmpty
          ? const Center(child: Text('還沒有資料，請稍後再試。'))
          : Stack(
              children: [
                InteractiveViewer(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Center(
                      child: Column(
                        children: [
                          //const GoogleSigninButton(),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 800),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 16),
                                    // Title
                                    Text(
                                      isAllCompleted
                                          ? '恭喜您找到所有關聯！'
                                          : '選擇四個有關連性的字按下提交',
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                    const SizedBox(height: 16),
                                    // Completed words
                                    if (words
                                        .where((e) => e.isCompleted)
                                        .isNotEmpty)
                                      CompletedWords(
                                          difficulitiesSolved:
                                              difficulitiesSolved,
                                          words: words,
                                          difficultyDescriptionMap:
                                              difficultyDescriptionMap),
                                    const SizedBox(height: 8),
                                    // Uncompleted words
                                    SizedBox(
                                      width: double.infinity,
                                      child: Wrap(
                                        spacing: Constants
                                            .cardHorizontalSpacing, // Spacing between items
                                        runSpacing: 8, // Spacing between lines
                                        alignment: WrapAlignment
                                            .center, // Center items horizontally
                                        children: [
                                          for (var word in words
                                              .where((e) => !e.isCompleted))
                                            WordCard(
                                              word: word.word,
                                              isSelected: word.isSelected,
                                              onTap: () =>
                                                  wordCardOnTap(word.word),
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
                                          ActionButton(
                                            text: '重新開始',
                                            onPressed:
                                                resetCompletedAndSelected,
                                            isPrimary: false,
                                          ),

                                        if (!isAllCompleted)
                                          ActionButton(
                                            text: '清除選擇',
                                            onPressed: deSelectAll,
                                            isPrimary: false,
                                          ),

                                        if (!isAllCompleted)
                                          ActionButton(
                                            text: '洗牌',
                                            onPressed: shuffleWords,
                                            isPrimary: false,
                                          ),

                                        if (!isAllCompleted)
                                          ActionButton(
                                            text: '提交',
                                            onPressed: checkAnswers,
                                          ),

                                        if (isAllCompleted)
                                          ActionButton(
                                            foreColor: Colors.black,
                                            backColor: Colors.amber,
                                            text: '參加排行榜',
                                            onPressed:
                                                openLeaderboardOptInDialog,
                                          ),
                                        //const GoogleSigninButton()
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 32,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                Center(
                  child: ConfettiWidget(
                    confettiController: confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    numberOfParticles: 20,
                    gravity: 0.1,
                    emissionFrequency: 0.05,
                    maxBlastForce: 20,
                    minBlastForce: 8,
                    colors: const [Colors.blue, Colors.red, Colors.yellow],
                  ),
                ),
              ],
            ),
    );
  }
}
