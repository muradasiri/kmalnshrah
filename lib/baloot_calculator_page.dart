import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'diwaniya/database.dart';
import 'diwaniya/models.dart';
import 'settings_provider.dart';
import 'notification_service.dart';

class BalootCalculatorPage extends StatefulWidget {
  final String localUserId;
  final String diwaniyaId;

  BalootCalculatorPage({required this.localUserId, required this.diwaniyaId});

  @override
  _BalootCalculatorPageState createState() => _BalootCalculatorPageState();
}

class _BalootCalculatorPageState extends State<BalootCalculatorPage> {
  int teamUsScore = 0;
  int teamThemScore = 0;
  List<int> roundsUs = [];
  List<int> roundsThem = [];
  bool showInputFields = false;
  Stopwatch stopwatch = Stopwatch();
  String formattedTime = '00:00';

  TextEditingController usController = TextEditingController();
  TextEditingController themController = TextEditingController();
  FocusNode usFocusNode = FocusNode();
  FocusNode themFocusNode = FocusNode();

  double arrowAngle = 0.0;
  final FlutterTts _flutterTts = FlutterTts();

  List<Player> players = [];
  Player? selectedPlayerUs1;
  Player? selectedPlayerUs2;
  Player? selectedPlayerThem1;
  Player? selectedPlayerThem2;

  @override
  void dispose() {
    _flutterTts.stop();
    usController.dispose();
    themController.dispose();
    usFocusNode.dispose();
    themFocusNode.dispose();
    _savePlayerData(); // Save player data when disposing
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _startStopwatch();
    _loadPlayers();
    _applySettings();
  }

  Future<void> _loadPlayers() async {
    List<Player> diwaniyaPlayers = await DatabaseService().getPlayersOnce(widget.diwaniyaId);
    setState(() {
      players = diwaniyaPlayers;
    });
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      teamUsScore = prefs.getInt('teamUsScore_${widget.diwaniyaId}') ?? 0;
      teamThemScore = prefs.getInt('teamThemScore_${widget.diwaniyaId}') ?? 0;
      roundsUs = (prefs.getStringList('roundsUs_${widget.diwaniyaId}') ?? []).map((e) => int.parse(e)).toList();
      roundsThem = (prefs.getStringList('roundsThem_${widget.diwaniyaId}') ?? []).map((e) => int.parse(e)).toList();
      arrowAngle = prefs.getDouble('arrowAngle_${widget.diwaniyaId}') ?? 0.0;
      selectedPlayerUs1 = _getPlayerFromPrefs(prefs, 'selectedPlayerUs1_${widget.diwaniyaId}');
      selectedPlayerUs2 = _getPlayerFromPrefs(prefs, 'selectedPlayerUs2_${widget.diwaniyaId}');
      selectedPlayerThem1 = _getPlayerFromPrefs(prefs, 'selectedPlayerThem1_${widget.diwaniyaId}');
      selectedPlayerThem2 = _getPlayerFromPrefs(prefs, 'selectedPlayerThem2_${widget.diwaniyaId}');
      bool keepScreenOn = prefs.getBool('keepScreenOn') ?? false;
      WakelockPlus.toggle(enable: keepScreenOn);
    });
    print('Loaded saved data: $selectedPlayerUs1, $selectedPlayerUs2, $selectedPlayerThem1, $selectedPlayerThem2');
  }

  Future<void> _applySettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool keepScreenOn = prefs.getBool('keepScreenOn') ?? false;
    WakelockPlus.toggle(enable: keepScreenOn);

    bool vibrateEnabled = prefs.getBool('vibrateEnabled') ?? false;
    if (vibrateEnabled) {
      Vibration.vibrate();
    }
  }

  Player? _getPlayerFromPrefs(SharedPreferences prefs, String key) {
    String? playerData = prefs.getString(key);
    if (playerData != null) {
      Map<String, dynamic> playerMap = Map<String, dynamic>.from(jsonDecode(playerData));
      return Player.fromMap(playerMap, playerMap['id']);
    }
    return null;
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('teamUsScore_${widget.diwaniyaId}', teamUsScore);
    await prefs.setInt('teamThemScore_${widget.diwaniyaId}', teamThemScore);
    await prefs.setStringList('roundsUs_${widget.diwaniyaId}', roundsUs.map((e) => e.toString()).toList());
    await prefs.setStringList('roundsThem_${widget.diwaniyaId}', roundsThem.map((e) => e.toString()).toList());
    await prefs.setDouble('arrowAngle_${widget.diwaniyaId}', arrowAngle);
    await _savePlayerToPrefs(prefs, 'selectedPlayerUs1_${widget.diwaniyaId}', selectedPlayerUs1);
    await _savePlayerToPrefs(prefs, 'selectedPlayerUs2_${widget.diwaniyaId}', selectedPlayerUs2);
    await _savePlayerToPrefs(prefs, 'selectedPlayerThem1_${widget.diwaniyaId}', selectedPlayerThem1);
    await _savePlayerToPrefs(prefs, 'selectedPlayerThem2_${widget.diwaniyaId}', selectedPlayerThem2);
    print('Saved data: $selectedPlayerUs1, $selectedPlayerUs2, $selectedPlayerThem1, $selectedPlayerThem2');
  }

  Future<void> _savePlayerToPrefs(SharedPreferences prefs, String key, Player? player) async {
    if (player != null) {
      String playerData = jsonEncode(player.toMap());
      await prefs.setString(key, playerData);
    } else {
      await prefs.remove(key);
    }
  }

  Future<void> _savePlayerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _savePlayerToPrefs(prefs, 'selectedPlayerUs1_${widget.diwaniyaId}', selectedPlayerUs1);
    await _savePlayerToPrefs(prefs, 'selectedPlayerUs2_${widget.diwaniyaId}', selectedPlayerUs2);
    await _savePlayerToPrefs(prefs, 'selectedPlayerThem1_${widget.diwaniyaId}', selectedPlayerThem1);
    await _savePlayerToPrefs(prefs, 'selectedPlayerThem2_${widget.diwaniyaId}', selectedPlayerThem2);
    print('Saved player data: $selectedPlayerUs1, $selectedPlayerUs2, $selectedPlayerThem1, $selectedPlayerThem2');
  }

  void _startStopwatch() {
    stopwatch.start();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && stopwatch.isRunning) {
        setState(() {
          formattedTime = _formatTime(stopwatch.elapsedMilliseconds);
        });
      }
    });
  }

  String _formatTime(int milliseconds) {
    int seconds = milliseconds ~/ 1000;
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _recordRoundScores() {
    if (_selectedPlayersCount() < 4) {
      _showErrorDialog('يجب اختيار 4 لاعبين لتسجيل النقاط.');
      return;
    }

    setState(() {
      if (showInputFields) {
        int usScore = int.tryParse(usController.text) ?? 0;
        int themScore = int.tryParse(themController.text) ?? 0;

        if (usScore == 0 && themScore == 0) {
          _showErrorDialog('يجب إدخال نقاط لأحد الفرق على الأقل.');
          return;
        }

        teamUsScore += usScore;
        teamThemScore += themScore;

        roundsUs.add(usScore);
        roundsThem.add(themScore);

        usController.clear();
        themController.clear();

        _checkForWinner();
        _saveData();
        _rotateArrow();
        _speakScores();
      }

      showInputFields = !showInputFields;
    });
  }

  void _speakScores() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    String message = 'مجموع نقاط لنا: $teamUsScore\nمجموع نقاط لهم: $teamThemScore';

    if (settingsProvider.isResultSpeakingEnabled) {
      _speak(message);
    }
  }

  void _rotateArrow() {
    setState(() {
      arrowAngle -= (90 * 3.14159 / 180);
    });
    _saveData();
  }

  void _undoLastRound() {
    _showConfirmationDialog(
      'تأكيد التراجع',
      'هل أنت متأكد أنك تريد التراجع عن الجولة الأخيرة؟',
          () {
        setState(() {
          if (roundsUs.isNotEmpty && roundsThem.isNotEmpty) {
            teamUsScore -= roundsUs.removeLast();
            teamThemScore -= roundsThem.removeLast();
            _saveData();
          }
        });
      },
    );
  }

  void _checkForWinner() {
    if (teamUsScore >= 152 || teamThemScore >= 152) {
      String winner = (teamUsScore > teamThemScore) ? 'لنا' : (teamThemScore > teamUsScore) ? 'لهم' : 'تعادل';
      _showResultDialog(winner);
    }
  }

  void _showResultDialog(String winner) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('نتيجة الصكة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('الفريق الفائز: $winner'),
              Text('مجموع نقاط فريق لنا: $teamUsScore'),
              Text('مجموع نقاط فريق لهم: $teamThemScore'),
              Text('الوقت المستغرق: $formattedTime'),
              Text('فريق لنا: ${selectedPlayerUs1?.name ?? ''} و ${selectedPlayerUs2?.name ?? ''}'),
              Text('فريق لهم: ${selectedPlayerThem1?.name ?? ''} و ${selectedPlayerThem2?.name ?? ''}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _undoLastRound();
              },
              child: Text('تراجع عن آخر جولة'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveAndStartNewRound(winner);
              },
              child: Text('حفظ وبدء صكة جديدة'),
            ),
          ],
        );
      },
    );
  }

  void _saveAndStartNewRound(String winner) async {
    try {
      _showSavingDialog();
      await _saveToArchive(winner, teamUsScore, teamThemScore, formattedTime);
      _sendNotification(winner); // إرسال الإشعار بعد الحفظ
      _resetScores();
    } catch (e) {
      print('Error saving and starting new round: $e');
      Navigator.of(context).pop(); // Close saving dialog
      _showErrorDialog('حدث خطأ أثناء حفظ النتائج. حاول مرة أخرى.');
    }
  }

  Future<void> _saveToArchive(String winner, int usScore, int themScore, String time) async {
    try {
      if (widget.diwaniyaId.isEmpty) {
        throw Exception('Diwaniya ID is empty');
      }

      await DatabaseService().addToScoreArchive(
        widget.diwaniyaId,
        winner,
        usScore,
        themScore,
        time,
        selectedPlayerUs1?.name ?? '',
        selectedPlayerUs2?.name ?? '',
        selectedPlayerThem1?.name ?? '',
        selectedPlayerThem2?.name ?? '',
        DateTime.now(),
      );

      if (winner == 'لنا') {
        await DatabaseService().updatePlayerRecord(widget.diwaniyaId, selectedPlayerUs1?.id ?? '', true);
        await DatabaseService().updatePlayerRecord(widget.diwaniyaId, selectedPlayerUs2?.id ?? '', true);
        await DatabaseService().updatePlayerRecord(widget.diwaniyaId, selectedPlayerThem1?.id ?? '', false);
        await DatabaseService().updatePlayerRecord(widget.diwaniyaId, selectedPlayerThem2?.id ?? '', false);
      } else if (winner == 'لهم') {
        await DatabaseService().updatePlayerRecord(widget.diwaniyaId, selectedPlayerUs1?.id ?? '', false);
        await DatabaseService().updatePlayerRecord(widget.diwaniyaId, selectedPlayerUs2?.id ?? '', false);
        await DatabaseService().updatePlayerRecord(widget.diwaniyaId, selectedPlayerThem1?.id ?? '', true);
        await DatabaseService().updatePlayerRecord(widget.diwaniyaId, selectedPlayerThem2?.id ?? '', true);
      }

      await DatabaseService().sendNotificationToDiwaniyaMembers(
        widget.diwaniyaId,
        'نتيجة الصكة',
        'الفريق ${winner == 'لنا' ? 'الأول' : 'الثاني'} فاز بنتيجة $usScore - $themScore',
      );

      Navigator.of(context).pop(); // Close saving dialog
    } catch (e) {
      print('Error saving to archive: $e');
      throw e;
    }
  }

  Future<void> _speak(String message) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    await _flutterTts.setLanguage("ar");
    await _flutterTts.setPitch(settingsProvider.isVoiceMale ? 1.0 : 1.5);
    if (settingsProvider.isResultSpeakingEnabled) {
      await _flutterTts.speak(message);
    }
  }

  void _sendNotification(String winner) {
    String usPlayers = '${selectedPlayerUs1?.name ?? ''} و ${selectedPlayerUs2?.name ?? ''}';
    String themPlayers = '${selectedPlayerThem1?.name ?? ''} و ${selectedPlayerThem2?.name ?? ''}';
    String notificationBody = 'الفريق الفائز: ${winner == 'لنا' ? usPlayers : themPlayers} بنتيجة $teamUsScore - $teamThemScore';

    NotificationService.showNotification(
      'نتيجة الصكة',
      notificationBody,
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('خطأ'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  void _showSavingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('جاري الحفظ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 16.0),
              Text('جارٍ حفظ النتيجة وإرسالها إلى الديوانية...'),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(String title, String content, VoidCallback onConfirm) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (settingsProvider.isVibrationEnabled) Vibration.vibrate(duration: 50);
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (settingsProvider.isVibrationEnabled) Vibration.vibrate(duration: 50);
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  void _resetScores() {
    setState(() {
      teamUsScore = 0;
      teamThemScore = 0;
      roundsUs.clear();
      roundsThem.clear();
      selectedPlayerUs1 = null;
      selectedPlayerUs2 = null;
      selectedPlayerThem1 = null;
      selectedPlayerThem2 = null;
      stopwatch.reset();
      formattedTime = '00:00';
      arrowAngle = 0.0;
      _saveData();
    });
  }

  void _selectPlayerUs1(Player player) {
    setState(() {
      selectedPlayerUs1 = player;
    });
    _savePlayerData();
  }

  void _selectPlayerUs2(Player player) {
    setState(() {
      selectedPlayerUs2 = player;
    });
    _savePlayerData();
  }

  void _selectPlayerThem1(Player player) {
    setState(() {
      selectedPlayerThem1 = player;
    });
    _savePlayerData();
  }

  void _selectPlayerThem2(Player player) {
    setState(() {
      selectedPlayerThem2 = player;
    });
    _savePlayerData();
  }

  void _showPlayerSelectionDialog() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('اختيار اللاعبين', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (BuildContext context, int index) {
                        bool isSelectedUs1 = players[index] == selectedPlayerUs1;
                        bool isSelectedUs2 = players[index] == selectedPlayerUs2;
                        bool isSelectedThem1 = players[index] == selectedPlayerThem1;
                        bool isSelectedThem2 = players[index] == selectedPlayerThem2;

                        return ListTile(
                          leading: _buildPlayerImage(players[index], settingsProvider),
                          title: Text(players[index].name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelectedUs1 || isSelectedUs2 || isSelectedThem1 || isSelectedThem2)
                                Text(
                                  isSelectedUs1 || isSelectedUs2 ? 'فريق لنا' : 'فريق لهم',
                                  style: TextStyle(color: isSelectedUs1 || isSelectedUs2 ? Colors.blue : Colors.red),
                                ),
                              Checkbox(
                                value: isSelectedUs1 || isSelectedUs2 || isSelectedThem1 || isSelectedThem2,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      if (!isSelectedUs1 && !isSelectedUs2 && !isSelectedThem1 && !isSelectedThem2) {
                                        if (selectedPlayerUs1 == null) {
                                          selectedPlayerUs1 = players[index];
                                        } else if (selectedPlayerUs2 == null) {
                                          selectedPlayerUs2 = players[index];
                                        } else if (selectedPlayerThem1 == null) {
                                          selectedPlayerThem1 = players[index];
                                        } else if (selectedPlayerThem2 == null) {
                                          selectedPlayerThem2 = players[index];
                                        }
                                      }
                                    } else {
                                      if (isSelectedUs1) {
                                        selectedPlayerUs1 = null;
                                      } else if (isSelectedUs2) {
                                        selectedPlayerUs2 = null;
                                      } else if (isSelectedThem1) {
                                        selectedPlayerThem1 = null;
                                      } else if (isSelectedThem2) {
                                        selectedPlayerThem2 = null;
                                      }
                                    }
                                  });

                                  if (settingsProvider.isVibrationEnabled) {
                                    Vibration.vibrate(duration: 50);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedPlayerUs1 == null) {
                                selectedPlayerUs1 = players[index];
                              } else if (selectedPlayerUs2 == null) {
                                selectedPlayerUs2 = players[index];
                              } else if (selectedPlayerThem1 == null) {
                                selectedPlayerThem1 = players[index];
                              } else if (selectedPlayerThem2 == null) {
                                selectedPlayerThem2 = players[index];
                              } else {
                                if (selectedPlayerUs1 == players[index]) {
                                  selectedPlayerUs1 = null;
                                } else if (selectedPlayerUs2 == players[index]) {
                                  selectedPlayerUs2 = null;
                                } else if (selectedPlayerThem1 == players[index]) {
                                  selectedPlayerThem1 = null;
                                } else if (selectedPlayerThem2 == players[index]) {
                                  selectedPlayerThem2 = null;
                                }
                              }

                              if (settingsProvider.isVibrationEnabled) {
                                Vibration.vibrate(duration: 50);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (settingsProvider.isVibrationEnabled) Vibration.vibrate(duration: 50);
                      _savePlayerData(); // Save selected players
                      Navigator.of(context).pop();
                    },
                    child: Text('تأكيد'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showResetConfirmationDialog() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد بدء نشرة جديدة'),
          content: Text('هل أنت متأكد أنك تريد بدء نشرة جديدة؟ سيتم مسح جميع البيانات الحالية ولن يتم حفظها.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (settingsProvider.isVibrationEnabled) Vibration.vibrate(duration: 50);
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (settingsProvider.isVibrationEnabled) Vibration.vibrate(duration: 50);
                Navigator.of(context).pop();
                _resetScores();
              },
              child: Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  int _selectedPlayersCount() {
    return [
      selectedPlayerUs1,
      selectedPlayerUs2,
      selectedPlayerThem1,
      selectedPlayerThem2
    ].where((player) => player != null).length;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('حاسبة بلوت'),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: () {
              if (settingsProvider.isVibrationEnabled) Vibration.vibrate(duration: 50);
              _undoLastRound();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (settingsProvider.isVibrationEnabled) Vibration.vibrate(duration: 50);
              _showResetConfirmationDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlayerSelection(selectedPlayerUs1, _selectPlayerUs1),
                _buildPlayerSelection(selectedPlayerUs2, _selectPlayerUs2),
                GestureDetector(
                  onTap: () {
                    if (settingsProvider.isVibrationEnabled) Vibration.vibrate(duration: 50);
                    _rotateArrow();
                  },
                  child: Transform.rotate(
                    angle: arrowAngle,
                    child: Icon(Icons.arrow_upward, size: 50, color: settingsProvider.appColor),
                  ),
                ),
                _buildPlayerSelection(selectedPlayerThem1, _selectPlayerThem1),
                _buildPlayerSelection(selectedPlayerThem2, _selectPlayerThem2),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildScoreColumn('لنا', teamUsScore, roundsUs, settingsProvider.appColor),
                  VerticalDivider(
                    color: Theme.of(context).primaryColor,
                    width: 20,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  _buildScoreColumn('لهم', teamThemScore, roundsThem, settingsProvider.appColor),
                ],
              ),
            ),
            if (showInputFields)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildScoreInputField(usController, 'لنا', usFocusNode, themFocusNode),
                  _buildScoreInputField(themController, 'لهم', themFocusNode, null),
                ],
              ),
            SizedBox(height: 16.0),
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreColumn(String title, int score, List<int> rounds, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 24.0, color: color),
          ),
          SizedBox(height: 8.0),
          Text(
            '$score',
            style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: rounds.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Divider(color: color),
                    Text(
                      ' جولة ${index + 1}',
                      style: TextStyle(fontSize: 18.0, color: color, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'النقاط: ${rounds[index]}',
                      style: TextStyle(fontSize: 16.0, color: color),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInputField(TextEditingController controller, String label, FocusNode currentFocus, FocusNode? nextFocus) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          focusNode: currentFocus,
          onSubmitted: (value) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: label,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          onPressed: _selectedPlayersCount() == 4 ? _recordRoundScores : _showPlayerSelectionDialog,
          child: Text(showInputFields ? 'تسجيل' : (_selectedPlayersCount() == 4 ? 'تسجيل النقاط' : 'اختيار لاعبين'), style: TextStyle(fontSize: 18.0)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedPlayersCount() == 4 ? Provider.of<SettingsProvider>(context).appColor : Colors.grey,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          ),
        ),
        if (showInputFields)
          ElevatedButton(
            onPressed: () {
              if (settingsProvider.isVibrationEnabled) Vibration.vibrate(duration: 50);
              setState(() {
                showInputFields = false;
              });
            },
            child: Text('إلغاء', style: TextStyle(fontSize: 18.0)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFA94748),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerSelection(Player? selectedPlayer, Function(Player) onSelect) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return GestureDetector(
      onTap: () {
        if (settingsProvider.isVibrationEnabled) Vibration.vibrate(duration: 50);
        _showPlayerSelectionDialog();
      },
      child: Container(
        height: 50.0,
        width: 50.0,
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedPlayer == null ? Colors.grey : Colors.transparent,
          border: Border.all(
            color: selectedPlayer != null ? settingsProvider.appColor : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: selectedPlayer != null
            ? selectedPlayer.imageUrl != null
            ? ClipOval(
          child: Image.network(
            selectedPlayer.imageUrl!,
            fit: BoxFit.cover,
          ),
        )
            : Center(
          child: Text(
            selectedPlayer.name,
            style: TextStyle(
              color: settingsProvider.appColor,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        )
            : Image.asset(
          'assets/default_avatar.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPlayerImage(Player player, SettingsProvider settingsProvider) {
    return player.imageUrl != null
        ? ClipOval(
      child: Image.network(
        player.imageUrl!,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
      ),
    )
        : ClipOval(
      child: Container(
        width: 50,
        height: 50,
        color: settingsProvider.appColor,
        child: Center(
          child: Text(
            player.name,
            style: TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<Player?> _selectPlayerDialog() async {
    return showDialog<Player>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('اختيار لاعب'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: players.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: _buildPlayerImage(players[index], Provider.of<SettingsProvider>(context)),
                  title: Text(players[index].name),
                  onTap: () {
                    Navigator.of(context).pop(players[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  bool _isPlayerSelected(Player player) {
    return player == selectedPlayerUs1 ||
        player == selectedPlayerUs2 ||
        player == selectedPlayerThem1 ||
        player == selectedPlayerThem2;
  }
}
