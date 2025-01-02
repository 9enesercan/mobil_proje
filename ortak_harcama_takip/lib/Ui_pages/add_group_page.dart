import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGroupPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddGroup;
  final User? currentUser;

  AddGroupPage({required this.onAddGroup, required this.currentUser});

  @override
  _AddGroupPageState createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isAddingGroup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grup Ekle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Grup Adı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isAddingGroup ? null : _addGroup,
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _addGroup() async {
    final String name = _nameController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen grup adını girin')),
      );
      return;
    }

    final Map<String, dynamic> newGroup = {
      'name': name,
      'createdBy': widget.currentUser?.uid ?? '',
      'members': [widget.currentUser?.uid ?? ''],
      'groupJoinId': (100000 +
              (999999 - 100000) *
                  (DateTime.now().millisecondsSinceEpoch % 1000000) %
                  900000)
          .toString(),
    };

    setState(() {
      _isAddingGroup = true;
    });

    try {
      await FirebaseFirestore.instance.collection('groups').add(newGroup);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grup başarıyla kaydedildi')),
      );
      widget.onAddGroup(newGroup);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grup eklenirken hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isAddingGroup = false;
      });
    }
  }
}
