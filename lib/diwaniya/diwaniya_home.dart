import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';
import 'diwaniya_details.dart';
import 'models.dart';
import 'package:provider/provider.dart';
import '../settings_provider.dart';

class DiwaniyaHome extends StatefulWidget {
  final String localUserId;

  DiwaniyaHome({required this.localUserId});

  @override
  _DiwaniyaHomeState createState() => _DiwaniyaHomeState();
}

class _DiwaniyaHomeState extends State<DiwaniyaHome> {
  List<Diwaniya> _diwaniyat = [];
  Map<String, List<Player>> _playersByDiwaniya = {};

  @override
  void initState() {
    super.initState();
    _loadLocalDiwaniyatAndPlayers();
    _syncDiwaniyatAndPlayersIfNeeded();
  }

  Future<void> _loadLocalDiwaniyatAndPlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? diwaniyatData = prefs.getString('diwaniyat');
    String? playersData = prefs.getString('players');

    if (diwaniyatData != null && playersData != null) {
      List<Diwaniya> localDiwaniyat = (jsonDecode(diwaniyatData) as List)
          .map((data) => Diwaniya.fromMap(data, data['id']))
          .toList();
      Map<String, List<Player>> localPlayers = (jsonDecode(playersData) as Map).map((diwaniyaId, players) {
        var playerList = (players as List).map((data) => Player.fromMap(data, data['id'])).toList();
        return MapEntry(diwaniyaId, playerList);
      });

      setState(() {
        _diwaniyat = localDiwaniyat;
        _playersByDiwaniya = localPlayers;
      });
    }
  }

  Future<void> _syncDiwaniyatAndPlayersIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? diwaniyatData = prefs.getString('diwaniyat');
    String? playersData = prefs.getString('players');

    // Fetch updated diwaniyat and players from Firestore
    List<Diwaniya> updatedDiwaniyat = await DatabaseService().getDiwaniyatForUserOnce(widget.localUserId);
    Map<String, List<Player>> updatedPlayers = {};

    for (var diwaniya in updatedDiwaniyat) {
      updatedPlayers[diwaniya.id] = await DatabaseService().getPlayersOnce(diwaniya.id);
    }

    // Compare with local data to see if there's any change
    List<Diwaniya> localDiwaniyat = diwaniyatData != null
        ? (jsonDecode(diwaniyatData) as List).map((data) => Diwaniya.fromMap(data, data['id'])).toList()
        : [];
    Map<String, List<Player>> localPlayers = playersData != null
        ? (jsonDecode(playersData) as Map).map((diwaniyaId, players) {
      var playerList = (players as List).map((data) => Player.fromMap(data, data['id'])).toList();
      return MapEntry(diwaniyaId, playerList);
    })
        : {};

    bool diwaniyatChanged = !listEquals(localDiwaniyat, updatedDiwaniyat);
    bool playersChanged = !mapEquals(localPlayers, updatedPlayers);

    if (diwaniyatChanged || playersChanged) {
      // Save updated data locally
      prefs.setString('diwaniyat', jsonEncode(updatedDiwaniyat.map((diwaniya) => diwaniya.toMap()).toList()));
      prefs.setString('players', jsonEncode(updatedPlayers.map((diwaniyaId, players) => MapEntry(
          diwaniyaId,
          players.map((player) => player.toMap()).toList()))));

      setState(() {
        _diwaniyat = updatedDiwaniyat;
        _playersByDiwaniya = updatedPlayers;
      });
    }
  }

  void _showJoinDiwaniyaDialog() {
    String code = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ادخل ديوانية'),
          content: TextField(
            onChanged: (value) {
              code = value;
            },
            decoration: InputDecoration(hintText: "أدخل كود الديوانية"),
          ),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('دخول'),
              onPressed: () async {
                if (code.isNotEmpty) {
                  try {
                    await DatabaseService().joinDiwaniya(code, widget.localUserId);
                    _syncDiwaniyatAndPlayersIfNeeded();
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('كود الديوانية غير صحيح')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(Function(File?) onImagePicked) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File? compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        '${pickedFile.path}_compressed.jpg',
        quality: 70,
      );
      onImagePicked(compressedImage);
    }
  }

  void _showAddDiwaniyaDialog() {
    String diwaniyaName = '';
    File? diwaniyaImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('إضافة ديوانية'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      diwaniyaName = value;
                    },
                    decoration: InputDecoration(hintText: "أدخل اسم الديوانية"),
                  ),
                  SizedBox(height: 20),
                  diwaniyaImage != null
                      ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(diwaniyaImage!, height: 100),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            diwaniyaImage = null;
                          });
                        },
                      ),
                    ],
                  )
                      : Text('لم يتم تحديد أي صورة'),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage((image) {
                        setState(() {
                          diwaniyaImage = image;
                        });
                      });
                    },
                    child: Text('اختر صورة'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('إلغاء'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('إضافة'),
                  onPressed: () async {
                    if (diwaniyaName.isNotEmpty) {
                      String code = _generateDiwaniyaCode();
                      String? imageUrl;
                      if (diwaniyaImage != null) {
                        imageUrl = await _uploadImage(diwaniyaImage!);
                      }
                      Diwaniya newDiwaniya = Diwaniya(
                        id: '',
                        name: diwaniyaName,
                        imageUrl: imageUrl,
                        code: code,
                        createdBy: widget.localUserId,
                        members: [widget.localUserId],
                      );
                      await DatabaseService().addDiwaniya(newDiwaniya);
                      _syncDiwaniyatAndPlayersIfNeeded();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String> _uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('diwaniyat/$fileName');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  String _generateDiwaniyaCode() {
    const length = 7;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void _showOptions(BuildContext context, Diwaniya diwaniya) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('تعديل الاسم والصورة'),
              onTap: () {
                Navigator.pop(context);
                _showEditDiwaniyaDialog(diwaniya);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('خروج من الديوانية'),
              onTap: () async {
                Navigator.pop(context);
                await DatabaseService().leaveDiwaniya(diwaniya.id, widget.localUserId);
                _syncDiwaniyatAndPlayersIfNeeded();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDiwaniyaDialog(Diwaniya diwaniya) {
    String? newName = diwaniya.name;
    File? newImageFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('تعديل الديوانية'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      newName = value;
                    },
                    decoration: InputDecoration(hintText: "أدخل اسم الديوانية الجديد"),
                    controller: TextEditingController(text: diwaniya.name),
                  ),
                  SizedBox(height: 20),
                  newImageFile != null
                      ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(newImageFile!, height: 100),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            newImageFile = null;
                          });
                        },
                      ),
                    ],
                  )
                      : (diwaniya.imageUrl != null
                      ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.network(diwaniya.imageUrl!, height: 100),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            diwaniya.imageUrl = null;
                          });
                        },
                      ),
                    ],
                  )
                      : Text('No image selected')),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage((image) {
                        setState(() {
                          newImageFile = image;
                        });
                      });
                    },
                    child: Text('اختر صورة جديدة'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('إلغاء'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('تعديل'),
                  onPressed: () async {
                    if (newName != null && newName!.isNotEmpty) {
                      diwaniya.name = newName!;
                      if (newImageFile != null) {
                        diwaniya.imageUrl = await _uploadImage(newImageFile!);
                      }
                      await DatabaseService().updateDiwaniya(diwaniya);
                      _syncDiwaniyatAndPlayersIfNeeded();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('الديوانيات'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddDiwaniyaDialog,
          ),
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed: _showJoinDiwaniyaDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<Diwaniya>>(
        stream: DatabaseService().getDiwaniyatForUser(widget.localUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var diwaniyat = snapshot.data!;
          if (diwaniyat.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لا يوجد لديك ديوانيات حالياً.',
                      style: TextStyle(fontSize: 18, color: settingsProvider.appColor),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'يمكنك الانضمام إلى ديوانية موجودة باستخدام كود الديوانية أو إنشاء ديوانية جديدة خاصة بك.',
                      style: TextStyle(fontSize: 16, color: settingsProvider.appColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showJoinDiwaniyaDialog,
                      child: Text('انضم الى ديوانية موجودة', style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(settingsProvider.appColor),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _showAddDiwaniyaDialog,
                      child: Text('انشاء ديوانية جديدة', style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(settingsProvider.appColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: diwaniyat.length,
            itemBuilder: (context, index) {
              var diwaniya = diwaniyat[index];
              return FutureBuilder<List<Player>>(
                future: DatabaseService().getPlayersOnce(diwaniya.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var players = snapshot.data!;
                  var topPlayers = players.where((player) => player.wins != 0 || player.losses != 0).toList();
                  topPlayers.sort((a, b) {
                    if (a.wins != b.wins) {
                      return b.wins.compareTo(a.wins);
                    } else {
                      return a.losses.compareTo(b.losses);
                    }
                  });
                  return GestureDetector(
                    onLongPress: () {
                      _showOptions(context, diwaniya);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiwaniyaDetails(
                            diwaniyaId: diwaniya.id,
                            localUserId: widget.localUserId,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5.0,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: settingsProvider.appColor,
                          radius: 30,
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            backgroundImage: diwaniya.imageUrl != null
                                ? NetworkImage(diwaniya.imageUrl!)
                                : AssetImage('assets/default_diwanyah.png') as ImageProvider,
                          ),
                        ),
                        title: Text(
                          diwaniya.name,
                          style: TextStyle(
                            color: settingsProvider.appColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('كود الديوانية: ${diwaniya.code}'),
                                IconButton(
                                  icon: Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: diwaniya.code));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('تم نسخ الكود')),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.group),
                                SizedBox(width: 5),
                                Text('${diwaniya.members.length} عضو'),
                              ],
                            ),
                          ],
                        ),

                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTopPlayerAvatarWithTrophy(Player player, Color borderColor, Color appColor, IconData trophyIcon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: borderColor,
            child: CircleAvatar(
              radius: 26,
              backgroundColor: appColor,
              backgroundImage: player.imageUrl != null
                  ? NetworkImage(player.imageUrl!)
                  : null,
              child: player.imageUrl == null
                  ? Text(
                player.name[0],
                style: TextStyle(color: Colors.white),
              )
                  : null,
            ),
          ),

        ],
      ),
    );
  }
}
