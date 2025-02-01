import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'database.dart';
import 'models.dart';
import 'package:provider/provider.dart';
import '../settings_provider.dart';
import 'player_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vibration/vibration.dart';

class DiwaniyaDetails extends StatefulWidget {
  final String diwaniyaId;
  final String localUserId;

  DiwaniyaDetails({required this.diwaniyaId, required this.localUserId});

  @override
  _DiwaniyaDetailsState createState() => _DiwaniyaDetailsState();
}

class _DiwaniyaDetailsState extends State<DiwaniyaDetails> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null);
    _tabController = TabController(length: 3, vsync: this);
  }

  void _showAddPlayerDialog() {
    String playerName = '';
    File? playerImage;
    final ImagePicker _picker = ImagePicker();

    void _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        playerImage = pickedFile != null ? File(pickedFile.path) : null;
      });
    }

    void _removeImage() {
      setState(() {
        playerImage = null;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة لاعب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  playerName = value;
                },
                decoration: InputDecoration(hintText: "أدخل اسم اللاعب"),
              ),
              SizedBox(height: 20),
              playerImage != null
                  ? Column(
                children: [
                  Image.file(playerImage!, height: 100),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: _removeImage,
                  ),
                ],
              )
                  : Text('لم يتم تحديد أي صورة'),
              ElevatedButton(
                onPressed: _pickImage,
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
                if (playerName.isNotEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                  String? imageUrl;
                  if (playerImage != null) {
                    imageUrl = await _uploadImage(playerImage!);
                  }
                  Player newPlayer = Player(
                    id: '',
                    name: playerName,
                    imageUrl: imageUrl,
                  );
                  await Provider.of<PlayerProvider>(context, listen: false).addPlayer(newPlayer);
                  await DatabaseService().addPlayer(widget.diwaniyaId, newPlayer);
                  Navigator.pop(context); // Close the progress indicator
                  Navigator.pop(context); // Close the add player dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('players/$fileName');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  void _showEditPlayerDialog(Player player) {
    String? newName = player.name;
    File? newImageFile;
    final ImagePicker _picker = ImagePicker();

    void _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        newImageFile = pickedFile != null ? File(pickedFile.path) : null;
      });
    }

    void _removeImage() {
      setState(() {
        newImageFile = null;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل اللاعب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newName = value;
                },
                decoration: InputDecoration(hintText: "أدخل اسم اللاعب الجديد"),
                controller: TextEditingController(text: player.name),
              ),
              SizedBox(height: 20),
              newImageFile != null
                  ? Column(
                children: [
                  Image.file(newImageFile!, height: 100),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: _removeImage,
                  ),
                ],
              )
                  : (player.imageUrl != null && player.imageUrl!.isNotEmpty
                  ? Column(
                children: [
                  Image.network(player.imageUrl!, height: 100),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: _removeImage,
                  ),
                ],
              )
                  : Text('لم يتم تحديد أي صورة')),
              ElevatedButton(
                onPressed: _pickImage,
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
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                  player.name = newName!;
                  if (newImageFile != null) {
                    player.imageUrl = await _uploadImage(newImageFile!);
                  }
                  await Provider.of<PlayerProvider>(context, listen: false).updatePlayer(player);
                  await DatabaseService().updatePlayer(widget.diwaniyaId, player);
                  await DatabaseService().updatePlayerNameInArchive(widget.diwaniyaId, player.id, newName!);
                  Navigator.pop(context); // Close the progress indicator
                  Navigator.pop(context); // Close the edit player dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showPlayerNameDialog(String playerName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            playerName,
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text('إغلاق'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الديوانية'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddPlayerDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'اللاعبين'),
                Tab(text: 'الترتيب'),
                Tab(text: 'الأرشيف'),
              ],
              labelColor: settingsProvider.appColor,
              indicatorColor: settingsProvider.appColor,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // تبويب اللاعبين
                  StreamBuilder<List<Player>>(
                    stream: DatabaseService().getPlayersStream(widget.diwaniyaId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                      }
                      var players = snapshot.data ?? [];
                      return ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          var player = players[index];
                          double winPercentage = (player.wins + player.losses) > 0
                              ? (player.wins / (player.wins + player.losses)) * 100
                              : 0;
                          return Card(
                            elevation: 5.0,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: settingsProvider.appColor,
                                child: ClipOval(
                                  child: player.imageUrl != null && player.imageUrl!.isNotEmpty
                                      ? Image.network(
                                    player.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                  )
                                      : Container(
                                    color: settingsProvider.appColor,
                                    child: Center(
                                      child: Text(
                                        player.name,
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(player.name),
                              subtitle: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.emoji_events, color: Colors.green),
                                          SizedBox(width: 4),
                                          Text(
                                            'فوز: ${player.wins}',
                                            style: TextStyle(color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
                                          SizedBox(width: 4),
                                          Text(
                                            'خسارة: ${player.losses}',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    children: [
                                      CircularProgressIndicator(
                                        value: winPercentage / 100,
                                        backgroundColor: Colors.red.withOpacity(0.3),
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${winPercentage.toStringAsFixed(1)}%',
                                        style: TextStyle(color: settingsProvider.appColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onLongPress: () {
                                _showEditPlayerDialog(player);
                                Vibration.vibrate();
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // تبويب الترتيب
                  StreamBuilder<List<Player>>(
                    stream: DatabaseService().getPlayersStream(widget.diwaniyaId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                      }
                      var players = snapshot.data ?? [];
                      players = players.where((player) => player.wins != 0 || player.losses != 0).toList();
                      players.sort((a, b) {
                        if (a.wins != b.wins) {
                          return b.wins.compareTo(a.wins);
                        } else {
                          return a.losses.compareTo(b.losses);
                        }
                      });
                      return ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          var player = players[index];
                          return Card(
                            elevation: index < 3 ? 10.0 : 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: settingsProvider.appColor,
                                    child: CircleAvatar(
                                      radius: 27,
                                      backgroundColor: index == 0
                                          ? Colors.amber
                                          : index == 1
                                          ? Colors.grey
                                          : index == 2
                                          ? Colors.brown
                                          : settingsProvider.appColor,
                                      child: ClipOval(
                                        child: player.imageUrl != null && player.imageUrl!.isNotEmpty
                                            ? Image.network(
                                          player.imageUrl!,
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                        )
                                            : Container(
                                          color: settingsProvider.appColor,
                                          child: Center(
                                            child: Text(
                                              player.name,
                                              style: TextStyle(color: Colors.white, fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (index == 0)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Icon(Icons.star, color: Colors.amber, size: 24),
                                    ),
                                  if (index == 1)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Icon(Icons.star, color: Colors.grey, size: 24),
                                    ),
                                  if (index == 2)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Icon(Icons.star, color: Colors.brown, size: 24),
                                    ),
                                ],
                              ),
                              title: Text(
                                player.name,
                                style: TextStyle(
                                  color: index == 0
                                      ? Colors.amber
                                      : index == 1
                                      ? Colors.grey
                                      : index == 2
                                      ? Colors.brown
                                      : settingsProvider.appColor,
                                  fontWeight: index < 3 ? FontWeight.bold : FontWeight.normal,
                                  fontSize: index < 3 ? 20 : 16,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'المركز',
                                    style: TextStyle(
                                      color: index == 0
                                          ? Colors.amber
                                          : index == 1
                                          ? Colors.grey
                                          : index == 2
                                          ? Colors.brown
                                          : settingsProvider.appColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: index == 0
                                          ? Colors.amber
                                          : index == 1
                                          ? Colors.grey
                                          : index == 2
                                          ? Colors.brown
                                          : settingsProvider.appColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // تبويب الأرشيف
                  FutureBuilder<List<ScoreArchive>>(
                    future: DatabaseService().getScoreArchiveOnce(widget.diwaniyaId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                      }
                      var scoreArchive = snapshot.data ?? [];
                      scoreArchive.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // ترتيب الأرشيف من الأحدث إلى الأقدم
                      return ListView.builder(
                        itemCount: scoreArchive.length,
                        itemBuilder: (context, index) {
                          var archive = scoreArchive[index];
                          String formattedDateTime = DateFormat('EEEE, yyyy-MM-dd hh:mm a', 'ar').format(archive.dateTime);

                          return FutureBuilder<List<Player>>(
                            future: DatabaseService().getPlayersOnce(widget.diwaniyaId),
                            builder: (context, playerSnapshot) {
                              if (playerSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              if (playerSnapshot.hasError) {
                                return Center(child: Text('حدث خطأ: ${playerSnapshot.error}'));
                              }
                              var players = playerSnapshot.data ?? [];
                              var teamUs1 = players.firstWhere((player) => player.name == archive.teamUs1).imageUrl;
                              var teamUs2 = players.firstWhere((player) => player.name == archive.teamUs2).imageUrl;
                              var teamThem1 = players.firstWhere((player) => player.name == archive.teamThem1).imageUrl;
                              var teamThem2 = players.firstWhere((player) => player.name == archive.teamThem2).imageUrl;

                              bool usIsWinner = archive.usScore > archive.themScore;
                              bool themIsWinner = archive.themScore > archive.usScore;

                              return Card(
                                elevation: 5.0,
                                child: ListTile(
                                  title: Column(
                                    children: [
                                      Center(
                                        child: Text(
                                          usIsWinner ? 'قامت لنا' : 'قامت لهم',
                                          style: TextStyle(
                                            color: usIsWinner ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Center(
                                        child: Text(
                                          formattedDateTime,
                                          style: TextStyle(color: settingsProvider.appColor),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  _showPlayerNameDialog(archive.teamUs1);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: usIsWinner ? Colors.green : Colors.red,
                                                      width: 2,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipOval(
                                                    child: teamUs1 != null
                                                        ? Image.network(
                                                      teamUs1,
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    )
                                                        : Container(
                                                      width: 50,
                                                      height: 50,
                                                      color: settingsProvider.appColor,
                                                      child: Center(
                                                        child: Text(
                                                          archive.teamUs1,
                                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              GestureDetector(
                                                onTap: () {
                                                  _showPlayerNameDialog(archive.teamUs2);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: usIsWinner ? Colors.green : Colors.red,
                                                      width: 2,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipOval(
                                                    child: teamUs2 != null
                                                        ? Image.network(
                                                      teamUs2,
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    )
                                                        : Container(
                                                      width: 50,
                                                      height: 50,
                                                      color: settingsProvider.appColor,
                                                      child: Center(
                                                        child: Text(
                                                          archive.teamUs2,
                                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  'لنا ${archive.usScore}',
                                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Image.asset(
                                                'assets/logo.png', // ضع مسار صورة شعار التطبيق هنا
                                                width: 50,
                                                height: 50,
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'مدة النشرة',
                                                style: TextStyle(
                                                  color: settingsProvider.appColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(Icons.timer, color: settingsProvider.appColor),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    archive.duration,
                                                    style: TextStyle(
                                                      color: settingsProvider.appColor,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  _showPlayerNameDialog(archive.teamThem1);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: themIsWinner ? Colors.green : Colors.red,
                                                      width: 2,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipOval(
                                                    child: teamThem1 != null
                                                        ? Image.network(
                                                      teamThem1,
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    )
                                                        : Container(
                                                      width: 50,
                                                      height: 50,
                                                      color: settingsProvider.appColor,
                                                      child: Center(
                                                        child: Text(
                                                          archive.teamThem1,
                                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              GestureDetector(
                                                onTap: () {
                                                  _showPlayerNameDialog(archive.teamThem2);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: themIsWinner ? Colors.green : Colors.red,
                                                      width: 2,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipOval(
                                                    child: teamThem2 != null
                                                        ? Image.network(
                                                      teamThem2,
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    )
                                                        : Container(
                                                      width: 50,
                                                      height: 50,
                                                      color: settingsProvider.appColor,
                                                      child: Center(
                                                        child: Text(
                                                          archive.teamThem2,
                                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  'لهم ${archive.themScore}',
                                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
