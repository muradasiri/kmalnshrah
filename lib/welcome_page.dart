import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final Function(String) onGameSelected;

  WelcomePage({required this.onGameSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أهلاً بك في تطبيق البلوت والطرنيب'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'اختر اللعبة التي ترغب في لعبها:',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onGameSelected('baloot');
              },
              child: Text('بلوت'),
            ),
            ElevatedButton(
              onPressed: () {
                onGameSelected('tarneeb');
              },
              child: Text('طرنيب'),
            ),
          ],
        ),
      ),
    );
  }
}
