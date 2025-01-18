import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'diwaniya/diwaniya_home.dart';
import 'diwaniya/models.dart';
import 'diwaniya/database.dart';
import 'settings_provider.dart';

class DiwaniyaSelectionPage extends StatefulWidget {
  final String localUserId;
  final Function(String) nextPageBuilder;

  DiwaniyaSelectionPage({required this.localUserId, required this.nextPageBuilder});

  @override
  _DiwaniyaSelectionPageState createState() => _DiwaniyaSelectionPageState();
}

class _DiwaniyaSelectionPageState extends State<DiwaniyaSelectionPage> {
  List<Diwaniya> diwaniyat = [];

  @override
  void initState() {
    super.initState();
    _loadDiwaniyat();
  }

  Future<void> _loadDiwaniyat() async {
    diwaniyat = await DatabaseService().getDiwaniyatForUserOnce(widget.localUserId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('اختيار ديوانية'),
      ),
      body: diwaniyat.isEmpty
          ? Center(
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiwaniyaHome(localUserId: widget.localUserId)),
                );
              },
              child: Text('الانتقال إلى صفحة الديوانيات', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(settingsProvider.appColor),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: diwaniyat.length,
        itemBuilder: (context, index) {
          var diwaniya = diwaniyat[index];
          return Card(
            elevation: 5.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: diwaniya.imageUrl != null
                    ? NetworkImage(diwaniya.imageUrl!)
                    : AssetImage('assets/default_diwanyah.png') as ImageProvider,
              ),
              title: Text(diwaniya.name),
              subtitle: Text('كود الديوانية: ${diwaniya.code}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget.nextPageBuilder(diwaniya.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
