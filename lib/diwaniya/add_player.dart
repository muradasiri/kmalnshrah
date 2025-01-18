import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'database.dart';
import 'models.dart';


class AddPlayerPage extends StatefulWidget {
  final String diwaniyaId;

  AddPlayerPage({required this.diwaniyaId});

  @override
  _AddPlayerPageState createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final fileName = pickedFile.path.split('/').last;
      final localImage = await File(pickedFile.path).copy('$path/$fileName');
      setState(() {
        _imageFile = localImage;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String imageUrl = 'assets/default_avatar.png';

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('player_images').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(_imageFile!);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      Player newPlayer = Player(
        id: '',
        name: _name!,
        imageUrl: imageUrl,
        wins: 0,
        losses: 0,
      );

      await DatabaseService().addPlayer(widget.diwaniyaId, newPlayer);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة لاعب'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'اسم اللاعب'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              SizedBox(height: 20),
              _imageFile != null
                  ? Image.file(_imageFile!, height: 200)
                  : Text('لم يتم اختيار صورة'),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('اختر صورة'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('إضافة لاعب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
