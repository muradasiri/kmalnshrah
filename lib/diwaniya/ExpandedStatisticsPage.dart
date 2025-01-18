import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'models.dart';

class ExpandedStatisticsPage extends StatelessWidget {
  final String localUserId;

  ExpandedStatisticsPage({required this.localUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expanded Statistics'),
      ),
      body: FutureBuilder<List<Diwaniya>>(
        future: DatabaseService().getDiwaniyatForUserOnce(localUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Diwaniyat available.'));
          }

          List<Diwaniya> diwaniyat = snapshot.data!;
          return ListView.builder(
            itemCount: diwaniyat.length,
            itemBuilder: (context, index) {
              Diwaniya diwaniya = diwaniyat[index];
              return ExpansionTile(
                title: Text(diwaniya.name),
                children: [
                  FutureBuilder<List<Player>>(
                    future: DatabaseService().getPlayersOnce(diwaniya.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No players in this Diwaniya.'));
                      }

                      List<Player> players = snapshot.data!;
                      return Column(
                        children: players.map((player) {
                          return ListTile(
                            title: Text(player.name),
                            subtitle: Text('Wins: ${player.wins}, Losses: ${player.losses}'),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
