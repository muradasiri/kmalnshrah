import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'models.dart';

final diwaniyatProvider = FutureProvider.autoDispose.family<List<Diwaniya>, String>((ref, userId) async {
  return await DatabaseService().getDiwaniyatForUserOnce(userId);
});

final playersProvider = FutureProvider.autoDispose.family<List<Player>, String>((ref, diwaniyaId) async {
  return await DatabaseService().getPlayersOnce(diwaniyaId);
});
