import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'settings_provider.dart';
import 'diwaniya/models.dart';
import 'diwaniya/database.dart';

class DakkaAlWaldPage extends StatefulWidget {
  final String localUserId;
  final String diwaniyaId;

  DakkaAlWaldPage({required this.localUserId, required this.diwaniyaId});

  @override
  _DakkaAlWaldPageState createState() => _DakkaAlWaldPageState();
}

class _DakkaAlWaldPageState extends State<DakkaAlWaldPage> with AutomaticKeepAliveClientMixin<DakkaAlWaldPage> {
  @override
  bool get wantKeepAlive => true;

  List<Player> players = [];
  List<Player> selectedPlayers = [];
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadPlayers(widget.diwaniyaId);
    _applySettings();
  }

  Future<void> _loadPlayers(String diwaniyaId) async {
    List<Player> diwaniyaPlayers = await DatabaseService().getPlayersOnce(diwaniyaId);
    setState(() {
      players = diwaniyaPlayers;
    });
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
    List<Player> team1 = selectedPlayers.sublist(0, 2);
    List<Player> team2 = selectedPlayers.sublist(2, 4);

    _selectDealerFromTeams(team1, team2);
  }

  void _selectDealerFromTeams(List<Player> team1, List<Player> team2) {
    List<Player> combinedTeams = team1 + team2;
    Player dealer = combinedTeams[Random().nextInt(combinedTeams.length)];

    String message = 'الفريق الأول:\n${team1.map((p) => p.name).join(', ')}\nالفريق الثاني:\n${team2.map((p) => p.name).join(', ')}\nالموزع: ${dealer.name}';

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

  void _showDialog(List<Player> team1, List<Player> team2, Player dealer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('نتائج القرعة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: team1.map((player) => _buildPlayerAvatar(player)).toList(),
                  ),
                  Text(
                    'VS',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: team2.map((player) => _buildPlayerAvatar(player)).toList(),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Text(
                'الموزع: ${dealer.name}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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

  Widget _buildPlayerAvatar(Player player) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey,
        backgroundImage: player.imageUrl != null ? NetworkImage(player.imageUrl!) : null,
        child: player.imageUrl == null
            ? Text(
          player.name.substring(0, 1),
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        )
            : null,
      ),
    );
  }

  Widget _buildPlayerItem(Player player) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedPlayers.contains(player)) {
            selectedPlayers.remove(player);
          } else {
            selectedPlayers.add(player);
          }
        });
      },
      child: Card(
        elevation: 5.0,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            child: player.imageUrl != null
                ? CircleAvatar(
              backgroundImage: NetworkImage(player.imageUrl!),
              radius: 20,
            )
                : Center(
              child: Text(
                player.name.substring(0, 1),
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ),
          title: Text(player.name),
          subtitle: Text(selectedPlayers.contains(player) ? 'محدد' : ''),
          trailing: Icon(
            selectedPlayers.contains(player) ? Icons.check_circle : Icons.circle_outlined,
            color: selectedPlayers.contains(player) ? Theme.of(context).primaryColor : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('دقة الولد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'اختر اللاعبين من الديوانية:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: settingsProvider.appColor),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return _buildPlayerItem(players[index]);
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
}
