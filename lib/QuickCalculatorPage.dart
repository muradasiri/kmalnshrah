import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'settings_provider.dart';

class QuickCalculatorPage extends StatefulWidget {
  @override
  _QuickCalculatorPageState createState() => _QuickCalculatorPageState();
}

class _QuickCalculatorPageState extends State<QuickCalculatorPage> {
  int teamUsScore = 0;
  int teamThemScore = 0;
  List<int> roundsUs = [];
  List<int> roundsThem = [];
  bool showInputFields = false;
  Stopwatch stopwatch = Stopwatch();
  String formattedTime = '00:00';
  final FlutterTts flutterTts = FlutterTts();

  TextEditingController usController = TextEditingController();
  TextEditingController themController = TextEditingController();
  FocusNode usFocusNode = FocusNode();
  FocusNode themFocusNode = FocusNode();

  double arrowAngle = 0.0;

  @override
  void dispose() {
    usController.dispose();
    themController.dispose();
    usFocusNode.dispose();
    themFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startStopwatch();
    _applySettings();
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
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
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

        if (settingsProvider.isResultSpeakingEnabled) {
          _speak('مجموع نقاط فريق لنا: $teamUsScore, مجموع نقاط فريق لهم: $teamThemScore');
        }

        _checkForWinner();
        _rotateArrow();
      }

      showInputFields = !showInputFields;
    });
  }

  void _rotateArrow() {
    setState(() {
      arrowAngle -= (90 * 3.14159 / 180);
    });
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
    if (settingsProvider.isResultSpeakingEnabled) {
      _speak('الفريق الفائز: $winner');
    }

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
                _resetScores();
              },
              child: Text('نشرة جديدة'),
            ),
          ],
        );
      },
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
      stopwatch.reset();
      formattedTime = '00:00';
      arrowAngle = 0.0;
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('حاسبة سريعة'),
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
          onPressed: _recordRoundScores,
          child: Text(showInputFields ? 'تسجيل' : 'تسجيل النقاط', style: TextStyle(fontSize: 18.0)),
          style: ElevatedButton.styleFrom(
            backgroundColor: settingsProvider.appColor,
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
}
