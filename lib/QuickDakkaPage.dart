import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'settings_provider.dart';

class QuickDakkaPage extends StatefulWidget {
  @override
  _QuickDakkaPageState createState() => _QuickDakkaPageState();
}

class _QuickDakkaPageState extends State<QuickDakkaPage> {
  List<String> players = [];
  List<String> selectedPlayers = [];
  FlutterTts flutterTts = FlutterTts();
  TextEditingController playerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _applySettings();
  }

  Future<void> _loadPlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      players = prefs.getStringList('quick_dakka_players') ?? [];
    });
  }

  Future<void> _savePlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('quick_dakka_players', players);
  }

  void _applySettings() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    if (settingsProvider.isVibrationEnabled) {
      Vibration.vibrate(duration: 100);
    }
    if (settingsProvider.keepScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void _drawTeams() {
    if (selectedPlayers.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء اختيار 4 لاعبين على الأقل')),
      );
      return;
    }

    selectedPlayers.shuffle(Random());
    List<String> team1 = selectedPlayers.sublist(0, 2);
    List<String> team2 = selectedPlayers.sublist(2, 4);

    _selectDealerFromTeams(team1, team2);
  }

  void _selectDealerFromTeams(List<String> team1, List<String> team2) {
    List<String> combinedTeams = team1 + team2;
    String dealer = combinedTeams[Random().nextInt(combinedTeams.length)];

    String message = 'الفريق الأول:\n${team1.join(', ')}\nالفريق الثاني:\n${team2.join(', ')}\nالموزع: $dealer';

    _speakResults(message);
    _showDialog(team1, team2, dealer);
  }

  Future<void> _speakResults(String message) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    if (settingsProvider.isResultSpeakingEnabled) {
      await flutterTts.speak(message);
    }
    if (settingsProvider.isVibrationEnabled) {
      Vibration.vibrate(duration: 500);
    }
  }

  void _showDialog(List<String> team1, List<String> team2, String dealer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('نتائج القرعة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الفريق الأول: ${team1.join(', ')}'),
              Text('الفريق الثاني: ${team2.join(', ')}'),
              Text('الموزع: $dealer'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('تم', style: TextStyle(color: Provider.of<SettingsProvider>(context).appColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addPlayer() {
    if (playerNameController.text.isNotEmpty) {
      setState(() {
        players.add(playerNameController.text);
        selectedPlayers.add(playerNameController.text); // Select the player automatically
        playerNameController.clear();
        _savePlayers();
      });
    }
  }

  void _editPlayer(String oldName, String newName) {
    setState(() {
      int index = players.indexOf(oldName);
      if (index != -1) {
        players[index] = newName;
        if (selectedPlayers.contains(oldName)) {
          selectedPlayers[selectedPlayers.indexOf(oldName)] = newName;
        }
        _savePlayers();
      }
    });
  }

  void _deletePlayer(String name) {
    setState(() {
      players.remove(name);
      selectedPlayers.remove(name);
      _savePlayers();
    });
  }

  void _clearPlayers() {
    setState(() {
      players.clear();
      selectedPlayers.clear();
      _savePlayers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('دقة الولد سريعة'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showConfirmationDialog(
                'تأكيد المسح',
                'هل أنت متأكد أنك تريد مسح جميع اللاعبين؟',
                _clearPlayers,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: playerNameController,
              decoration: InputDecoration(
                labelText: 'اسم اللاعب',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addPlayer,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(players[index]),
                    background: Container(color: Colors.blue, child: Icon(Icons.edit, color: Colors.white)),
                    secondaryBackground: Container(color: Colors.red, child: Icon(Icons.delete, color: Colors.white)),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        TextEditingController editController = TextEditingController(text: players[index]);
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('تعديل اسم اللاعب'),
                              content: TextField(
                                controller: editController,
                                decoration: InputDecoration(labelText: 'اسم اللاعب الجديد'),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('إلغاء'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: Text('تأكيد'),
                                  onPressed: () {
                                    _editPlayer(players[index], editController.text);
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else if (direction == DismissDirection.endToStart) {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('تأكيد الحذف'),
                              content: Text('هل أنت متأكد أنك تريد حذف هذا اللاعب؟'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('إلغاء'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: Text('تأكيد'),
                                  onPressed: () {
                                    _deletePlayer(players[index]);
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return false;
                    },
                    child: ListTile(
                      title: Text(players[index]),
                      trailing: Icon(
                        selectedPlayers.contains(players[index]) ? Icons.check_circle : Icons.circle_outlined,
                        color: selectedPlayers.contains(players[index]) ? Theme.of(context).primaryColor : null,
                      ),
                      onTap: () {
                        setState(() {
                          if (selectedPlayers.contains(players[index])) {
                            selectedPlayers.remove(players[index]);
                          } else {
                            selectedPlayers.add(players[index]);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _drawTeams,
                    child: Text('دق الولد بين اللاعبين', style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(settingsProvider.appColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('تأكيد'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
