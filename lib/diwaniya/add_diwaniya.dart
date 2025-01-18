import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class AddDiwaniya extends StatefulWidget {
  final String localUserId;

  AddDiwaniya({required this.localUserId});

  @override
  _AddDiwaniyaState createState() => _AddDiwaniyaState();
}

class _AddDiwaniyaState extends State<AddDiwaniya> {
  final _formKey = GlobalKey<FormState>();
  String _diwaniyaName = '';

  Future<void> _addDiwaniya() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Diwaniya newDiwaniya = Diwaniya(
        id: '',
        name: _diwaniyaName,
        code: '',
        createdBy: widget.localUserId,
        members: [widget.localUserId],
      );

      DocumentReference docRef = await FirebaseFirestore.instance.collection('diwaniyas').add(newDiwaniya.toMap());
      await docRef.update({'id': docRef.id});

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة ديوانية'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'اسم الديوانية'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'الرجاء إدخال اسم الديوانية';
                  }
                  return null;
                },
                onSaved: (value) {
                  _diwaniyaName = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addDiwaniya,
                child: Text('إضافة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
