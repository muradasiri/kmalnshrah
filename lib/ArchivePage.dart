import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';

class ArchivePage extends StatefulWidget {
  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<String> archiveItems = [];

  @override
  void initState() {
    super.initState();
    _loadArchive();
  }

  Future<void> _loadArchive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      archiveItems = prefs.getStringList('archiveItems') ?? [];
    });
  }

  Future<void> _clearArchive() async {
    bool confirm = await _showConfirmationDialog('هل تريد فعلاً حذف الأرشيف كاملاً؟');
    if (confirm) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('archiveItems');
      setState(() {
        archiveItems.clear();
      });
    }
  }

  Future<void> _removeItem(int index) async {
    bool confirm = await _showConfirmationDialog('هل تريد فعلاً حذف أرشيف هذه الصكة؟');
    if (confirm) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      archiveItems.removeAt(index);
      await prefs.setStringList('archiveItems', archiveItems);
      setState(() {});
    }
  }

  Future<bool> _showConfirmationDialog(String message) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('لا'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('نعم'),
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog(String details, DateTime dateTime) {
    List<String> detailParts = details.split(' - ');
    String winner = detailParts[0];
    String usScore = detailParts[1];
    String themScore = detailParts[2];
    String time = detailParts[3];
    String teamUs = detailParts[4];
    String teamThem = detailParts[5];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('تفاصيل الصكة')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Text(winner, style: TextStyle(fontSize: 18))),
              SizedBox(height: 8.0),
              Center(child: Text(usScore, style: TextStyle(fontSize: 16))),
              SizedBox(height: 8.0),
              Center(child: Text(themScore, style: TextStyle(fontSize: 16))),
              SizedBox(height: 8.0),
              Center(child: Text('$time', style: TextStyle(fontSize: 14))),
              SizedBox(height: 8.0),
              Center(child: Text('فريقنا: $teamUs', style: TextStyle(fontSize: 14))),
              SizedBox(height: 8.0),
              Center(child: Text('فريقهم: $teamThem', style: TextStyle(fontSize: 14))),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إغلاق'),
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
        title: Text('أرشيف الصكات'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearArchive,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: archiveItems.length,
        itemBuilder: (context, index) {
          String item = archiveItems[index];
          List<String> parts = item.split('|');
          DateTime dateTime = DateTime.parse(parts[0]);
          String formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
          String details = parts[1];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              title: Text('صكة رقم ${index + 1} - $formattedDate'),
              subtitle: Text(details.split(' - ')[0]),
              trailing: IconButton(
                icon: Icon(Icons.close, color: settingsProvider.appColor),
                onPressed: () => _removeItem(index),
              ),
              onTap: () {
                _showDetailsDialog(details, dateTime);
              },
            ),
          );
        },
      ),
    );
  }
}
