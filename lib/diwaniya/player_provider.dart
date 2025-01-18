import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart';

class PlayerProvider with ChangeNotifier {
  Map<String, Player> _players = {};

  Map<String, Player> get players => _players;

  PlayerProvider() {
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedPlayers = prefs.getStringList('players');
    if (storedPlayers != null) {
      _players = Map<String, Player>.fromEntries(
        storedPlayers.map(
              (playerData) {
            Map<String, dynamic> playerMap = jsonDecode(playerData);
            Player player = Player.fromMap(playerMap, playerMap['id']);
            return MapEntry(player.id, player);
          },
        ),
      );
    }
    notifyListeners();
  }

  Future<void> _savePlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedPlayers = _players.values.map((player) => jsonEncode(player.toMap())).toList();
    await prefs.setStringList('players', storedPlayers);
  }

  Future<void> addPlayer(Player player) async {
    _players[player.id] = player;
    await _savePlayers();
    notifyListeners();
  }

  Future<void> updatePlayer(Player player) async {
    if (_players.containsKey(player.id)) {
      _players[player.id] = player;
      await _savePlayers();
      notifyListeners();
    }
  }

  Future<void> deletePlayer(String playerId) async {
    if (_players.containsKey(playerId)) {
      _players.remove(playerId);
      await _savePlayers();
      notifyListeners();
    }
  }
}
