import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'database.dart';
import 'models.dart';

class AddDiwaniya extends StatefulWidget {
  @override
  _AddDiwaniyaState createState() => _AddDiwaniyaState();
}

class _AddDiwaniyaState extends State<AddDiwaniya> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _image;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadImageAndAddDiwaniya(String name) async {
    String imageUrl = 'assets/default_avatar.png';
    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref().child('diwaniya_images').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    final diwaniya = Diwaniya(
      id: '',
      name: name,
      imageUrl: imageUrl, code: '', createdBy: '', members: [],
    );

    try {
      await DatabaseService().addDiwaniya(diwaniya);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add diwaniya: $e')),
      );
    }
  }

  Future<void> _addDiwaniya() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      await _uploadImageAndAddDiwaniya(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة ديوانية جديدة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'اسم الديوانية'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم الديوانية';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : AssetImage('assets/default_avatar.png') as ImageProvider,
                    child: _image == null
                        ? Icon(
                      Icons.camera_alt,
                      color: Colors.grey[800],
                    )
                        : null,
                  ),
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
      ),
    );
  }
}
