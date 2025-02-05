import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  DatabaseService() {
    final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // استيراد الديوانيات للمستخدم
  Stream<List<Diwaniya>> getDiwaniyatForUser(String userId) {
    return _db
        .collection('diwaniyat')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Diwaniya.fromMap(doc.data(), doc.id)).toList());
  }

  Future<List<Diwaniya>> getDiwaniyatForUserOnce(String userId) async {
    var snapshot = await _db
        .collection('diwaniyat')
        .where('members', arrayContains: userId)
        .get();
    return snapshot.docs.map((doc) => Diwaniya.fromMap(doc.data(), doc.id)).toList();
  }

  // استيراد اللاعبين
  Stream<List<Player>> getPlayersStream(String diwaniyaId) {
    return _db
        .collection('diwaniyat')
        .doc(diwaniyaId)
        .collection('players')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Player.fromMap(doc.data(), doc.id)).toList());
  }

  Future<List<Player>> getPlayersOnce(String diwaniyaId) async {
    var snapshot = await _db
        .collection('diwaniyat')
        .doc(diwaniyaId)
        .collection('players')
        .get();
    return snapshot.docs.map((doc) => Player.fromMap(doc.data(), doc.id)).toList();
  }

  // إضافة، تحديث، وحذف اللاعبين
  Future<void> addPlayer(String diwaniyaId, Player player) async {
    var docRef = await _db.collection('diwaniyat').doc(diwaniyaId).collection('players').add(player.toMap());
    await docRef.update({'id': docRef.id});
  }

  Future<void> updatePlayer(String diwaniyaId, Player player) async {
    await _db.collection('diwaniyat').doc(diwaniyaId).collection('players').doc(player.id).update(player.toMap());
  }

  Future<void> deletePlayer(String diwaniyaId, String playerId) async {
    // احصل على بيانات اللاعب قبل الحذف
    var playerSnapshot = await _db.collection('diwaniyat').doc(diwaniyaId).collection('players').doc(playerId).get();
    var playerData = playerSnapshot.data();

    // إضافة بيانات اللاعب إلى أرشيف اللاعبين المحذوفين
    if (playerData != null) {
      await _db.collection('diwaniyat').doc(diwaniyaId).collection('deletedPlayersArchive').add(playerData);
      await _db.collection('diwaniyat').doc(diwaniyaId).collection('players').doc(playerId).update({'isDeleted': true});
    }
  }

  Future<void> leaveDiwaniya(String diwaniyaId, String userId) async {
    await _db.collection('diwaniyat').doc(diwaniyaId).update({
      'members': FieldValue.arrayRemove([userId])
    });
  }

  // إضافة، تحديث، والدخول إلى الديوانية
  Future<void> addDiwaniya(Diwaniya diwaniya) async {
    var docRef = await _db.collection('diwaniyat').add(diwaniya.toMap());
    await docRef.update({'id': docRef.id});
  }

  Future<void> updateDiwaniya(Diwaniya diwaniya) async {
    await _db.collection('diwaniyat').doc(diwaniya.id).update(diwaniya.toMap());
  }

  Future<void> joinDiwaniya(String code, String userId) async {
    var snapshot = await _db.collection('diwaniyat').where('code', isEqualTo: code).get();
    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first;
      await _db.collection('diwaniyat').doc(doc.id).update({
        'members': FieldValue.arrayUnion([userId])
      });
    } else {
      throw Exception('Diwaniya code not found');
    }
  }

  // إضافة الأرشيف
  Future<void> addToScoreArchive(
      String diwaniyaId,
      String winner,
      int usScore,
      int themScore,
      String duration,
      String teamUs1,
      String teamUs2,
      String teamThem1,
      String teamThem2,
      DateTime dateTime,
      ) async {
    var archive = ScoreArchive(
      id: '',
      winner: winner,
      usScore: usScore,
      themScore: themScore,
      duration: duration,
      dateTime: dateTime,
      teamUs1: teamUs1,
      teamUs2: teamUs2,
      teamThem1: teamThem1,
      teamThem2: teamThem2,
    );
    var docRef = await _db
        .collection('diwaniyat')
        .doc(diwaniyaId)
        .collection('scoreArchive')
        .add(archive.toMap());
    await docRef.update({'id': docRef.id});
  }

  // تحديث سجل اللاعب
  Future<void> updatePlayerRecord(String diwaniyaId, String playerId, bool won) async {
    var playerRef = _db.collection('diwaniyat').doc(diwaniyaId).collection('players').doc(playerId);
    var playerSnapshot = await playerRef.get();
    var playerData = playerSnapshot.data();
    int wins = playerData?['wins'] ?? 0;
    int losses = playerData?['losses'] ?? 0;

    if (won) {
      wins += 1;
    } else {
      losses += 1;
    }

    await playerRef.update({
      'wins': wins,
      'losses': losses,
    });
  }

  Future<Map<String, dynamic>> getPlayerRecord(String diwaniyaId, String playerId) async {
    var snapshot = await _db.collection('diwaniyat').doc(diwaniyaId).collection('players').doc(playerId).get();
    return snapshot.data() ?? {};
  }

  Future<void> updatePlayerNameInArchive(String diwaniyaId, String oldName, String newName) async {
    var archiveRef = _db.collection('diwaniyat').doc(diwaniyaId).collection('scoreArchive');
    var archiveSnapshot = await archiveRef.where('teamUs1', isEqualTo: oldName).get();
    for (var doc in archiveSnapshot.docs) {
      await doc.reference.update({'teamUs1': newName});
    }
    archiveSnapshot = await archiveRef.where('teamUs2', isEqualTo: oldName).get();
    for (var doc in archiveSnapshot.docs) {
      await doc.reference.update({'teamUs2': newName});
    }
    archiveSnapshot = await archiveRef.where('teamThem1', isEqualTo: oldName).get();
    for (var doc in archiveSnapshot.docs) {
      await doc.reference.update({'teamThem1': newName});
    }
    archiveSnapshot = await archiveRef.where('teamThem2', isEqualTo: oldName).get();
    for (var doc in archiveSnapshot.docs) {
      await doc.reference.update({'teamThem2': newName});
    }
  }

  Stream<List<ScoreArchive>> getScoreArchiveStream(String diwaniyaId) {
    return _db
        .collection('diwaniyat')
        .doc(diwaniyaId)
        .collection('scoreArchive')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ScoreArchive.fromMap(doc.data(), doc.id)).toList());
  }

  Future<List<ScoreArchive>> getScoreArchiveOnce(String diwaniyaId) async {
    var snapshot = await _db
        .collection('diwaniyat')
        .doc(diwaniyaId)
        .collection('scoreArchive')
        .get();
    return snapshot.docs.map((doc) => ScoreArchive.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<Map<String, dynamic>>> getDeletedPlayersArchive(String diwaniyaId) async {
    var snapshot = await _db
        .collection('diwaniyat')
        .doc(diwaniyaId)
        .collection('deletedPlayersArchive')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> sendNotificationToDiwaniyaMembers(String diwaniyaId, String title, String message) async {
    var diwaniyaDoc = await _db.collection('diwaniyat').doc(diwaniyaId).get();
    var diwaniyaData = diwaniyaDoc.data();

    if (diwaniyaData != null) {
      List<String> memberIds = List<String>.from(diwaniyaData['members'] ?? []);
      for (var memberId in memberIds) {
        // احصل على رمز FCM للعضو من قاعدة البيانات
        var memberDoc = await _db.collection('users').doc(memberId).get();
        var memberData = memberDoc.data();
        if (memberData != null && memberData['fcmToken'] != null) {
          String fcmToken = memberData['fcmToken'];
          await _sendNotification(fcmToken, title, message);
        }
      }
    }
  }

  Future<void> _sendNotification(String fcmToken, String title, String message) async {
    final String serverKey = 'AIzaSyCNUB0-pR7XD-2K4cjnmRxd2dwKYFI7fGw'; // استبدلها بمفتاح الخادم الخاص بك من FCM

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(<String, dynamic>{
          'to': fcmToken,
          'notification': <String, dynamic>{
            'title': title,
            'body': message,
          },
        }),
      );
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }
}
