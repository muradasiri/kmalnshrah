import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'models.dart';

class SelectPlayersPage extends StatefulWidget {
  final String localUserId;

  SelectPlayersPage({required this.localUserId});

  @override
  _SelectPlayersPageState createState() => _SelectPlayersPageState();
}

class _SelectPlayersPageState extends State<SelectPlayersPage> {
  List<Diwaniya> diwaniyat = [];
  Map<String, List<Player>> playersByDiwaniya = {};
  List<Player> selectedPlayers = [];

  @override
  void initState() {
    super.initState();
    _loadDiwaniyatAndPlayers();
  }

  Future<void> _loadDiwaniyatAndPlayers() async {
    final diwaniyatStream = DatabaseService().getDiwaniyatForUser(widget.localUserId);
    diwaniyatStream.listen((diwaniyatList) {
      setState(() {
        diwaniyat = diwaniyatList;
      });
      for (var diwaniya in diwaniyatList) {
        DatabaseService().getPlayersStream(diwaniya.id).listen((playersList) {
          setState(() {
            playersByDiwaniya[diwaniya.id] = playersList;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختيار اللاعبين'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, selectedPlayers);
            },
            child: Text('تم', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: diwaniyat.length,
        itemBuilder: (context, index) {
          final diwaniya = diwaniyat[index];
          final players = playersByDiwaniya[diwaniya.id] ?? [];
          return ExpansionTile(
            title: Text(diwaniya.name),
            children: players.map((player) {
              return CheckboxListTile(
                title: Text(player.name),
                value: selectedPlayers.contains(player),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      selectedPlayers.add(player);
                    } else {
                      selectedPlayers.remove(player);
                    }
                  });
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
