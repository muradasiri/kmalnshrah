import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'models.dart';

class PlayerRankingPage extends StatelessWidget {
  final String localUserId;

  PlayerRankingPage({required this.localUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Rankings'),
      ),
      body: FutureBuilder<List<Player>>(
        future: _getPlayersRanked(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No players available.'));
          }

          List<Player> players = snapshot.data!;
          players.sort((a, b) => b.wins.compareTo(a.wins));

          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              Player player = players[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: player.imageUrl != null ? NetworkImage(player.imageUrl!) : AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                title: Text(player.name),
                subtitle: Text('Wins: ${player.wins}, Losses: ${player.losses}'),
                trailing: Text('Rank: ${index + 1}'),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Player>> _getPlayersRanked() async {
    List<Diwaniya> diwaniyat = await DatabaseService().getDiwaniyatForUserOnce(localUserId);
    List<Player> allPlayers = [];
    for (var diwaniya in diwaniyat) {
      List<Player> diwaniyaPlayers = await DatabaseService().getPlayersOnce(diwaniya.id);
      allPlayers.addAll(diwaniyaPlayers);
    }
    return allPlayers;
  }
}
